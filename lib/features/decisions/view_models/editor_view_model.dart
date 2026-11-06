import 'package:flutter/foundation.dart';

import '../../../data/models/decision.dart';
import 'app_view_model.dart';

class EditorViewModel extends ChangeNotifier {
  final DecisionList? original;
  String title;
  final List<String> options;
  EditorViewModel(this.original)
    : title = original?.title ?? '',
      options = [...?original?.options] {
    if (options.isEmpty) options.addAll(['', '']);
  }
  void add() {
    options.add('');
    notifyListeners();
  }

  void remove(int index) {
    options.removeAt(index);
    notifyListeners();
  }

  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    options.insert(newIndex, options.removeAt(oldIndex));
    notifyListeners();
  }

  DecisionList? validate() {
    final clean = options
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (title.trim().isEmpty || clean.length < 2) return null;
    final now = DateTime.now();
    return DecisionList(
      id: original?.id ?? newId(),
      title: title.trim(),
      options: clean,
      createdAt: original?.createdAt ?? now,
      updatedAt: now,
    );
  }
}
