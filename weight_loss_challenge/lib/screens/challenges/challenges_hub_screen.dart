import 'package:flutter/material.dart';
import 'package:weight_loss_challenge/screens/challenges/my_challenges_screen.dart';
import 'package:weight_loss_challenge/screens/challenges/invited_challenges_screen.dart';

class ChallengesHubScreen extends StatelessWidget {
  const ChallengesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Challenges'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My Challenges'),
              Tab(text: 'Invited Challenges'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Active'),
                      Tab(text: 'Completed'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        MyChallengesScreen(isActive: true),
                        MyChallengesScreen(isActive: false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const InvitedChallengesScreen(),
          ],
        ),
      ),
    );
  }
}
