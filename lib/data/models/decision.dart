enum SelectionMode { wheel, list }

class DecisionList {
  final String id, title;
  final List<String> options;
  final DateTime createdAt, updatedAt;
  DecisionList({
    required this.id,
    required this.title,
    required List<String> options,
    required this.createdAt,
    required this.updatedAt,
  }) : options = List.unmodifiable(options);
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'options': options,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
  factory DecisionList.fromJson(Map<String, dynamic> j) => DecisionList(
    id: j['id'],
    title: j['title'],
    options: List<String>.from(j['options']),
    createdAt: DateTime.parse(j['createdAt']),
    updatedAt: DateTime.parse(j['updatedAt']),
  );
}

class DecisionResult {
  final String id, decisionTitle, selectedOption;
  final String? decisionListId;
  final SelectionMode selectionMode;
  final DateTime createdAt;
  const DecisionResult({
    required this.id,
    this.decisionListId,
    required this.decisionTitle,
    required this.selectedOption,
    required this.selectionMode,
    required this.createdAt,
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'decisionListId': decisionListId,
    'decisionTitle': decisionTitle,
    'selectedOption': selectedOption,
    'selectionMode': selectionMode.name,
    'createdAt': createdAt.toIso8601String(),
  };
  factory DecisionResult.fromJson(Map<String, dynamic> j) => DecisionResult(
    id: j['id'],
    decisionListId: j['decisionListId'],
    decisionTitle: j['decisionTitle'],
    selectedOption: j['selectedOption'],
    selectionMode: SelectionMode.values.byName(j['selectionMode']),
    createdAt: DateTime.parse(j['createdAt']),
  );
}
