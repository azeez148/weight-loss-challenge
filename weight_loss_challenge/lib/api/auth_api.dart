import 'package:weight_loss_challenge/api/mock_backend.dart';
import 'package:weight_loss_challenge/services/auth_service.dart';

class AuthApi {
  final MockBackend _backend = MockBackend();

  Future<MockUser?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (_backend.users.any((user) => user.email == email)) {
      throw Exception('Email already in use');
    }
    final user = MockUser(
      id: _backend.users.length.toString(),
      email: email,
      displayName: displayName ?? '',
    );
    _backend.users.add(user);
    return user;
  }

  Future<MockUser?> signInWithEmailAndPassword(
      String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _backend.users.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
