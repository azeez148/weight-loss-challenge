import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:weight_loss_challenge/models/challenge.dart';
import 'package:weight_loss_challenge/providers/app_state.dart';

class ChallengeDetailScreen extends StatefulWidget {
  final String challengeId;

  const ChallengeDetailScreen({
    super.key,
    required this.challengeId,
  });

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  final _weightController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _recordWeight() async {
    if (_weightController.text.isEmpty) return;

    final weight = double.tryParse(_weightController.text);
    if (weight == null) return;

    setState(() => _isLoading = true);

    try {
      await context.read<AppState>().addWeightEntry(
        challengeId: widget.challengeId,
        weight: weight,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Weight recorded successfully!')),
        );
        _weightController.clear();
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _inviteParticipants() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final challenge = context.read<AppState>().userChallenges
          .firstWhere((c) => c.id == widget.challengeId);

      final shareText =
          'Join my Weight Loss Challenge "${challenge.name}"! Use this invite code: ${challenge.inviteCode}';
      await Share.share(shareText);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _leaveChallenge(Challenge challenge) async {
    if (_isLoading) return;

    final appState = context.read<AppState>();
    if (challenge.creatorId == appState.currentUser?.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Challenge creator cannot leave the challenge'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Challenge'),
        content: const Text('Are you sure you want to leave this challenge?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await appState.leaveChallenge(challenge.id);
      if (mounted) {
        Navigator.pop(context); // Return to previous screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildProgressSection(Challenge challenge, AppState appState) {
    final currentUser = appState.currentUser;
    if (currentUser == null) return const SizedBox.shrink();

    final weightLoss = challenge.getWeightLoss(currentUser.id);
    final weightLossPercentage = challenge.getWeightLossPercentage(currentUser.id);
    final progress = challenge.participantProgress[currentUser.id] ?? [];
    final hasEntries = progress.isNotEmpty;

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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (challenge.weightLossGoal != null)
                  Text(
                    'Goal: ${challenge.weightLossGoal}kg',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (!hasEntries)
              const Text('No weight entries recorded yet')
            else
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        'Starting Weight',
                        '${progress.first.weight.toStringAsFixed(1)} kg',
                      ),
                      _buildStatCard(
                        'Current Weight',
                        '${progress.last.weight.toStringAsFixed(1)} kg',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        'Weight Lost',
                        '${weightLoss?.abs().toStringAsFixed(1) ?? '0.0'} kg',
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      _buildStatCard(
                        'Loss Percentage',
                        '${weightLossPercentage?.abs().toStringAsFixed(1) ?? '0.0'}%',
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Record Weight',
                      hintText: 'Enter your current weight in kg',
                      helperText: 'e.g., 75.5',
                    ),
                    keyboardType: TextInputType.number,
                    enabled: !_isLoading && !challenge.isReadOnly(currentUser.id),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: _isLoading || challenge.isReadOnly(currentUser.id)
                      ? null
                      : _recordWeight,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsSection(Challenge challenge, AppState appState) {
    final currentUser = appState.currentUser;
    final isHost = challenge.creatorId == currentUser?.id;

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
                  'Participants',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isHost || challenge.participantIds.contains(currentUser?.id))
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: _isLoading ? null : _inviteParticipants,
                        icon: const Icon(Icons.share),
                        label: const Text('Share Invite'),
                      ),
                      IconButton(
                        onPressed: () {
                          // TODO: Implement QR code generation and sharing.
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('QR code generation not implemented yet.')),
                          );
                        },
                        icon: const Icon(Icons.qr_code),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (isHost)
              const Chip(
                label: Text('Hosted by you'),
                backgroundColor: Colors.green,
                labelStyle: TextStyle(color: Colors.white),
              ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: challenge.participantIds.length,
              itemBuilder: (context, index) {
                final participantId = challenge.participantIds[index];
                final user = appState.getUserProfile(participantId);
                final isCreator = challenge.creatorId == participantId;
                final progress = challenge.participantProgress[participantId] ?? [];
                return ExpansionTile(
                  leading: CircleAvatar(
                    child: Text(user?.name[0].toUpperCase() ?? ''),
                  ),
                  title: Text(user?.name ?? 'Unknown User'),
                  trailing: isCreator ? const Chip(label: Text('Host')) : null,
                  children: [
                    if (progress.isEmpty)
                      const ListTile(
                        title: Text('No weight entries yet.'),
                      )
                    else
                      ...progress.asMap().entries.map((entryMap) {
                        final entryIndex = entryMap.key;
                        final entry = entryMap.value;
                        final canApprove =
                            entry.approvalStatus == WeightEntryApprovalStatus.pending &&
                                participantId != appState.currentUser?.id &&
                                challenge.participantIds
                                    .contains(appState.currentUser?.id);
                        return ListTile(
                          title: Text('${entry.weight} kg'),
                          subtitle: Text(
                              '${entry.timestamp.toString().split(' ')[0]} - ${entry.approvalStatus.toString().split('.').last}'),
                          trailing: canApprove
                              ? ElevatedButton(
                                  onPressed: () {
                                    appState.approveWeightEntry(
                                        challenge.id, participantId, entryIndex);
                                  },
                                  child: const Text('Approve'),
                                )
                              : null,
                        );
                      }),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _voteToEndChallenge(Challenge challenge) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vote to End Challenge'),
        content: const Text(
            'Are you sure you want to vote to end this challenge? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Vote'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<AppState>().endChallenge(challenge.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your vote has been cast!')),
      );
    }
  }

  Widget _buildStatCard(String label, String value, {Color? color}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color?.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final challenge = appState.userChallenges
            .firstWhere((c) => c.id == widget.challengeId);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Challenge Details'),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'leave':
                      _leaveChallenge(challenge);
                      break;
                    case 'end':
                      _voteToEndChallenge(challenge);
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'leave',
                    child: Text('Leave Challenge'),
                  ),
                  PopupMenuItem<String>(
                    value: 'end',
                    enabled: !challenge.isReadOnly(appState.currentUser!.id),
                    child: Text(
                        'Vote to End Challenge (${challenge.endChallengeVotes.length}/${challenge.initialParticipantIds.length})'),
                  ),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(challenge.description),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            challenge.type == ChallengeType.individual
                                ? Icons.person
                                : Icons.group,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            challenge.type == ChallengeType.individual
                                ? 'Individual Challenge'
                                : 'Group Challenge',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${challenge.startDate.year}-${challenge.startDate.month.toString().padLeft(2, '0')}-${challenge.startDate.day.toString().padLeft(2, '0')} to '
                            '${challenge.endDate.year}-${challenge.endDate.month.toString().padLeft(2, '0')}-${challenge.endDate.day.toString().padLeft(2, '0')}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildProgressSection(challenge, appState),
              const SizedBox(height: 16),
              _buildParticipantsSection(challenge, appState),
              if (challenge.isPublic &&
                  !challenge.participantIds.contains(appState.currentUser?.id))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      await appState.requestToJoinPublicChallenge(
                          challenge.id, appState.currentUser!.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Request to join sent!')),
                      );
                    },
                    child: const Text('Request to Join'),
                  ),
                ),
              if (challenge.creatorId == appState.currentUser?.id)
                _buildPendingRequestsSection(challenge, appState),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPendingRequestsSection(Challenge challenge, AppState appState) {
    return FutureBuilder<List<String>>(
      future: appState.getPendingJoinRequests(challenge.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        final requestIds = snapshot.data!;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pending Join Requests',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: requestIds.length,
                  itemBuilder: (context, index) {
                    final userId = requestIds[index];
                    final user = appState.getUserProfile(userId);
                    return ListTile(
                      title: Text(user?.name ?? 'Unknown User'),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          await appState.approveJoinRequest(challenge.id, userId);
                        },
                        child: const Text('Approve'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
