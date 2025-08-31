import 'package:uuid/uuid.dart';
import 'package:weight_loss_challenge/models/weight_entry.dart';

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
  final Map<String, List<WeightEntry>>
      participantProgress; // Track each participant's weight entries
  final String creatorId;
  final List<String> participantIds;
  final bool isActive;
  final ChallengeType type;
  final String inviteCode;
  final bool isPublic;
  final DateTime joinEndDate;
  final DateTime entryWeightEndDate;
  final DateTime finalWeightEndDate;
  final Map<String, bool> endChallengeVotes;
  final List<String> pendingJoinRequests;
  final List<String> initialParticipantIds;

  double get progressPercentage {
    if (weightLossGoal == null || weightLossGoal! <= 0) return 0.0;
    final totalWeightLoss = participantProgress.values
        .expand((entries) => entries)
        .where((entry) => entry.approvalStatus == WeightEntryApprovalStatus.approved)
        .fold<double>(0.0, (sum, entry) => sum + entry.weight);
    return (totalWeightLoss / weightLossGoal!) * 100;
  }

  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

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
    Map<String, List<WeightEntry>>? participantProgress,
    String? inviteCode,
    this.isPublic = false,
    required this.joinEndDate,
    required this.entryWeightEndDate,
    required this.finalWeightEndDate,
    Map<String, bool>? endChallengeVotes,
    List<String>? pendingJoinRequests,
    List<String>? initialParticipantIds,
  })  : id = id ?? const Uuid().v4(),
        participantProgress = participantProgress ?? {},
        endChallengeVotes = endChallengeVotes ?? {},
        pendingJoinRequests = pendingJoinRequests ?? [],
        initialParticipantIds = initialParticipantIds ?? [],
        inviteCode =
            inviteCode ?? const Uuid().v4().substring(0, 6).toUpperCase();

  Challenge copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    double? weightLossGoal,
    Map<String, List<WeightEntry>>? participantProgress,
    String? creatorId,
    List<String>? participantIds,
    bool? isActive,
    ChallengeType? type,
    String? inviteCode,
    bool? isPublic,
    DateTime? joinEndDate,
    DateTime? entryWeightEndDate,
    DateTime? finalWeightEndDate,
    Map<String, bool>? endChallengeVotes,
    List<String>? pendingJoinRequests,
    List<String>? initialParticipantIds,
  }) {
    return Challenge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      weightLossGoal: weightLossGoal ?? this.weightLossGoal,
      participantProgress: participantProgress ?? this.participantProgress,
      creatorId: creatorId ?? this.creatorId,
      participantIds: participantIds ?? this.participantIds,
      isActive: isActive ?? this.isActive,
      type: type ?? this.type,
      inviteCode: inviteCode ?? this.inviteCode,
      isPublic: isPublic ?? this.isPublic,
      joinEndDate: joinEndDate ?? this.joinEndDate,
      entryWeightEndDate: entryWeightEndDate ?? this.entryWeightEndDate,
      finalWeightEndDate: finalWeightEndDate ?? this.finalWeightEndDate,
      endChallengeVotes: endChallengeVotes ?? this.endChallengeVotes,
      pendingJoinRequests: pendingJoinRequests ?? this.pendingJoinRequests,
      initialParticipantIds:
          initialParticipantIds ?? this.initialParticipantIds,
    );
  }

  double? getWeightLoss(String userId) {
    final progress = participantProgress[userId]
        ?.where((e) => e.approvalStatus == WeightEntryApprovalStatus.approved)
        .toList();
    if (progress == null || progress.length < 2) return null;
    return progress.first.weight - progress.last.weight;
  }

  double? getWeightLossPercentage(String userId) {
    final progress = participantProgress[userId]
        ?.where((e) => e.approvalStatus == WeightEntryApprovalStatus.approved)
        .toList();
    if (progress == null || progress.length < 2) return null;
    final startWeight = progress.first.weight;
    final currentWeight = progress.last.weight;
    return ((startWeight - currentWeight) / startWeight) * 100;
  }

  bool isReadOnly(String userId) {
    if (DateTime.now().isAfter(entryWeightEndDate)) {
      final progress = participantProgress[userId] ?? [];
      if (progress.isEmpty) {
        return true;
      }
    }
    return false;
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
      'participantProgress': participantProgress
          .map((key, value) => MapEntry(key, value.map((e) => e.toMap()).toList())),
      'inviteCode': inviteCode,
      'isPublic': isPublic,
      'joinEndDate': joinEndDate.toIso8601String(),
      'entryWeightEndDate': entryWeightEndDate.toIso8601String(),
      'finalWeightEndDate': finalWeightEndDate.toIso8601String(),
      'endChallengeVotes': endChallengeVotes,
      'pendingJoinRequests': pendingJoinRequests,
      'initialParticipantIds': initialParticipantIds,
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
      participantProgress:
          (map['participantProgress'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(
            key,
            (value as List)
                .map((e) => WeightEntry.fromMap(e as Map<String, dynamic>))
                .toList()),
      ),
      inviteCode: map['inviteCode'] as String?,
      isPublic: map['isPublic'] as bool,
      joinEndDate: DateTime.parse(map['joinEndDate'] as String),
      entryWeightEndDate: DateTime.parse(map['entryWeightEndDate'] as String),
      finalWeightEndDate: DateTime.parse(map['finalWeightEndDate'] as String),
      endChallengeVotes: (map['endChallengeVotes'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, value as bool),
      ),
      pendingJoinRequests: List<String>.from(map['pendingJoinRequests'] ?? []),
      initialParticipantIds:
          List<String>.from(map['initialParticipantIds'] ?? []),
    );
  }
}
