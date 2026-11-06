import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/decision.dart';
import '../../../data/models/app_settings.dart';
import '../../../data/repositories/local_repository.dart';

final repositoryProvider = Provider<LocalRepository>(
  (ref) => throw UnimplementedError('Override at bootstrap'),
);
final appViewModelProvider = NotifierProvider<AppViewModel, AppState>(
  AppViewModel.new,
);

class AppState {
  final List<DecisionList> lists;
  final List<DecisionResult> history;
  final AppSettings settings;
  const AppState(this.lists, this.history, this.settings);
}

class AppViewModel extends Notifier<AppState> {
  LocalRepository get _repo => ref.read(repositoryProvider);
  @override
  AppState build() => AppState(_repo.lists, _repo.history, _repo.settings);
  Future<void> save(DecisionList value) async {
    final next = [value, ...state.lists.where((e) => e.id != value.id)];
    await _repo.saveLists(next);
    state = AppState(next, state.history, state.settings);
  }

  Future<void> delete(String id) async {
    final next = state.lists.where((e) => e.id != id).toList();
    await _repo.saveLists(next);
    state = AppState(next, state.history, state.settings);
  }

  Future<void> duplicate(DecisionList value) => save(
    DecisionList(
      id: newId(),
      title: '${value.title} (copy)',
      options: value.options,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  );
  Future<void> record(DecisionResult value) async {
    final next = [value, ...state.history];
    await _repo.saveHistory(next);
    state = AppState(state.lists, next, state.settings);
  }

  Future<void> clearHistory() async {
    await _repo.saveHistory([]);
    state = AppState(state.lists, [], state.settings);
  }

  Future<void> settings(AppSettings value) async {
    await _repo.saveSettings(value);
    state = AppState(state.lists, state.history, value);
  }
}

int _sequence = 0;
String newId() => '${DateTime.now().microsecondsSinceEpoch}-${_sequence++}';
