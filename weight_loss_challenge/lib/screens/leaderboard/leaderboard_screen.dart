import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight_loss_challenge/models/challenge.dart';
import 'package:weight_loss_challenge/models/user_model.dart';
import 'package:weight_loss_challenge/providers/app_state.dart';

class LeaderboardEntry {
  final UserModel user;
  final double weightLoss;

  LeaderboardEntry({required this.user, required this.weightLoss});
}

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.userChallenges.isEmpty) {
            return const Center(child: Text('No challenges to rank.'));
          }
          // For now, just display the leaderboard for the first challenge
          final challenge = appState.userChallenges.first;
          return LeaderboardView(challenge: challenge);
        },
      ),
    );
  }
}

class LeaderboardView extends StatelessWidget {
  final Challenge challenge;

  const LeaderboardView({super.key, required this.challenge});

  @override
  Widget build(BuildContext context) {
    // This is a simplified way to get users. In a real app, you'd have a better way
    // to get user details from IDs.
    final allUsers = [
      UserModel(id: 'user1', name: 'Alice', email: 'alice@example.com', currentWeight: 70, startWeight: 75, targetWeight: 65),
      UserModel(id: 'user2', name: 'Bob', email: 'bob@example.com', currentWeight: 85, startWeight: 90, targetWeight: 80),
    ];

    final entries = challenge.participantIds.map((userId) {
      final user = allUsers.firstWhere((u) => u.id == userId, orElse: () => UserModel(id: userId, name: 'Unknown', email: '', currentWeight: 0, startWeight: 0, targetWeight: 0));
      final weightLoss = challenge.getWeightLoss(userId) ?? 0.0;
      return LeaderboardEntry(user: user, weightLoss: weightLoss);
    }).toList();

    entries.sort((a, b) => b.weightLoss.compareTo(a.weightLoss));

    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return LeaderboardTile(
          entry: entry,
          rank: index + 1,
        );
      },
    );
  }
}

class LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;

  const LeaderboardTile({super.key, required this.entry, required this.rank});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(rank.toString()),
        ),
        title: Text(entry.user.name),
        subtitle: Text('Lost ${entry.weightLoss.toStringAsFixed(1)} kg'),
        trailing: _buildRankBadge(context),
      ),
    );
  }

  Widget? _buildRankBadge(BuildContext context) {
    if (rank <= 3) {
      IconData iconData;
      Color color;
      switch (rank) {
        case 1:
          iconData = Icons.emoji_events;
          color = Colors.amber;
          break;
        case 2:
          iconData = Icons.emoji_events;
          color = Colors.grey[400]!;
          break;
        case 3:
          iconData = Icons.emoji_events;
          color = Colors.brown[400]!;
          break;
        default:
          return null;
      }
      return Icon(iconData, color: color);
    }
    return null;
  }
}
