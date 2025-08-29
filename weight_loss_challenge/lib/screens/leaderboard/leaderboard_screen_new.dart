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

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Individual'),
            Tab(text: 'Group'),
          ],
        ),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.userChallenges.isEmpty) {
            return const Center(child: Text('No challenges to rank.'));
          }
          
          final challenge = appState.userChallenges.first;
          return TabBarView(
            controller: _tabController,
            children: [
              LeaderboardView(
                challenge: challenge,
                isGroupView: false,
              ),
              LeaderboardView(
                challenge: challenge,
                isGroupView: true,
              ),
            ],
          );
        },
      ),
    );
  }
}

class LeaderboardView extends StatelessWidget {
  final Challenge challenge;
  final bool isGroupView;

  const LeaderboardView({
    super.key,
    required this.challenge,
    required this.isGroupView,
  });

  @override
  Widget build(BuildContext context) {
    return isGroupView ? _buildGroupLeaderboard(context) : _buildIndividualLeaderboard(context);
  }

  Widget _buildIndividualLeaderboard(BuildContext context) {
    // Fetch users and their progress
    final appState = context.read<AppState>();
    final entries = challenge.participantIds.map((userId) {
      final userProfile = appState.getUserProfile(userId);
      final weightLoss = challenge.getWeightLoss(userId) ?? 0.0;
      final weightLossPercentage = challenge.getWeightLossPercentage(userId) ?? 0.0;
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

    // Sort by weight loss percentage for individual ranking
    entries.sort((a, b) => b.weightLossPercentage.compareTo(a.weightLossPercentage));

    return ListView.builder(
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
    );
  }

  Widget _buildGroupLeaderboard(BuildContext context) {
    // Group users by their team/department if available
    final appState = context.read<AppState>();
    final groups = <String, List<String>>{
      'Team A': ['user1', 'user2'],
      'Team B': ['user3', 'user4'],
      // In a real app, you would get this from your backend
    };
    
    final entries = groups.entries.map((group) {
      final teamMembers = group.value;
      double totalWeightLoss = 0;
      double totalStartWeight = 0;
      
      for (final userId in teamMembers) {
        if (challenge.participantIds.contains(userId)) {
          final weightLoss = challenge.getWeightLoss(userId) ?? 0.0;
          final userProfile = appState.getUserProfile(userId);
          totalWeightLoss += weightLoss;
          totalStartWeight += userProfile?.startWeight ?? 0;
        }
      }
      
      final weightLossPercentage = totalStartWeight > 0 
          ? (totalWeightLoss / totalStartWeight) * 100
          : 0.0;
          
      return LeaderboardEntry(
        user: UserModel(
          id: group.key,
          name: group.key,
          email: '',
          currentWeight: 0,
          startWeight: totalStartWeight,
          targetWeight: 0,
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
        subtitle: Text(
          showPercentage
              ? '${entry.weightLossPercentage.toStringAsFixed(1)}% lost'
              : '${entry.weightLoss.toStringAsFixed(1)} kg lost',
        ),
        trailing: Text(
          showPercentage
              ? '${entry.weightLoss.toStringAsFixed(1)} kg'
              : '${entry.weightLossPercentage.toStringAsFixed(1)}%',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
