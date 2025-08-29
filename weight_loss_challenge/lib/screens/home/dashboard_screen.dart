import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:weight_loss_challenge/models/challenge.dart';
import 'package:weight_loss_challenge/providers/app_state.dart';
import 'package:weight_loss_challenge/screens/auth/login_screen.dart';
import 'package:weight_loss_challenge/screens/challenges/challenge_detail_screen.dart';
import 'package:weight_loss_challenge/screens/challenges/create_challenge_screen.dart';
import 'package:weight_loss_challenge/theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _handleLogout(BuildContext context) async {
    try {
      await context.read<AppState>().logout();
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e')),
        );
      }
    }
  }

  void _showJoinChallengeDialog(BuildContext context) {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Join a Challenge'),
          content: TextField(
            controller: codeController,
            decoration: const InputDecoration(
              labelText: 'Invite Code',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final code = codeController.text.trim();
                if (code.isNotEmpty) {
                  try {
                    await context
                        .read<AppState>()
                        .joinChallengeWithInviteCode(code);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Successfully joined challenge!')),
                    );
                  } catch (e) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                }
              },
              child: const Text('Join'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final statistics = appState.userStatistics.map(
      (key, value) => MapEntry(key, (value ?? 0.0) as double),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight Loss Challenge'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Join Challenge',
            onPressed: () => _showJoinChallengeDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile coming soon!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Implement refresh logic
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStatisticsCard(context, statistics),
            const SizedBox(height: 16),
            _buildActiveChallengesSection(context, appState),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateChallengeScreen(),
            ),
          );
        },
        label: const Text('New Challenge'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatisticsCard(BuildContext context, Map<String, double> statistics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Progress',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    // TODO: Navigate to add weight entry screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add weight entry coming soon!')),
                    );
                  },
                  tooltip: 'Add Weight Entry',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatBox(
                  'Current',
                  _formatValue(statistics['currentWeight']),
                ),
                _buildStatBox(
                  'Total Loss',
                  _formatValue(statistics['totalLoss']),
                  color: Theme.of(context).colorScheme.primary,
                ),
                _buildStatBox(
                  'Per Week',
                  _formatValue(statistics['averageLossPerWeek']),
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 500.ms).slideY(begin: 0.2, end: 0.0);
  }

  String _formatValue(double? value) {
    return '${value?.toStringAsFixed(1) ?? '0.0'} kg';
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final now = DateTime.now();
    final startDiff = start.difference(now).inDays;
    final endDiff = end.difference(now).inDays;

    if (startDiff > 0) {
      return 'Starts in $startDiff days';
    } else if (endDiff < 0) {
      return 'Ended ${-endDiff} days ago';
    } else {
      return '${endDiff + 1} days remaining';
    }
  }

  Widget _buildStatBox(String label, String value, {Color? color}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color?.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color ?? Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveChallengesSection(BuildContext context, AppState appState) {
    final challenges = appState.userChallenges;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Challenges',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (challenges.isEmpty)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No active challenges',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CreateChallengeScreen(),
                      ),
                    );
                  },
                  child: const Text('Create your first challenge'),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: challenges.length,
            itemBuilder: (context, index) {
              final challenge = challenges[index];
              final currentUser = appState.currentUser;
              if (currentUser == null) return const SizedBox.shrink();

              final userProgress =
                  challenge.participantProgress[currentUser.id];
              final hasProgress =
                  userProgress != null && userProgress.isNotEmpty;
              final weightLoss = challenge.getWeightLoss(currentUser.id);
              final progressText = hasProgress
                  ? weightLoss != null
                      ? '${weightLoss.abs().toStringAsFixed(1)}kg lost'
                      : 'Progress recorded'
                  : 'No progress yet';

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    challenge.type == ChallengeType.individual
                        ? Icons.person
                        : Icons.group,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    challenge.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(progressText),
                      const SizedBox(height: 4),
                      Text(
                        '${challenge.participantIds.length} participants • ${_formatDateRange(challenge.startDate, challenge.endDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChallengeDetailScreen(
                          challengeId: challenge.id,
                        ),
                      ),
                    );
                  },
                ),
              ).animate().fade(duration: 500.ms).slideY(begin: 0.5, end: 0.0);
            },
          ),
      ],
    );
  }
}