import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight_loss_challenge/models/challenge.dart';
import 'package:weight_loss_challenge/providers/app_state.dart';
import 'package:weight_loss_challenge/screens/challenges/challenge_detail_screen.dart';

class MyChallengesScreen extends StatelessWidget {
  final bool isActive;
  const MyChallengesScreen({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return _ChallengesTabView(isActive: isActive);
  }
}

class _ChallengesTabView extends StatelessWidget {
  final bool isActive;

  const _ChallengesTabView({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Individual'),
              Tab(text: 'Group'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _ChallengeList(
                  isActive: isActive,
                  type: ChallengeType.individual,
                ),
                _ChallengeList(
                  isActive: isActive,
                  type: ChallengeType.group,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeList extends StatelessWidget {
  final bool isActive;
  final ChallengeType type;

  const _ChallengeList({required this.isActive, required this.type});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final challenges = appState.allChallenges
            .where((c) =>
                c.participantIds.contains(appState.currentUser?.id) &&
                c.isActive == isActive &&
                c.type == type)
            .toList();

        if (challenges.isEmpty) {
          return const Center(
            child: Text('No challenges found.'),
          );
        }

        return ListView.builder(
          itemCount: challenges.length,
          itemBuilder: (context, index) {
            final challenge = challenges[index];
            return ListTile(
              title: Text(challenge.name),
              subtitle: Text(challenge.description),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        ChallengeDetailScreen(challengeId: challenge.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
