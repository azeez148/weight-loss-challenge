import 'dart:async';
import 'package:weight_loss_challenge/api/weight_api.dart';
import '../models/weight_entry.dart';

class WeightService {
  final WeightApi _api = WeightApi();
  final Map<String, List<WeightEntry>> _weightEntries = {};
  final _weightEntriesController =
      StreamController<List<WeightEntry>>.broadcast();

  Stream<List<WeightEntry>> getWeightEntriesStream(String userId) {
    return _weightEntriesController.stream.map(
        (entries) => entries.where((entry) => entry.userId == userId).toList());
  }

  List<WeightEntry> getWeightEntriesForUser(String userId) {
    return List.unmodifiable(_weightEntries[userId] ?? []);
  }

  Future<WeightEntry> addWeightEntry({
    required String userId,
    required double weight,
    String? challengeId,
  }) async {
    final entry = await _api.addWeightEntry(
      userId: userId,
      weight: weight,
      challengeId: challengeId,
    );
    if (!_weightEntries.containsKey(userId)) {
      _weightEntries[userId] = [];
    }
    _weightEntries[userId]!.add(entry);
    _notifyListeners();
    return entry;
  }

  Future<void> deleteWeightEntry(String userId, String entryId) async {
    await _api.deleteWeightEntry(userId, entryId);
    _weightEntries[userId]?.removeWhere((entry) => entry.id == entryId);
    _notifyListeners();
  }

  Map<String, dynamic> getUserStatistics(String userId) {
    final entries = _weightEntries[userId] ?? [];
    if (entries.isEmpty) {
      return {
        'initialWeight': 0.0,
        'currentWeight': 0.0,
        'totalLoss': 0.0,
        'averageLossPerWeek': 0.0,
      };
    }

    final sortedEntries = List<WeightEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    final initialWeight = sortedEntries.first.weight;
    final currentWeight = sortedEntries.last.weight;
    final totalLoss = initialWeight - currentWeight;

    final weeks = sortedEntries.last.date
            .difference(sortedEntries.first.date)
            .inDays /
        7;
    final averageLossPerWeek = weeks > 0 ? totalLoss / weeks : 0;

    return {
      'initialWeight': initialWeight,
      'currentWeight': currentWeight,
      'totalLoss': totalLoss,
      'averageLossPerWeek': averageLossPerWeek,
    };
  }

  void _notifyListeners() {
    final allEntries = _weightEntries.values.expand((e) => e).toList();
    _weightEntriesController.add(allEntries);
  }

  void dispose() {
    _weightEntriesController.close();
  }
}
