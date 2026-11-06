import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'data/repositories/local_repository.dart';
import 'features/decisions/view_models/app_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Hive.initFlutter();
    final box = await Hive.openBox<String>('pickforme_v1');
    runApp(
      ProviderScope(
        overrides: [repositoryProvider.overrideWithValue(LocalRepository(box))],
        child: const PickForMeApp(),
      ),
    );
  } catch (_) {
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'PickForMe could not open local storage. Free some device storage and restart the app.',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
