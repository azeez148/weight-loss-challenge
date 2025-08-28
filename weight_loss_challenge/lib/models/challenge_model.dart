import 'package:uuid/uuid.dart';

class Challenge {
  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String creatorId;
  final List<String> participantIds;
  final Map<String, double> startWeights;
  final Map<String, double> currentWeights;
  final String inviteCode;
  final bool isActive;

  Challenge({
    String? id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.creatorId,
    this.participantIds = const [],
    this.startWeights = const {},
    this.currentWeights = const {},
    String? inviteCode,
    this.isActive = true,
  }) : id = id ?? const Uuid().v4(),
       inviteCode = inviteCode ?? const Uuid().v4().substring(0, 6).toUpperCase();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'creatorId': creatorId,
      'participantIds': participantIds,
      'startWeights': startWeights,
      'currentWeights': currentWeights,
      'inviteCode': inviteCode,
      'isActive': isActive,
    };
  }

  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      creatorId: map['creatorId'] as String,
      participantIds: List<String>.from(map['participantIds'] ?? []),
      startWeights: Map<String, double>.from(map['startWeights'] ?? {}),
      currentWeights: Map<String, double>.from(map['currentWeights'] ?? {}),
      inviteCode: map['inviteCode'] as String,
      isActive: map['isActive'] as bool,
    );
  }

  Challenge copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? creatorId,
    List<String>? participantIds,
    Map<String, double>? startWeights,
    Map<String, double>? currentWeights,
    String? inviteCode,
    bool? isActive,
  }) {
    return Challenge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      creatorId: creatorId ?? this.creatorId,
      participantIds: participantIds ?? this.participantIds,
      startWeights: startWeights ?? this.startWeights,
      currentWeights: currentWeights ?? this.currentWeights,
      inviteCode: inviteCode ?? this.inviteCode,
      isActive: isActive ?? this.isActive,
    );
  }
}
