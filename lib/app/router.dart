import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/models/decision.dart';
import '../features/home/views/home_view.dart';
import '../features/decisions/views/editor_view.dart';
import '../features/decisions/views/picker_view.dart';
import '../features/decisions/views/result_view.dart';
import '../features/library/views/library_view.dart';
import '../features/settings/views/settings_view.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, _) => const HomeView()),
    GoRoute(
      path: '/create',
      builder: (_, s) => EditorView(
        initial: s.extra is DecisionList ? s.extra as DecisionList : null,
      ),
    ),
    GoRoute(
      path: '/pick',
      builder: (_, s) => s.extra is DecisionList
          ? PickerView(decision: s.extra as DecisionList)
          : const MissingDecision(),
    ),
    GoRoute(
      path: '/result',
      builder: (_, s) => s.extra is DecisionResult
          ? ResultView(result: s.extra as DecisionResult)
          : const MissingDecision(),
    ),
    GoRoute(path: '/saved', builder: (_, _) => const LibraryView()),
    GoRoute(
      path: '/history',
      builder: (_, _) => const LibraryView(history: true),
    ),
    GoRoute(path: '/settings', builder: (_, _) => const SettingsView()),
  ],
);

class MissingDecision extends StatelessWidget {
  const MissingDecision({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: FilledButton(
        onPressed: () => context.go('/'),
        child: const Text('Choose a decision to begin'),
      ),
    ),
  );
}
