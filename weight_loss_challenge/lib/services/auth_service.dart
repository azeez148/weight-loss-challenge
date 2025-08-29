import 'dart:async';
import 'package:weight_loss_challenge/api/auth_api.dart';

// Mock user class to represent authenticated user
class MockUser {
  final String id;
  final String email;
  final String displayName;

  MockUser({
    required this.id,
    required this.email,
    String? displayName,
  }) : displayName = displayName ?? email.split('@')[0];
}

class AuthService {
  final AuthApi _api = AuthApi();
  MockUser? _currentUser;
  final _authStateController = StreamController<MockUser?>.broadcast();

  Stream<MockUser?> get authStateChanges => _authStateController.stream;

  MockUser? get currentUser => _currentUser;

  Future<MockUser?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _currentUser = await _api.createUserWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
    _authStateController.add(_currentUser);
    return _currentUser;
  }

  Future<MockUser?> signInWithEmailAndPassword(
      String email, String password) async {
    _currentUser = await _api.signInWithEmailAndPassword(email, password);
    _authStateController.add(_currentUser);
    return _currentUser;
  }

  Future<void> signOut() async {
    await _api.signOut();
    _currentUser = null;
    _authStateController.add(null);
  }

  void dispose() {
    _authStateController.close();
  }
}
