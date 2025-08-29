import 'package:weight_loss_challenge/api/mock_backend.dart';
import 'package:weight_loss_challenge/models/weight_entry.dart';

class WeightApi {
  final MockBackend _backend = MockBackend();

  Future<List<WeightEntry>> getWeightEntriesForUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _backend.weightEntries[userId] ?? [];
  }

  Future<WeightEntry> addWeightEntry({
    required String userId,
    required double weight,
    String? challengeId,
    String? note,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final entry = WeightEntry(
      id: _backend.weightEntries[userId]?.length.toString() ?? '0',
      userId: userId,
      weight: weight,
      date: DateTime.now(),
      challengeId: challengeId,
      note: note,
    );
    if (_backend.weightEntries[userId] == null) {
      _backend.weightEntries[userId] = [];
    }
    _backend.weightEntries[userId]!.add(entry);
    return entry;
  }

  Future<void> deleteWeightEntry(String userId, String entryId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _backend.weightEntries[userId]?.removeWhere((entry) => entry.id == entryId);
  }
}
