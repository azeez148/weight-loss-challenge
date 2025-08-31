import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight_loss_challenge/models/challenge.dart';
import 'package:weight_loss_challenge/providers/app_state.dart';
import 'package:weight_loss_challenge/screens/challenges/challenge_detail_screen.dart';

class CreateChallengeScreen extends StatefulWidget {
  const CreateChallengeScreen({super.key});

  @override
  State<CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends State<CreateChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetWeightController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  DateTime _joinEndDate = DateTime.now().add(const Duration(days: 7));
  DateTime _entryWeightEndDate = DateTime.now().add(const Duration(days: 7));
  DateTime _finalWeightEndDate = DateTime.now().add(const Duration(days: 30));
  ChallengeType _type = ChallengeType.individual;
  bool _isPublic = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateChallenge() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final appState = context.read<AppState>();
        final currentUser = appState.currentUser;

        if (currentUser == null) {
          throw Exception('User not logged in');
        }

        final challenge = await appState.createChallenge(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          type: _type,
          startDate: _startDate,
          endDate: _endDate,
          weightLossGoal: _targetWeightController.text.isEmpty
              ? null
              : double.parse(_targetWeightController.text),
          isPublic: _isPublic,
          joinEndDate: _joinEndDate,
          entryWeightEndDate: _entryWeightEndDate,
          finalWeightEndDate: _finalWeightEndDate,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Challenge created successfully!')),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
                  ChallengeDetailScreen(challengeId: challenge.id),
            ),
          );
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
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _selectDate(BuildContext context,
      {required DateTime initialDate,
      required Function(DateTime) onDateSelected}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      onDateSelected(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Challenge'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Challenge Type Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Challenge Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SegmentedButton<ChallengeType>(
                        segments: const [
                          ButtonSegment(
                            value: ChallengeType.individual,
                            icon: Icon(Icons.person),
                            label: Text('Individual'),
                          ),
                          ButtonSegment(
                            value: ChallengeType.group,
                            icon: Icon(Icons.group),
                            label: Text('Group'),
                          ),
                        ],
                        selected: {_type},
                        onSelectionChanged: (Set<ChallengeType> types) {
                          setState(() {
                            _type = types.first;
                          });
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Public Challenge'),
                        value: _isPublic,
                        onChanged: (value) {
                          setState(() {
                            _isPublic = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Challenge Details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Challenge Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Challenge Name',
                          hintText: 'Summer Weight Loss 2025',
                        ),
                        enabled: !_isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a challenge name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Let\'s get fit together!',
                        ),
                        maxLines: 3,
                        enabled: !_isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Challenge Type Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Challenge Goals',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _type == ChallengeType.individual
                            ? 'Track your personal weight loss journey and challenge yourself to reach your goals!'
                            : 'Compete with friends or colleagues to see which group can achieve the greatest weight loss percentage!',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _targetWeightController,
                        decoration: const InputDecoration(
                          labelText: 'Weight Loss Goal (kg)',
                          hintText: 'e.g., 5 for 5kg loss goal',
                          helperText: 'Optional - for personal reference',
                        ),
                        keyboardType: TextInputType.number,
                        enabled: !_isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return null; // Making it optional
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          final goal = double.parse(value);
                          if (goal <= 0) {
                            return 'Goal must be greater than 0';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Challenge Duration
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Challenge Timelines',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: const Text('Start Date'),
                        subtitle: Text(
                          '${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context,
                            initialDate: _startDate,
                            onDateSelected: (date) =>
                                setState(() => _startDate = date)),
                      ),
                      ListTile(
                        title: const Text('End Date'),
                        subtitle: Text(
                          '${_endDate.year}-${_endDate.month.toString().padLeft(2, '0')}-${_endDate.day.toString().padLeft(2, '0')}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context,
                            initialDate: _endDate,
                            onDateSelected: (date) =>
                                setState(() => _endDate = date)),
                      ),
                      ListTile(
                        title: const Text('Join End Date'),
                        subtitle: Text(
                          '${_joinEndDate.year}-${_joinEndDate.month.toString().padLeft(2, '0')}-${_joinEndDate.day.toString().padLeft(2, '0')}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context,
                            initialDate: _joinEndDate,
                            onDateSelected: (date) =>
                                setState(() => _joinEndDate = date)),
                      ),
                      ListTile(
                        title: const Text('Entry Weight End Date'),
                        subtitle: Text(
                          '${_entryWeightEndDate.year}-${_entryWeightEndDate.month.toString().padLeft(2, '0')}-${_entryWeightEndDate.day.toString().padLeft(2, '0')}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context,
                            initialDate: _entryWeightEndDate,
                            onDateSelected: (date) =>
                                setState(() => _entryWeightEndDate = date)),
                      ),
                      ListTile(
                        title: const Text('Final Weight End Date'),
                        subtitle: Text(
                          '${_finalWeightEndDate.year}-${_finalWeightEndDate.month.toString().padLeft(2, '0')}-${_finalWeightEndDate.day.toString().padLeft(2, '0')}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context,
                            initialDate: _finalWeightEndDate,
                            onDateSelected: (date) =>
                                setState(() => _finalWeightEndDate = date)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleCreateChallenge,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Create Challenge'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
