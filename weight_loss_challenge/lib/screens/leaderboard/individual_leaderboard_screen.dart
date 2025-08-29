import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight_loss_challenge/models/challenge.dart';
import 'package:weight_loss_challenge/models/user_model.dart';
import 'package:weight_loss_challenge/providers/app_state.dart';

class LeaderboardEntry {
  final UserModel user;
  final double weightLoss;
  final double weightLossPercentage;

  LeaderboardEntry({
    required this.user,
    required this.weightLoss,
    required this.weightLossPercentage,
  });
}

class IndividualLeaderboardScreen extends StatefulWidget {
  const IndividualLeaderboardScreen({super.key});

  @override
  State<IndividualLeaderboardScreen> createState() =>
      _IndividualLeaderboardScreenState();
}

class _IndividualLeaderboardScreenState
    extends State<IndividualLeaderboardScreen> {
  String? _selectedChallengeId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Individual Leaderboard'),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final userChallenges = appState.userChallenges;

          if (userChallenges.isEmpty) {
            return const Center(
                child: Text('You have not joined any challenges yet.'));
          }

          if (_selectedChallengeId == null && userChallenges.isNotEmpty) {
            _selectedChallengeId = userChallenges.first.id;
          }

          final selectedChallenge = userChallenges
              .firstWhere((c) => c.id == _selectedChallengeId);

          final entries = selectedChallenge.participantIds.map((userId) {
            final userProfile = appState.getUserProfile(userId);
            final weightLoss =
                selectedChallenge.getWeightLoss(userId) ?? 0.0;
            final weightLossPercentage =
                selectedChallenge.getWeightLossPercentage(userId) ?? 0.0;
            return LeaderboardEntry(
              user: UserModel(
                id: userId,
                name: userProfile?.displayName ?? 'Unknown',
                email: userProfile?.email ?? '',
                currentWeight: userProfile?.currentWeight ?? 0,
                startWeight: userProfile?.startWeight ?? 0,
                targetWeight: userProfile?.targetWeight ?? 0,
              ),
              weightLoss: weightLoss,
              weightLossPercentage: weightLossPercentage,
            );
          }).toList();

          entries.sort((a, b) =>
              b.weightLossPercentage.compareTo(a.weightLossPercentage));

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<String>(
                  value: _selectedChallengeId,
                  decoration: const InputDecoration(
                    labelText: 'Select Challenge',
                    border: OutlineInputBorder(),
                  ),
                  items: userChallenges
                      .map((challenge) => DropdownMenuItem(
                            value: challenge.id,
                            child: Text(challenge.name),
                          ))
                      .toList(),
                  onChanged: (String? challengeId) {
                    if (challengeId != null) {
                      setState(() {
                        _selectedChallengeId = challengeId;
                      });
                    }
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return LeaderboardTile(
                      entry: entry,
                      rank: index + 1,
                      showPercentage: true,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;
  final bool showPercentage;

  const LeaderboardTile({
    super.key,
    required this.entry,
    required this.rank,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRankColor(rank),
          child: Text(
            rank.toString(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          entry.user.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              showPercentage
                  ? '${entry.weightLossPercentage.toStringAsFixed(1)}% lost'
                  : '${entry.weightLoss.toStringAsFixed(1)} kg total weight loss',
            ),
            if (!showPercentage && entry.user.email.isNotEmpty)
              Text(
                entry.user.email,
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        isThreeLine: !showPercentage && entry.user.email.isNotEmpty,
        trailing: Text(
          showPercentage
              ? '${entry.weightLoss.toStringAsFixed(1)} kg'
              : '${entry.weightLossPercentage.toStringAsFixed(1)}%',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber; // Gold
      case 2:
        return Colors.blueGrey; // Silver
      case 3:
        return Colors.brown; // Bronze
      default:
        return Colors.grey;
    }
  }
}
