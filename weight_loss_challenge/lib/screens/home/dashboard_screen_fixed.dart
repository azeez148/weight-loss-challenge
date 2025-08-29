import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:weight_loss_challenge/models/challenge.dart';
import 'package:weight_loss_challenge/providers/app_state.dart';
import 'package:weight_loss_challenge/screens/auth/login_screen.dart';
import 'package:weight_loss_challenge/screens/challenges/challenge_detail_screen.dart';
import 'package:weight_loss_challenge/screens/challenges/create_challenge_screen.dart';
import 'package:weight_loss_challenge/screens/weight/add_weight_entry_screen.dart';
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
                try {
                  await context.read<AppState>().joinChallengeWithInviteCode(
                    codeController.text.trim(),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Successfully joined the challenge!'),
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
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
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (appState.userChallenges.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please join a challenge first')),
            );
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddWeightEntryScreen(
                challenge: appState.userChallenges.first,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Weight'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Implement refresh logic
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (appState.userChallenges.isEmpty) ...[
              const SizedBox(height: 32),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.group_add,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No challenges yet',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Join or create a challenge to get started',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CreateChallengeScreen(),
                          ),
                        );
                      },
                      child: const Text('Create Challenge'),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(
                    begin: 0.3,
                    curve: Curves.easeOut,
                    duration: const Duration(milliseconds: 500),
                  ),
            ] else ...[
              for (final challenge in appState.userChallenges)
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ChallengeDetailScreen(
                            challengeId: challenge.id,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            challenge.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(challenge.description),
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: challenge.progressPercentage / 100,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${challenge.progressPercentage.toStringAsFixed(1)}% complete',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                '${challenge.daysRemaining} days remaining',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
