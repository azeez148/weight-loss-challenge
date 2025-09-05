import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight_loss_challenge/providers/app_state.dart';
import 'package:weight_loss_challenge/screens/app_shell.dart';
import 'package:weight_loss_challenge/screens/auth/login_screen.dart';
import 'package:weight_loss_challenge/services/auth_service.dart';
import 'package:weight_loss_challenge/theme/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Weight Loss Challenge',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: StreamBuilder<MockUser?>(
          stream: context.watch<AppState>().authStateChanges,
          builder: (context, snapshot) {
            final user = snapshot.data;
            if (user != null) {
              return const AppShell();
            }
            return const LoginScreen();
          },
        ));
  }
}
