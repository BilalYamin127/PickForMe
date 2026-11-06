import 'dart:convert';

import 'package:hive_ce/hive.dart';

import '../models/decision.dart';
import '../models/app_settings.dart';

/// JSON records keep the on-device schema explicit without generated adapters.
class LocalRepository {
  final Box<String> box;
  LocalRepository(this.box);
  List<DecisionList> get lists =>
      _read('lists').map(DecisionList.fromJson).toList();
  List<DecisionResult> get history =>
      _read('history').map(DecisionResult.fromJson).toList();
  AppSettings get settings {
    final raw = box.get('settings');
    return raw == null
        ? const AppSettings()
        : AppSettings.fromJson(jsonDecode(raw));
  }

  List<Map<String, dynamic>> _read(String key) =>
      (jsonDecode(box.get(key, defaultValue: '[]')!) as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
  Future<void> saveLists(List<DecisionList> values) =>
      box.put('lists', jsonEncode(values.map((e) => e.toJson()).toList()));
  Future<void> saveHistory(List<DecisionResult> values) =>
      box.put('history', jsonEncode(values.map((e) => e.toJson()).toList()));
  Future<void> saveSettings(AppSettings value) =>
      box.put('settings', jsonEncode(value.toJson()));
}
