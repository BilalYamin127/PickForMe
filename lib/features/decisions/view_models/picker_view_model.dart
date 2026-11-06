import 'package:flutter/foundation.dart';

import '../../../core/services/random_service.dart';
import '../../../data/models/decision.dart';
import 'app_view_model.dart';

class PickerViewModel extends ChangeNotifier {
  final DecisionList decision;
  final RandomService random;
  SelectionMode mode = SelectionMode.wheel;
  int? winner;
  bool busy = false;
  double rotation = 0;
  PickerViewModel(this.decision, {RandomService? random})
    : random = random ?? RandomService();
  double begin() {
    winner = random.select(decision.options.length);
    busy = true;
    notifyListeners();
    return RandomService.targetRotation(
      rotation,
      winner!,
      decision.options.length,
    );
  }

  DecisionResult finish(double finalRotation, {required bool saved}) {
    rotation = finalRotation;
    busy = false;
    notifyListeners();
    return DecisionResult(
      id: newId(),
      decisionListId: saved ? decision.id : null,
      decisionTitle: decision.title,
      selectedOption: decision.options[winner!],
      selectionMode: mode,
      createdAt: DateTime.now(),
    );
  }

  void changeMode(SelectionMode value) {
    if (busy) return;
    mode = value;
    notifyListeners();
  }
}
