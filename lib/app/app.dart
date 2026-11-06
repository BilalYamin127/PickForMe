import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/decisions/view_models/app_view_model.dart';
import 'router.dart';
import 'theme.dart';

class PickForMeApp extends ConsumerWidget {
  const PickForMeApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(
      appViewModelProvider.select((s) => s.settings.themeMode),
    );
    return MaterialApp.router(
      title: 'PickForMe',
      debugShowCheckedModeBanner: false,
      theme: appTheme(Brightness.light),
      darkTheme: appTheme(Brightness.dark),
      themeMode: ThemeMode.values.firstWhere(
        (e) => e.name == mode,
        orElse: () => ThemeMode.system,
      ),
      routerConfig: appRouter,
    );
  }
}
