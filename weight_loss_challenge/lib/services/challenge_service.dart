import 'dart:async';
import 'package:weight_loss_challenge/api/challenge_api.dart';
import '../models/challenge.dart';

class ChallengeService {
  final ChallengeApi _api = ChallengeApi();
  List<Challenge> _challenges = [];
  final _challengesController = StreamController<List<Challenge>>.broadcast();

  ChallengeService() {
    _api.getAllChallenges().then((challenges) {
      _challenges = challenges;
      _challengesController.add(_challenges);
    });
  }

  Stream<List<Challenge>> get challengesStream => _challengesController.stream;

  List<Challenge> getAllChallenges() {
    return List.unmodifiable(_challenges);
  }

  Future<Challenge?> getChallengeByInviteCode(String code) async {
    return await _api.getChallengeByInviteCode(code);
  }

  List<Challenge> getActiveChallengesForUser(String userId) {
    return _challenges
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
  }) async {
    final challenge = await _api.createChallenge(
      name: name,
      description: description,
      startDate: startDate,
      endDate: endDate,
      creatorId: creatorId,
      type: type,
      weightLossGoal: weightLossGoal,
    );
    _challenges.add(challenge);
    _challengesController.add(_challenges);
    return challenge;
  }

  Future<void> joinChallenge(String challengeId, String userId) async {
    await _api.joinChallenge(challengeId, userId);
    await refreshChallenges(userId);
  }

  Future<void> leaveChallenge(String challengeId, String userId) async {
    await _api.leaveChallenge(challengeId, userId);
    await refreshChallenges(userId);
  }

  Future<void> addWeightEntry({
    required String challengeId,
    required String userId,
    required double weight,
  }) async {
    await _api.addWeightEntry(
      challengeId: challengeId,
      userId: userId,
      weight: weight,
    );
    await refreshChallenges(userId);
  }

  Future<void> refreshChallenges(String userId) async {
    _challenges = await _api.getAllChallenges();
    _challengesController.add(_challenges);
  }

  void dispose() {
    _challengesController.close();
  }
}
