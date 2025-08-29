import 'package:uuid/uuid.dart';

enum ChallengeType {
  individual,
  group,
}

class Challenge {
  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final double? weightLossGoal; // Optional weight loss goal
  final Map<String, List<double>> participantProgress; // Track each participant's weight entries
  final String creatorId;
  final List<String> participantIds;
  final bool isActive;
  final ChallengeType type;
  final String inviteCode;

  Challenge({
    String? id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.creatorId,
    required this.participantIds,
    required this.isActive,
    required this.type,
    this.weightLossGoal,
    Map<String, List<double>>? participantProgress,
    String? inviteCode,
  })  : id = id ?? const Uuid().v4(),
        participantProgress = participantProgress ?? {},
        inviteCode =
            inviteCode ?? const Uuid().v4().substring(0, 6).toUpperCase();

  Challenge copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    double? weightLossGoal,
    String? creatorId,
    List<String>? participantIds,
    bool? isActive,
    ChallengeType? type,
    String? inviteCode,
  }) {
    return Challenge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      weightLossGoal: weightLossGoal ?? this.weightLossGoal,
      creatorId: creatorId ?? this.creatorId,
      participantIds: participantIds ?? this.participantIds,
      isActive: isActive ?? this.isActive,
      type: type ?? this.type,
      inviteCode: inviteCode ?? this.inviteCode,
    );
  }

  double? getWeightLoss(String userId) {
    final progress = participantProgress[userId];
    if (progress == null || progress.length < 2) return null;
    return progress.first - progress.last;
  }

  double? getWeightLossPercentage(String userId) {
    final progress = participantProgress[userId];
    if (progress == null || progress.length < 2) return null;
    final startWeight = progress.first;
    final currentWeight = progress.last;
    return ((startWeight - currentWeight) / startWeight) * 100;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'weightLossGoal': weightLossGoal,
      'creatorId': creatorId,
      'participantIds': participantIds,
      'isActive': isActive,
      'type': type.toString().split('.').last,
      'participantProgress': participantProgress,
      'inviteCode': inviteCode,
    };
  }

  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      weightLossGoal: map['weightLossGoal'] as double?,
      creatorId: map['creatorId'] as String,
      participantIds: List<String>.from(map['participantIds'] as List),
      isActive: map['isActive'] as bool,
      type: ChallengeType.values.firstWhere(
        (e) => e.toString().split('.').last == (map['type'] as String),
        orElse: () => ChallengeType.individual,
      ),
      participantProgress: (map['participantProgress'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, List<double>.from(value as List)),
      ),
      inviteCode: map['inviteCode'] as String?,
    );
  }
}
