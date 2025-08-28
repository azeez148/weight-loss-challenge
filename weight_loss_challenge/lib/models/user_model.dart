class UserModel {
  final String id;
  final String email;
  final String name;
  double currentWeight;
  final double startWeight;
  final double targetWeight;
  final List<String> challengeIds;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.currentWeight,
    required this.startWeight,
    required this.targetWeight,
    this.challengeIds = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'currentWeight': currentWeight,
      'startWeight': startWeight,
      'targetWeight': targetWeight,
      'challengeIds': challengeIds,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      currentWeight: (map['currentWeight'] ?? 0.0).toDouble(),
      startWeight: (map['startWeight'] ?? 0.0).toDouble(),
      targetWeight: (map['targetWeight'] ?? 0.0).toDouble(),
      challengeIds: List<String>.from(map['challengeIds'] ?? []),
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    double? currentWeight,
    double? startWeight,
    double? targetWeight,
    List<String>? challengeIds,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      currentWeight: currentWeight ?? this.currentWeight,
      startWeight: startWeight ?? this.startWeight,
      targetWeight: targetWeight ?? this.targetWeight,
      challengeIds: challengeIds ?? this.challengeIds,
    );
  }
}
