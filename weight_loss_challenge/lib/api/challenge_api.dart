import 'package:weight_loss_challenge/api/mock_backend.dart';
import 'package:weight_loss_challenge/models/challenge.dart';
import 'package:weight_loss_challenge/models/weight_entry.dart';

class ChallengeApi {
  final MockBackend _backend = MockBackend();

  Future<List<Challenge>> getAllChallenges() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _backend.challenges;
  }

  Future<Challenge?> getChallengeByInviteCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _backend.challenges
          .firstWhere((c) => c.inviteCode.toUpperCase() == code.toUpperCase());
    } catch (e) {
      return null;
    }
  }

  Future<List<Challenge>> getActiveChallengesForUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _backend.challenges
        .where((c) => c.isActive && c.participantIds.contains(userId))
        .toList();
  }

  Future<Challenge> createChallenge({
    required String name,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required String creatorId,
    required ChallengeType type,
    double? weightLossGoal,
    required bool isPublic,
    required DateTime joinEndDate,
    required DateTime entryWeightEndDate,
    required DateTime finalWeightEndDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final challenge = Challenge(
      id: _backend.challenges.length.toString(),
      name: name,
      description: description,
      startDate: startDate,
      endDate: endDate,
      weightLossGoal: weightLossGoal,
      creatorId: creatorId,
      participantIds: [creatorId],
      initialParticipantIds: [creatorId],
      isActive: true,
      type: type,
      isPublic: isPublic,
      joinEndDate: joinEndDate,
      entryWeightEndDate: entryWeightEndDate,
      finalWeightEndDate: finalWeightEndDate,
    );
    _backend.challenges.add(challenge);
    return challenge;
  }

  Future<void> joinChallenge(String challengeId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index =
        _backend.challenges.indexWhere((c) => c.id == challengeId);
    if (index == -1) throw Exception('Challenge not found');

    final challenge = _backend.challenges[index];
    if (challenge.participantIds.contains(userId)) {
      throw Exception('Already joined this challenge');
    }

    final updatedChallenge = challenge.copyWith(
      participantIds: [...challenge.participantIds, userId],
    );
    _backend.challenges[index] = updatedChallenge;
  }

  Future<void> leaveChallenge(String challengeId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index =
        _backend.challenges.indexWhere((c) => c.id == challengeId);
    if (index == -1) throw Exception('Challenge not found');

    final challenge = _backend.challenges[index];
    if (!challenge.participantIds.contains(userId)) {
      throw Exception('Not a participant in this challenge');
    }

    if (challenge.creatorId == userId) {
      throw Exception('Creator cannot leave the challenge');
    }

    final updatedChallenge = challenge.copyWith(
      participantIds:
          challenge.participantIds.where((id) => id != userId).toList(),
    );
    _backend.challenges[index] = updatedChallenge;
  }

  Future<WeightEntry> addWeightEntry({
    required String challengeId,
    required String userId,
    required double weight,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index =
        _backend.challenges.indexWhere((c) => c.id == challengeId);
    if (index == -1) throw Exception('Challenge not found');

    final challenge = _backend.challenges[index];
    if (!challenge.participantIds.contains(userId)) {
      throw Exception('Not a participant in this challenge');
    }

    final progress =
        Map<String, List<WeightEntry>>.from(challenge.participantProgress);
    if (!progress.containsKey(userId)) {
      progress[userId] = [];
    }
    final newEntry = WeightEntry(weight: weight, timestamp: DateTime.now());
    progress[userId]!.add(newEntry);

    final updatedChallenge = challenge.copyWith(
      participantProgress: progress,
    );
    _backend.challenges[index] = updatedChallenge;
    return newEntry;
  }

  Future<void> requestToJoinPublicChallenge(String challengeId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _backend.requestToJoinPublicChallenge(challengeId, userId);
  }

  Future<List<String>> getPendingJoinRequests(String challengeId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _backend.getPendingJoinRequests(challengeId);
  }

  Future<void> approveJoinRequest(String challengeId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _backend.approveJoinRequest(challengeId, userId);
  }

  Future<void> endChallenge(String challengeId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _backend.endChallenge(challengeId, userId);
  }

  Future<List<String>> getWinners(String challengeId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _backend.getWinners(challengeId);
  }

  Future<void> approveWeightEntry(String challengeId, String approverUserId, String entryUserId, int entryIndex) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _backend.approveWeightEntry(challengeId, approverUserId, entryUserId, entryIndex);
  }
}
