import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:pick_for_me/app/app.dart';
import 'package:pick_for_me/core/services/random_service.dart';
import 'package:pick_for_me/data/models/decision.dart';
import 'package:pick_for_me/data/models/app_settings.dart';
import 'package:pick_for_me/data/repositories/local_repository.dart';
import 'package:pick_for_me/features/decisions/view_models/app_view_model.dart';
import 'package:pick_for_me/features/decisions/view_models/editor_view_model.dart';
import 'package:pick_for_me/features/decisions/view_models/picker_view_model.dart';

void main() {
  test(
    'Wheel lands under pointer for every winner and arbitrary prior rotation',
    () {
      for (final count in [2, 3, 6, 13, 100]) {
        for (var winner = 0; winner < count; winner++) {
          for (final current in [0.0, 1.234, 95.7, -12.4]) {
            final target = RandomService.targetRotation(current, winner, count);
            expect(RandomService.indexAtPointer(target, count), winner);
            expect(target - current, greaterThanOrEqualTo(12 * pi));
          }
        }
      }
    },
  );
  test('Secure picker bounds and invalid counts', () {
    final random = RandomService();
    expect(() => random.select(1), throwsArgumentError);
    for (var i = 0; i < 1000; i++) {
      expect(random.select(7), inInclusiveRange(0, 6));
    }
  });
  test('Editor validates and preserves reordered choices', () {
    final vm = EditorViewModel(null);
    expect(vm.validate(), isNull);
    vm.title = '  Dinner  ';
    vm.options[0] = ' Pizza ';
    vm.options[1] = 'Sushi';
    vm.add();
    vm.reorder(0, 2);
    final result = vm.validate()!;
    expect(result.title, 'Dinner');
    expect(result.options, ['Sushi', 'Pizza']);
  });
  test('Saved lists, results and settings survive reopening Hive', () async {
    final temp = await Directory.systemTemp.createTemp('pickforme_test');
    Hive.init(temp.path);
    var box = await Hive.openBox<String>('app');
    var repo = LocalRepository(box);
    final now = DateTime.now();
    final list = DecisionList(
      id: 'a',
      title: 'Dinner',
      options: ['Pizza', 'Sushi'],
      createdAt: now,
      updatedAt: now,
    );
    await repo.saveLists([list]);
    final vm = PickerViewModel(list, random: RandomService(random: Random(4)));
    vm.begin();
    final result = vm.finish(
      RandomService.targetRotation(0, vm.winner!, 2),
      saved: true,
    );
    await repo.saveHistory([result]);
    await repo.saveSettings(
      const AppSettings(themeMode: 'dark', soundEnabled: false),
    );
    await box.close();
    box = await Hive.openBox<String>('app');
    repo = LocalRepository(box);
    expect(repo.lists.single.options, ['Pizza', 'Sushi']);
    expect(repo.history.single.selectedOption, list.options[vm.winner!]);
    expect(repo.settings.themeMode, 'dark');
    expect(repo.settings.soundEnabled, false);
    await Hive.close();
    await temp.delete(recursive: true);
  });
  test(
    'View model saves, edits, duplicates, deletes and clears history',
    () async {
      final repo = MemoryRepository();
      final container = ProviderContainer(
        overrides: [repositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      final vm = container.read(appViewModelProvider.notifier);
      final now = DateTime.now();
      final list = DecisionList(
        id: 'one',
        title: 'Dinner',
        options: ['Pizza', 'Sushi'],
        createdAt: now,
        updatedAt: now,
      );
      await vm.save(list);
      await vm.save(
        DecisionList(
          id: 'one',
          title: 'Lunch',
          options: list.options,
          createdAt: now,
          updatedAt: now,
        ),
      );
      expect(repo.lists.single.title, 'Lunch');
      await vm.duplicate(repo.lists.single);
      expect(repo.lists.length, 2);
      await vm.delete('one');
      expect(repo.lists.single.title, 'Lunch (copy)');
      await vm.settings(
        const AppSettings(themeMode: 'dark', vibrationEnabled: false),
      );
      expect(container.read(appViewModelProvider).settings.themeMode, 'dark');
      await vm.record(
        DecisionResult(
          id: 'r',
          decisionTitle: 'Lunch',
          selectedOption: 'Pizza',
          selectionMode: SelectionMode.list,
          createdAt: now,
        ),
      );
      expect(repo.history.length, 1);
      await vm.clearHistory();
      expect(repo.history, isEmpty);
    },
  );
  testWidgets('Create, save, spin and reveal a real result', (tester) async {
    final repo = MemoryRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [repositoryProvider.overrideWithValue(repo)],
        child: const PickForMeApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start a new decision'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Dinner');
    await tester.enterText(find.byType(TextFormField).at(1), 'Pizza');
    await tester.enterText(find.byType(TextFormField).at(2), 'Sushi');
    await tester.ensureVisible(find.text('Save list & let’s pick'));
    await tester.runAsync(() async {
      await tester.tap(find.text('Save list & let’s pick'));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();
    expect(repo.lists.length, 1);
    await tester.scrollUntilVisible(
      find.text('Let’s spin!'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Let’s spin!'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();
    expect(find.text('AND THE WINNER IS…'), findsOneWidget);
    expect(repo.history.length, 1);
    expect(['Pizza', 'Sushi'], contains(repo.history.single.selectedOption));
    await tester.tap(find.text('Pick again'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Shuffle list'),
      -250,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Shuffle list'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Pick for me!'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Pick for me!'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(repo.history.length, 2);
    expect(repo.history.first.selectionMode, SelectionMode.list);
    expect(find.text('AND THE WINNER IS…'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

class UnusedBox implements Box<String> {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MemoryRepository extends LocalRepository {
  MemoryRepository() : super(UnusedBox());
  List<DecisionList> _lists = [];
  List<DecisionResult> _history = [];
  AppSettings _settings = const AppSettings();
  @override
  List<DecisionList> get lists => _lists;
  @override
  List<DecisionResult> get history => _history;
  @override
  AppSettings get settings => _settings;
  @override
  Future<void> saveLists(List<DecisionList> values) async {
    _lists = values;
  }

  @override
  Future<void> saveHistory(List<DecisionResult> values) async {
    _history = values;
  }

  @override
  Future<void> saveSettings(AppSettings value) async {
    _settings = value;
  }
}
