import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight_loss_challenge/providers/app_state.dart';
import 'package:weight_loss_challenge/screens/challenges/challenge_detail_screen.dart';

class InvitedChallengesScreen extends StatelessWidget {
  const InvitedChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final challenges = appState.allChallenges
            .where((c) =>
                c.isPublic &&
                !c.participantIds.contains(appState.currentUser?.id))
            .toList();

        if (challenges.isEmpty) {
          return const Center(
            child: Text('No public challenges found.'),
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
