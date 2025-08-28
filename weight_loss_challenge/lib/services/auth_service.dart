import 'dart:async';

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
  MockUser? _currentUser;
  final _authStateController = StreamController<MockUser?>.broadcast();

  // Hardcoded credentials for testing
  static const _mockEmail = 'test@example.com';
  static const _mockPassword = 'password123';

  // Auth state changes stream
  Stream<MockUser?> get authStateChanges => _authStateController.stream;

  // Get current user
  MockUser? get currentUser => _currentUser;

  // Create user with email and password
  Future<MockUser?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Mock registration delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock user creation
      if (email == _mockEmail) {
        throw Exception('Email already in use');
      }
      
      _currentUser = MockUser(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: displayName,
      );
      _authStateController.add(_currentUser);
      return _currentUser;
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<MockUser?> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Mock authentication delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Check against hardcoded credentials
      if (email == _mockEmail && password == _mockPassword) {
        _currentUser = MockUser(
          id: '12345',
          email: email,
          displayName: 'Test User',
        );
        _authStateController.add(_currentUser);
        return _currentUser;
      } else {
        throw Exception('Invalid email or password. Use test@example.com / password123');
      }
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  // Register with email and password
  Future<MockUser?> registerWithEmailAndPassword(String email, String password) async {
    try {
      // Mock registration delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Pretend registration is successful only for non-test account
      if (email != _mockEmail && email.isNotEmpty && password.length >= 6) {
        _currentUser = MockUser(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          email: email,
        );
        _authStateController.add(_currentUser);
        return _currentUser;
      } else if (email == _mockEmail) {
        throw Exception('Email already in use');
      } else {
        throw Exception('Invalid email or password. Password must be at least 6 characters');
      }
    } catch (e) {
      print('Error registering: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _currentUser = null;
      _authStateController.add(null);
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Clean up resources
  void dispose() {
    _authStateController.close();
  }
}
