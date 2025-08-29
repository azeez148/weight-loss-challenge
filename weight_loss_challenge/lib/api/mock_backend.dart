import 'package:uuid/uuid.dart';
import 'package:weight_loss_challenge/models/challenge.dart';
import 'package:weight_loss_challenge/models/user_profile.dart';
import 'package:weight_loss_challenge/models/weight_entry.dart';
import 'package:weight_loss_challenge/services/auth_service.dart';

class MockBackend {
  static final MockBackend _instance = MockBackend._internal();
  factory MockBackend() => _instance;
  MockBackend._internal();

  final _uuid = const Uuid();

  // Data
  final List<Challenge> challenges = [];
  final Map<String, UserProfile> profiles = {};
  final Map<String, List<WeightEntry>> weightEntries = {};
  final List<MockUser> users = [];

  // Initialize with some data
  void initialize() {
    if (users.isEmpty) {
      final user1 = MockUser(
        id: 'user1',
        email: 'user1@example.com',
        displayName: 'Alice',
      );
      final user2 = MockUser(
        id: 'user2',
        email: 'user2@example.com',
        displayName: 'Bob',
      );
      users.addAll([user1, user2]);

      profiles[user1.id] = UserProfile(
        id: user1.id,
        email: user1.email,
        displayName: user1.displayName,
        startWeight: 80,
        currentWeight: 80,
        targetWeight: 70,
        height: 170,
      );
      profiles[user2.id] = UserProfile(
        id: user2.id,
        email: user2.email,
        displayName: user2.displayName,
        startWeight: 90,
        currentWeight: 90,
        targetWeight: 80,
        height: 180,
      );

      final challenge1 = Challenge(
        id: 'challenge1',
        name: '30-Day Weight Loss Challenge',
        description: 'Lose 5kg in 30 days',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        creatorId: user1.id,
        participantIds: [user1.id, user2.id],
        type: ChallengeType.group,
        weightLossGoal: 5,
        isActive: true,
        participantProgress: {
          user1.id: [80, 78, 77],
          user2.id: [90, 89],
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
        type: ChallengeType.group,
        weightLossGoal: 8,
        isActive: true,
      );
      challenges.addAll([challenge1, challenge2]);

      weightEntries[user1.id] = [
        WeightEntry(id: 'w1', userId: user1.id, weight: 80, date: DateTime.now().subtract(const Duration(days: 10))),
        WeightEntry(id: 'w2', userId: user1.id, weight: 78, date: DateTime.now().subtract(const Duration(days: 5))),
        WeightEntry(id: 'w3', userId: user1.id, weight: 77, date: DateTime.now()),
      ];
      weightEntries[user2.id] = [
        WeightEntry(id: 'w4', userId: user2.id, weight: 90, date: DateTime.now().subtract(const Duration(days: 8))),
        WeightEntry(id: 'w5', userId: user2.id, weight: 89, date: DateTime.now().subtract(const Duration(days: 2))),
      ];
    }
  }
}
