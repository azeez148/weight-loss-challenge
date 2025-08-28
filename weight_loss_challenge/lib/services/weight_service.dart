import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/weight_entry.dart';

class WeightService {
  final _uuid = const Uuid();
  final Map<String, List<WeightEntry>> _weightEntries = {};
  final _weightEntriesController = StreamController<List<WeightEntry>>.broadcast();

  Stream<List<WeightEntry>> getWeightEntriesStream(String userId) {
    return _weightEntriesController.stream.map((entries) =>
        entries.where((entry) => entry.userId == userId).toList());
  }

  // Get all weight entries for a user
  List<WeightEntry> getWeightEntriesForUser(String userId) {
    return List.unmodifiable(_weightEntries[userId] ?? []);
  }

  // Get weight entries for a specific challenge
  List<WeightEntry> getWeightEntriesForChallenge(String userId, String challengeId) {
    final userEntries = _weightEntries[userId] ?? [];
    return userEntries.where((entry) => entry.challengeId == challengeId).toList();
  }

  // Add a new weight entry
  Future<WeightEntry> addWeightEntry({
    required String userId,
    required double weight,
    String? challengeId,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final entry = WeightEntry(
      id: _uuid.v4(),
      userId: userId,
      challengeId: challengeId,
      weight: weight,
      date: DateTime.now(),
    );

    if (!_weightEntries.containsKey(userId)) {
      _weightEntries[userId] = [];
    }

    _weightEntries[userId]!.add(entry);
    _notifyListeners();
    return entry;
  }

  // Update a weight entry
  Future<WeightEntry> updateWeightEntry({
    required String userId,
    required String entryId,
    double? weight,
    String? note,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final entries = _weightEntries[userId];
    if (entries == null) throw Exception('No entries found for user');

    final index = entries.indexWhere((entry) => entry.id == entryId);
    if (index == -1) throw Exception('Entry not found');

    final oldEntry = entries[index];
    final updatedEntry = oldEntry.copyWith(
      weight: weight,
      note: note,
    );

    entries[index] = updatedEntry;
    _notifyListeners();
    return updatedEntry;
  }

  // Delete a weight entry
  Future<void> deleteWeightEntry(String userId, String entryId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final entries = _weightEntries[userId];
    if (entries == null) return;

    entries.removeWhere((entry) => entry.id == entryId);
    _notifyListeners();
  }

  // Get user's progress statistics
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

  // Clean up resources
  void dispose() {
    _weightEntriesController.close();
  }
}
