import 'package:flutter/material.dart';
import '../models/challenge.dart';
import '../models/user_model.dart';
import '../models/weight_entry.dart';
import '../services/auth_service.dart';
import '../services/challenge_service.dart';
import '../services/profile_service.dart';
import '../services/weight_service.dart';

class AppState extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ChallengeService _challengeService = ChallengeService();
  final WeightService _weightService = WeightService();
  final ProfileService _profileService = ProfileService();

  MockUser? get currentUser => _authService.currentUser;
  UserModel? get userProfile => currentUser != null
      ? _profileService.getProfile(currentUser!.id)
      : null;

  UserModel? getUserProfile(String userId) => _profileService.getProfile(userId);

  List<Challenge> get userChallenges => currentUser != null
      ? _challengeService.getActiveChallengesForUser(currentUser!.id)
      : [];
      
  List<Challenge> get allChallenges => _challengeService.getAllChallenges();

  List<WeightEntry> get userWeightEntries => currentUser != null
      ? _weightService.getWeightEntriesForUser(currentUser!.id)
      : [];

  Stream<MockUser?> get authStateChanges => _authService.authStateChanges;

  // Challenge methods
  Future<Challenge?> getChallengeByInviteCode(String code) async {
    return await _challengeService.getChallengeByInviteCode(code);
  }

  Future<void> joinChallenge(String challengeId) async {
    if (currentUser == null) throw Exception('No user logged in');
    await _challengeService.joinChallenge(challengeId, currentUser!.id);
    notifyListeners();
  }

  // Authentication methods
  Future<MockUser?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final user = await _authService.createUserWithEmailAndPassword(
      email: email,
      password: password,
      displayName: name,
    );
    
    if (user != null) {
      await _profileService.updateProfile(
        userId: user.id,
        email: user.email,
        name: user.displayName,
      );
      notifyListeners();
    }
    return user;
  }

  Future<MockUser?> login(String email, String password) async {
    final user = await _authService.signInWithEmailAndPassword(email, password);
    if (user != null) {
      // Initialize user profile if it doesn't exist
      final profile = _profileService.getProfile(user.id);
      if (profile == null) {
        await _profileService.updateProfile(
          userId: user.id,
          email: user.email,
          name: user.displayName,
        );
      }
      await _weightService.fetchWeightEntriesForUser(user.id);
      await refreshChallenges();
    }
    notifyListeners();
    return user;
  }

  Future<void> logout() async {
    await _authService.signOut();
    notifyListeners();
  }

  // Challenge methods
  Future<Challenge> createChallenge({
    required String name,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required ChallengeType type,
    double? weightLossGoal,
    required bool isPublic,
    required DateTime joinEndDate,
    required DateTime entryWeightEndDate,
    required DateTime finalWeightEndDate,
  }) async {
    if (currentUser == null) throw Exception('Not authenticated');
    final challenge = await _challengeService.createChallenge(
      name: name,
      description: description,
      startDate: startDate,
      endDate: endDate,
      type: type,
      weightLossGoal: weightLossGoal,
      creatorId: currentUser!.id,
      isPublic: isPublic,
      joinEndDate: joinEndDate,
      entryWeightEndDate: entryWeightEndDate,
      finalWeightEndDate: finalWeightEndDate,
    );
    notifyListeners();
    return challenge;
  }

  Future<void> joinChallengeWithInviteCode(String code) async {
    if (currentUser == null) throw Exception('Not authenticated');
    final challenge = await _challengeService.getChallengeByInviteCode(code);
    if (challenge == null) {
      throw Exception('Challenge not found with that invite code.');
    }
    await joinChallenge(challenge.id);
  }

  Future<void> leaveChallenge(String challengeId) async {
    if (currentUser == null) throw Exception('Not authenticated');
    await _challengeService.leaveChallenge(challengeId, currentUser!.id);
    notifyListeners();
  }

  Future<void> requestToJoinPublicChallenge(
      String challengeId, String userId) async {
    await _challengeService.requestToJoinPublicChallenge(challengeId, userId);
    notifyListeners();
  }

  Future<List<String>> getPendingJoinRequests(String challengeId) async {
    return await _challengeService.getPendingJoinRequests(challengeId);
  }

  Future<void> approveJoinRequest(String challengeId, String userId) async {
    await _challengeService.approveJoinRequest(challengeId, userId);
    notifyListeners();
  }

  Future<void> approveWeightEntry(
      String challengeId, String entryUserId, int entryIndex) async {
    if (currentUser == null) throw Exception('Not authenticated');
    await _challengeService.approveWeightEntry(
        challengeId, currentUser!.id, entryUserId, entryIndex);
    notifyListeners();
  }

  Future<void> endChallenge(String challengeId) async {
    if (currentUser == null) throw Exception('Not authenticated');
    await _challengeService.endChallenge(challengeId, currentUser!.id);
    notifyListeners();
  }

  // Weight tracking methods
  Future<WeightEntry> addWeightEntry({
    required String challengeId,
    required double weight,
    String? note,
  }) async {
    if (currentUser == null) throw Exception('Not authenticated');

    // Add weight entry to the challenge
    final entry = await _challengeService.addWeightEntry(
      challengeId: challengeId,
      userId: currentUser!.id,
      weight: weight,
    );

    notifyListeners();
    return entry;
  }

  Future<void> deleteWeightEntry(String weightEntryId) async {
    if (currentUser == null) throw Exception('Not authenticated');
    await _weightService.deleteWeightEntry(currentUser!.id, weightEntryId);
    notifyListeners();
  }

  // Profile methods
  Future<UserModel> updateProfile({
    String? name,
    double? targetWeight,
    double? currentWeight,
    double? height,
    DateTime? lastRecordedDateTime,
  }) async {
    if (currentUser == null) throw Exception('Not authenticated');
    final profile = await _profileService.updateProfile(
      userId: currentUser!.id,
      email: currentUser!.email,
      name: name,
      targetWeight: targetWeight,
      currentWeight: currentWeight,
      height: height,
      lastRecordedDateTime: lastRecordedDateTime,
    );
    notifyListeners();
    return profile;
  }

  Map<String, dynamic> get userStatistics {
    if (currentUser == null) {
      return {
        'initialWeight': 0.0,
        'currentWeight': 0.0,
        'totalLoss': 0.0,
        'averageLossPerWeek': 0.0,
      };
    }
    return _weightService.getUserStatistics(currentUser!.id);
  }

  Future<void> refreshChallenges() async {
    if (currentUser == null) return;
    await _challengeService.refreshChallenges(currentUser!.id);
    notifyListeners();
  }

  @override
  void dispose() {
    _authService.dispose();
    _challengeService.dispose();
    _weightService.dispose();
    _profileService.dispose();
    super.dispose();
  }
}
