import 'package:uuid/uuid.dart';
import 'package:weight_loss_challenge/models/challenge.dart';
import 'package:weight_loss_challenge/models/user_model.dart';
import 'package:weight_loss_challenge/models/weight_entry.dart';

class MockBackend {
  static final MockBackend _instance = MockBackend._internal();
  factory MockBackend() => _instance;
  MockBackend._internal();

  final _uuid = const Uuid();

  // Data
  final List<Challenge> challenges = [];
  final Map<String, UserModel> users = {};

  // Initialize with some data
  void initialize() {
    if (users.isEmpty) {
      final user1 = UserModel(
        id: 'user1',
        email: 'user1@example.com',
        name: 'Alice',
        startWeight: 80,
        currentWeight: 77,
        targetWeight: 70,
        height: 170,
        lastRecordedDateTime: DateTime.now(),
      );
      final user2 = UserModel(
        id: 'user2',
        email: 'user2@example.com',
        name: 'Bob',
        startWeight: 90,
        currentWeight: 89,
        targetWeight: 80,
        height: 180,
        lastRecordedDateTime: DateTime.now().subtract(const Duration(days: 2)),
      );
      users[user1.id] = user1;
      users[user2.id] = user2;

      final challenge1 = Challenge(
        id: 'challenge1',
        name: '30-Day Weight Loss Challenge',
        description: 'Lose 5kg in 30 days',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        creatorId: user1.id,
        participantIds: [user1.id, user2.id],
        initialParticipantIds: [user1.id, user2.id],
        type: ChallengeType.group,
        weightLossGoal: 5,
        isActive: true,
        isPublic: true,
        joinEndDate: DateTime.now().add(const Duration(days: 7)),
        entryWeightEndDate: DateTime.now().add(const Duration(days: 7)),
        finalWeightEndDate: DateTime.now().add(const Duration(days: 30)),
        participantProgress: {
          user1.id: [
            WeightEntry(
                id: 'w1',
                weight: 80,
                timestamp: DateTime.now().subtract(const Duration(days: 1)),
                approvalStatus: WeightEntryApprovalStatus.approved),
            WeightEntry(
                id: 'w2',
                weight: 78,
                timestamp: DateTime.now().subtract(const Duration(days: 0)),
                approvalStatus: WeightEntryApprovalStatus.approved),
          ],
          user2.id: [
            WeightEntry(
                id: 'w3',
                weight: 90,
                timestamp: DateTime.now().subtract(const Duration(days: 1)),
                approvalStatus: WeightEntryApprovalStatus.approved),
            WeightEntry(
                id: 'w4',
                weight: 89,
                timestamp: DateTime.now(),
                approvalStatus: WeightEntryApprovalStatus.pending),
          ],
        },
      );
      final challenge2 = Challenge(
        id: 'challenge2',
        name: 'Summer Shred',
        description: 'Get ready for summer',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 60)),
        creatorId: user2.id,
        participantIds: [user2.id],
        initialParticipantIds: [user2.id],
        type: ChallengeType.individual,
        weightLossGoal: 8,
        isActive: true,
        isPublic: false,
        joinEndDate: DateTime.now().add(const Duration(days: 10)),
        entryWeightEndDate: DateTime.now().add(const Duration(days: 10)),
        finalWeightEndDate: DateTime.now().add(const Duration(days: 60)),
      );
      challenges.addAll([challenge1, challenge2]);
    }
  }

  Future<void> requestToJoinPublicChallenge(
      String challengeId, String userId) async {
    final challenge = challenges.firstWhere((c) => c.id == challengeId);
    if (challenge.isPublic) {
      challenge.pendingJoinRequests.add(userId);
    }
  }

  Future<List<String>> getPendingJoinRequests(String challengeId) async {
    final challenge = challenges.firstWhere((c) => c.id == challengeId);
    return challenge.pendingJoinRequests;
  }

  Future<void> approveJoinRequest(String challengeId, String userId) async {
    final challenge = challenges.firstWhere((c) => c.id == challengeId);
    challenge.pendingJoinRequests.remove(userId);
    challenge.participantIds.add(userId);
  }

  Future<void> endChallenge(String challengeId, String userId) async {
    final challenge = challenges.firstWhere((c) => c.id == challengeId);
    challenge.endChallengeVotes[userId] = true;

    final voteCount = challenge.endChallengeVotes.length;
    final participantCount = challenge.initialParticipantIds.length;

    if ((voteCount / participantCount) >= 0.3) {
      final index = challenges.indexWhere((c) => c.id == challengeId);
      challenges[index] = challenge.copyWith(isActive: false);
    }
  }

  Future<List<String>> getWinners(String challengeId) async {
    final challenge = challenges.firstWhere((c) => c.id == challengeId);
    final participants = challenge.participantIds;
    final winners = <String>[];

    if (challenge.type == ChallengeType.individual) {
      final participantLosses = <String, double>{};
      for (final userId in participants) {
        final weightLoss = challenge.getWeightLossPercentage(userId);
        if (weightLoss != null) {
          participantLosses[userId] = weightLoss;
        }
      }

      final sortedParticipants = participantLosses.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      for (int i = 0; i < sortedParticipants.length && i < 3; i++) {
        winners.add(sortedParticipants[i].key);
      }
    } else {
      // Group challenge logic.
      // The current implementation assumes a single group per challenge.
      // A possible improvement would be to add support for multiple groups within a challenge.
      double totalStartWeight = 0;
      double totalCurrentWeight = 0;

      for (final userId in participants) {
        final progress = challenge.participantProgress[userId]
            ?.where((e) => e.approvalStatus == WeightEntryApprovalStatus.approved)
            .toList();
        if (progress != null && progress.isNotEmpty) {
          totalStartWeight += progress.first.weight;
          totalCurrentWeight += progress.last.weight;
        }
      }

      if (totalStartWeight > totalCurrentWeight) {
        // Since there is no group ID, we return the creator's ID as the winner.
        winners.add(challenge.creatorId);
      }
    }
    return winners;
  }

  Future<void> approveWeightEntry(String challengeId, String approverUserId, String entryUserId, int entryIndex) async {
    final challenge = challenges.firstWhere((c) => c.id == challengeId);
    if (challenge.participantIds.contains(approverUserId)) {
      final weightEntry = challenge.participantProgress[entryUserId]![entryIndex];
      challenge.participantProgress[entryUserId]![entryIndex] = weightEntry.copyWith(
        approvalStatus: WeightEntryApprovalStatus.approved,
        approvedBy: approverUserId,
      );
    }
  }
}
