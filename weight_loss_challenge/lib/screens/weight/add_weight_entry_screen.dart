import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight_loss_challenge/models/challenge.dart';
import 'package:weight_loss_challenge/providers/app_state.dart';

class AddWeightEntryScreen extends StatefulWidget {
  final Challenge challenge;

  const AddWeightEntryScreen({
    super.key,
    required this.challenge,
  });

  @override
  State<AddWeightEntryScreen> createState() => _AddWeightEntryScreenState();
}

class _AddWeightEntryScreenState extends State<AddWeightEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _weightController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final weight = double.parse(_weightController.text);
        await context.read<AppState>().addWeightEntry(
          challengeId: widget.challenge.id,
          weight: weight,
          note: _noteController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Weight entry added successfully!')),
          );
          Navigator.of(context).pop();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Weight Entry'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Weight input
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  hintText: 'Enter your current weight',
                  prefixIcon: Icon(Icons.monitor_weight_outlined),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your weight';
                  }
                  final weight = double.tryParse(value);
                  if (weight == null) {
                    return 'Please enter a valid number';
                  }
                  if (weight <= 0) {
                    return 'Weight must be greater than 0';
                  }
                  if (weight > 500) {
                    return 'Weight seems too high';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Optional note
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  hintText: 'Add any comments about this entry',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 24),

              // Current stats
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Consumer<AppState>(
                    builder: (context, appState, _) {
                      final userProfile = appState.userProfile;
                      if (userProfile == null) return const SizedBox.shrink();

                      final startWeight = userProfile.startWeight ?? 0;
                      final currentWeight = userProfile.currentWeight ?? 0;
                      final targetWeight = userProfile.targetWeight ?? 0;
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Progress',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          _buildStatRow('Start Weight', '$startWeight kg'),
                          _buildStatRow('Current Weight', '$currentWeight kg'),
                          _buildStatRow('Target Weight', '$targetWeight kg'),
                          const Divider(),
                          _buildStatRow(
                            'Total Lost',
                            '${(startWeight - currentWeight).toStringAsFixed(1)} kg',
                            isHighlight: true,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save Weight Entry'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : null,
              color: isHighlight ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}
