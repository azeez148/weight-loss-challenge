import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:weight_loss_challenge/providers/app_state.dart';
import 'package:weight_loss_challenge/theme/app_theme.dart';

class InviteScreen extends StatelessWidget {
  const InviteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final inviteCode = appState.userProfile?.inviteCode ?? 'No code found';
        return Scaffold(
          appBar: AppBar(
            title: const Text('Invite Friends'),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Text(
                          'Scan this QR code to join!',
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        if (inviteCode != 'No code found')
                          QrImageView(
                            data: inviteCode,
                            version: QrVersions.auto,
                            size: 200.0,
                          ),
                        const SizedBox(height: 24),
                        Text(
                          'Or share this code:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          inviteCode,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text('Share Invite Code'),
                  onPressed: inviteCode != 'No code found'
                      ? () {
                          Share.share(
                              'Join my weight loss challenge! Here is my invite code: $inviteCode');
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
