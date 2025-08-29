import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/challenge.dart';

class ChallengeService {
  final _uuid = const Uuid();
  final List<Challenge> _challenges = [];
  final _challengesController = StreamController<List<Challenge>>.broadcast();

  Stream<List<Challenge>> get challengesStream => _challengesController.stream;

  // Get all challenges
  List<Challenge> getAllChallenges() {
    return List.unmodifiable(_challenges);
  }

  // Find a challenge by invite code
  Future<Challenge?> getChallengeByInviteCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _challenges.firstWhere((c) => c.inviteCode.toUpperCase() == code.toUpperCase());
    } catch (e) {
      return null;
    }
  }

  // Get active challenges for a user
  List<Challenge> getActiveChallengesForUser(String userId) {
    return _challenges
        .where((c) => c.isActive && c.participantIds.contains(userId))
        .toList();
  }

  // Create a new challenge
  Future<Challenge> createChallenge({
    required String name,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required String creatorId,
    required ChallengeType type,
    double? weightLossGoal,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final challenge = Challenge(
      id: _uuid.v4(),
      name: name,
      description: description,
      startDate: startDate,
      endDate: endDate,
      weightLossGoal: weightLossGoal,
      creatorId: creatorId,
      participantIds: [creatorId],
      isActive: true,
      type: type,
    );

    _challenges.add(challenge);
    _challengesController.add(_challenges);
    return challenge;
  }

  // Join a challenge
  Future<void> joinChallenge(String challengeId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _challenges.indexWhere((c) => c.id == challengeId);
    if (index == -1) throw Exception('Challenge not found');

    final challenge = _challenges[index];
    if (challenge.participantIds.contains(userId)) {
      throw Exception('Already joined this challenge');
    }

    final updatedChallenge = challenge.copyWith(
      participantIds: [...challenge.participantIds, userId],
    );

    _challenges[index] = updatedChallenge;
    _challengesController.add(_challenges);
  }

  // Leave a challenge
  Future<void> leaveChallenge(String challengeId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _challenges.indexWhere((c) => c.id == challengeId);
    if (index == -1) throw Exception('Challenge not found');

    final challenge = _challenges[index];
    if (!challenge.participantIds.contains(userId)) {
      throw Exception('Not a participant in this challenge');
    }

    if (challenge.creatorId == userId) {
      throw Exception('Creator cannot leave the challenge');
    }

    final updatedChallenge = challenge.copyWith(
      participantIds: challenge.participantIds.where((id) => id != userId).toList(),
    );

    _challenges[index] = updatedChallenge;
    _challengesController.add(_challenges);
  }

  // Add weight entry to a challenge
  Future<void> addWeightEntry({
    required String challengeId,
    required String userId,
    required double weight,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _challenges.indexWhere((c) => c.id == challengeId);
    if (index == -1) throw Exception('Challenge not found');

    final challenge = _challenges[index];
    if (!challenge.participantIds.contains(userId)) {
      throw Exception('Not a participant in this challenge');
    }

    final progress = Map<String, List<double>>.from(challenge.participantProgress);
    if (!progress.containsKey(userId)) {
      progress[userId] = [];
    }
    progress[userId]!.add(weight);

    final updatedChallenge = Challenge(
      id: challenge.id,
      name: challenge.name,
      description: challenge.description,
      startDate: challenge.startDate,
      endDate: challenge.endDate,
      weightLossGoal: challenge.weightLossGoal,
      creatorId: challenge.creatorId,
      participantIds: challenge.participantIds,
      isActive: challenge.isActive,
      type: challenge.type,
      participantProgress: progress,
    );

    _challenges[index] = updatedChallenge;
    _challengesController.add(_challenges);
  }

  // End a challenge
  Future<void> endChallenge(String challengeId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _challenges.indexWhere((c) => c.id == challengeId);
    if (index == -1) throw Exception('Challenge not found');

    final challenge = _challenges[index];
    if (challenge.creatorId != userId) {
      throw Exception('Only the creator can end the challenge');
    }

    final updatedChallenge = challenge.copyWith(isActive: false);
    _challenges[index] = updatedChallenge;
    _challengesController.add(_challenges);
  }

  // Refresh challenges for a user
  Future<void> refreshChallenges(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // In a real app, this would fetch fresh data from the backend
    // For now, we'll just notify listeners to trigger a UI update
    _challengesController.add(_challenges);
  }

  // Clean up resources
  void dispose() {
    _challengesController.close();
  }
}
