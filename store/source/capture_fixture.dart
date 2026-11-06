import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pick_for_me/app/app.dart';
import 'package:pick_for_me/app/router.dart';
import 'package:pick_for_me/data/models/decision.dart';
import 'package:pick_for_me/data/models/app_settings.dart';
import 'package:pick_for_me/data/repositories/local_repository.dart';
import 'package:pick_for_me/features/decisions/view_models/app_view_model.dart';
import 'package:hive_ce/hive.dart';

class UnusedBox implements Box<String> {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class PreviewRepository extends LocalRepository {
  PreviewRepository() : super(UnusedBox());
  final now = DateTime(2026, 11, 6, 18, 30);
  @override
  List<DecisionList> get lists => [
    DecisionList(
      id: 'dinner',
      title: 'What’s for dinner?',
      options: ['Pizza', 'Sushi', 'Tacos', 'Pasta', 'Burgers', 'Salad'],
      createdAt: now,
      updatedAt: now,
    ),
    DecisionList(
      id: 'movie',
      title: 'Movie night',
      options: ['Comedy', 'Thriller', 'Animation', 'Adventure'],
      createdAt: now,
      updatedAt: now,
    ),
    DecisionList(
      id: 'weekend',
      title: 'Weekend plans',
      options: ['Beach day', 'Road trip', 'Game night', 'A little adventure'],
      createdAt: now,
      updatedAt: now,
    ),
    DecisionList(
      id: 'play',
      title: 'What should we play?',
      options: ['Cards', 'Board game', 'Video game', 'Charades'],
      createdAt: now,
      updatedAt: now,
    ),
  ];
  @override
  List<DecisionResult> get history => [
    DecisionResult(
      id: 'r1',
      decisionListId: 'dinner',
      decisionTitle: 'What’s for dinner?',
      selectedOption: 'Pizza',
      selectionMode: SelectionMode.wheel,
      createdAt: now,
    ),
    DecisionResult(
      id: 'r2',
      decisionListId: 'movie',
      decisionTitle: 'Movie night',
      selectedOption: 'Adventure',
      selectionMode: SelectionMode.list,
      createdAt: now.subtract(const Duration(hours: 2)),
    ),
    DecisionResult(
      id: 'r3',
      decisionListId: 'weekend',
      decisionTitle: 'Weekend plans',
      selectedOption: 'Beach day',
      selectionMode: SelectionMode.wheel,
      createdAt: now.subtract(const Duration(days: 1)),
    ),
  ];
  AppSettings value = const AppSettings(
    soundEnabled: false,
    vibrationEnabled: false,
    themeMode: 'light',
  );
  @override
  AppSettings get settings => value;
  @override
  Future<void> saveSettings(AppSettings settings) async {
    value = settings;
  }
}

void main() {
  testWidgets('Capture real app screens for store assets', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    await tester.runAsync(() async {
      for (final entry in {
        'Roboto':
            '${Platform.environment['PICKFORME_FLUTTER_FONTS']}/Roboto-Regular.ttf',
        'Ahem':
            '${Platform.environment['PICKFORME_FLUTTER_FONTS']}/Roboto-Regular.ttf',
        'MaterialIcons':
            '${Platform.environment['PICKFORME_FLUTTER_FONTS']}/MaterialIcons-Regular.otf',
        if (File(
          Platform.environment['PICKFORME_EMOJI_FONT'] ??
              '/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf',
        ).existsSync())
          'Noto Color Emoji':
              Platform.environment['PICKFORME_EMOJI_FONT'] ??
              '/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf',
      }.entries) {
        final loader = FontLoader(entry.key)
          ..addFont(
            File(entry.value)
                .readAsBytes()
                .then((v) => ByteData.sublistView(v)),
          );
        await loader.load();
      }
    });
    final repo = PreviewRepository();
    final key = GlobalKey();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [repositoryProvider.overrideWithValue(repo)],
        child: RepaintBoundary(key: key, child: const PickForMeApp()),
      ),
    );
    await tester.pumpAndSettle();
    Future<void> shot(String name) async {
      await tester.pumpAndSettle();
      final boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 3);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File('store/raw-screenshots/$name.png')
            .writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }

    await shot('01-home');
    appRouter.go('/create', extra: repo.lists.first);
    await shot('02-create');
    appRouter.go('/pick', extra: repo.lists.first);
    await shot('03-wheel');
    await tester.tap(find.text('Shuffle list'));
    await shot('04-shuffle');
    appRouter.go('/result', extra: repo.history.first);
    await shot('05-result');
    appRouter.go('/saved');
    await shot('06-saved-lists');
    appRouter.go('/settings');
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(key.currentContext!);
    await container
        .read(appViewModelProvider.notifier)
        .settings(repo.settings.copyWith(themeMode: 'dark'));
    await shot('07-dark-settings');
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
