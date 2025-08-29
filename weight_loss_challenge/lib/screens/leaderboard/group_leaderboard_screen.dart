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

class GroupLeaderboardScreen extends StatelessWidget {
  const GroupLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Leaderboard'),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final allChallenges = appState.allChallenges;

          if (allChallenges.isEmpty) {
            return const Center(child: Text('No challenges found.'));
          }

          final entries = allChallenges.map((challenge) {
            double totalWeightLoss = 0;
            double totalStartWeight = 0;

            for (final userId in challenge.participantIds) {
              final weightLoss = challenge.getWeightLoss(userId) ?? 0.0;
              final userProfile = appState.getUserProfile(userId);
              totalWeightLoss += weightLoss;
              totalStartWeight += userProfile?.startWeight ?? 0;
            }

            final weightLossPercentage = totalStartWeight > 0
                ? (totalWeightLoss / totalStartWeight) * 100
                : 0.0;

            return LeaderboardEntry(
              user: UserModel(
                id: challenge.id,
                name:
                    '${challenge.name} (${challenge.participantIds.length} participants)',
                email: challenge.description,
                currentWeight: totalWeightLoss,
                startWeight: totalStartWeight,
                targetWeight: challenge.weightLossGoal ?? 0,
              ),
              weightLoss: totalWeightLoss,
              weightLossPercentage: weightLossPercentage,
            );
          }).toList();

          // Sort by total weight loss for group ranking
          entries.sort((a, b) => b.weightLoss.compareTo(a.weightLoss));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return LeaderboardTile(
                entry: entry,
                rank: index + 1,
                showPercentage: false,
              );
            },
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
