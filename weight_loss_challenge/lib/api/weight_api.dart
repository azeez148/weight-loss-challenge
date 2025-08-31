import 'package:weight_loss_challenge/api/mock_backend.dart';
import 'package:weight_loss_challenge/models/weight_entry.dart';

class WeightApi {
  final MockBackend _backend = MockBackend();

  Future<List<WeightEntry>> getWeightEntriesForUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final allEntries = <WeightEntry>[];
    for (final challenge in _backend.challenges) {
      if (challenge.participantProgress.containsKey(userId)) {
        allEntries.addAll(challenge.participantProgress[userId]!);
      }
    }
    return allEntries;
  }

  Future<WeightEntry> addWeightEntry({
    required String userId,
    required double weight,
    String? challengeId,
    String? note, // Note is not in the model, but we keep it for now
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final entry = WeightEntry(
      weight: weight,
      timestamp: DateTime.now(),
    );

    if (challengeId != null) {
      final challenge =
          _backend.challenges.firstWhere((c) => c.id == challengeId);
      if (challenge.participantProgress[userId] == null) {
        challenge.participantProgress[userId] = [];
      }
      challenge.participantProgress[userId]!.add(entry);
    }

    return entry;
  }

  Future<void> deleteWeightEntry(String userId, String weightEntryId) async {
    for (final challenge in _backend.challenges) {
      if (challenge.participantProgress.containsKey(userId)) {
        challenge.participantProgress[userId]!
            .removeWhere((e) => e.id == weightEntryId);
      }
    }
  }
}
