import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight_loss_challenge/models/user_profile.dart';
import 'package:weight_loss_challenge/providers/app_state.dart';
import 'package:weight_loss_challenge/screens/leaderboard/individual_leaderboard_screen.dart';
import 'package:weight_loss_challenge/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _targetWeightController;
  late TextEditingController _currentWeightController;
  late TextEditingController _heightController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _targetWeightController = TextEditingController();
    _currentWeightController = TextEditingController();
    _heightController = TextEditingController();
    _initializeControllers();
  }

  void _initializeControllers() {
    final userProfile = context.read<AppState>().userProfile;
    if (userProfile != null) {
      _nameController.text = userProfile.displayName;
      _targetWeightController.text = userProfile.targetWeight?.toString() ?? '';
      _currentWeightController.text = userProfile.currentWeight?.toString() ?? '';
      _heightController.text = userProfile.height?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetWeightController.dispose();
    _currentWeightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await context.read<AppState>().updateProfile(
        displayName: _nameController.text,
        targetWeight: double.tryParse(_targetWeightController.text),
        currentWeight: double.tryParse(_currentWeightController.text),
        height: double.tryParse(_heightController.text),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final userProfile = appState.userProfile;
          if (userProfile == null) {
            return const Center(child: Text('No profile found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(userProfile),
                  const SizedBox(height: 24),
                  _buildStatisticsCard(appState),
                  const SizedBox(height: 24),
                  _buildLeaderboardCard(context),
                  const SizedBox(height: 24),
                  _buildProfileForm(),
                  const SizedBox(height: 24),
                  _buildWeightHistoryCard(appState),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                profile.displayName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.displayName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    profile.email,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(AppState appState) {
    final stats = appState.userStatistics;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progress Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total Loss', '${stats['totalLoss']?.toStringAsFixed(1) ?? '0'} kg'),
                _buildStatItem('Weekly Avg', '${stats['averageLossPerWeek']?.toStringAsFixed(1) ?? '0'} kg'),
                _buildStatItem('Success Rate', '${(stats['successRate'] ?? 0.0).toStringAsFixed(0)}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildProfileForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Information',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Display Name',
            border: OutlineInputBorder(),
          ),
          enabled: _isEditing,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _currentWeightController,
                decoration: const InputDecoration(
                  labelText: 'Current Weight (kg)',
                  border: OutlineInputBorder(),
                ),
                enabled: _isEditing,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _targetWeightController,
                decoration: const InputDecoration(
                  labelText: 'Target Weight (kg)',
                  border: OutlineInputBorder(),
                ),
                enabled: _isEditing,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _heightController,
          decoration: const InputDecoration(
            labelText: 'Height (cm)',
            border: OutlineInputBorder(),
          ),
          enabled: _isEditing,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) return null;
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLeaderboardCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Leaderboards',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const IndividualLeaderboardScreen(),
                    ),
                  );
                },
                child: const Text('View Individual Leaderboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightHistoryCard(AppState appState) {
    final entries = appState.userWeightEntries;
    if (entries.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weight History',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text('No weight entries recorded yet'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weight History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return ListTile(
                  title: Text('${entry.weight} kg'),
                  subtitle: Text(entry.date.toString().split(' ')[0]),
                  trailing: entry.note != null ? Text(entry.note!) : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
