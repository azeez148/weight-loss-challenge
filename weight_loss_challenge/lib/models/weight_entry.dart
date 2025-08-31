import 'package:uuid/uuid.dart';

enum WeightEntryApprovalStatus {
  pending,
  approved,
  rejected,
}

class WeightEntry {
  final String id;
  final double weight;
  final DateTime timestamp;
  final WeightEntryApprovalStatus approvalStatus;
  final String? approvedBy; // userId of the approver

  WeightEntry({
    String? id,
    required this.weight,
    required this.timestamp,
    this.approvalStatus = WeightEntryApprovalStatus.pending,
    this.approvedBy,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weight': weight,
      'timestamp': timestamp.toIso8601String(),
      'approvalStatus': approvalStatus.toString().split('.').last,
      'approvedBy': approvedBy,
    };
  }

  factory WeightEntry.fromMap(Map<String, dynamic> map) {
    return WeightEntry(
      id: map['id'],
      weight: (map['weight'] ?? 0.0).toDouble(),
      timestamp: DateTime.parse(map['timestamp']),
      approvalStatus: WeightEntryApprovalStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['approvalStatus'],
        orElse: () => WeightEntryApprovalStatus.pending,
      ),
      approvedBy: map['approvedBy'],
    );
  }

  WeightEntry copyWith({
    String? id,
    double? weight,
    DateTime? timestamp,
    WeightEntryApprovalStatus? approvalStatus,
    String? approvedBy,
  }) {
    return WeightEntry(
      id: id ?? this.id,
      weight: weight ?? this.weight,
      timestamp: timestamp ?? this.timestamp,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      approvedBy: approvedBy ?? this.approvedBy,
    );
  }
}
