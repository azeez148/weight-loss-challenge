class WeightEntry {
  final String id;
  final String userId;
  final String? challengeId;
  final double weight;
  final DateTime date;
  final String? note;

  WeightEntry({
    required this.id,
    required this.userId,
    this.challengeId,
    required this.weight,
    required this.date,
    this.note,
  });

  WeightEntry copyWith({
    String? id,
    String? userId,
    String? challengeId,
    double? weight,
    DateTime? date,
    String? note,
  }) {
    return WeightEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      challengeId: challengeId ?? this.challengeId,
      weight: weight ?? this.weight,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'challengeId': challengeId,
      'weight': weight,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory WeightEntry.fromMap(Map<String, dynamic> map) {
    return WeightEntry(
      id: map['id'] as String,
      userId: map['userId'] as String,
      challengeId: map['challengeId'] as String,
      weight: map['weight'] as double,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
    );
  }
}
