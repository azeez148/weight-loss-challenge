import 'package:weight_loss_challenge/api/mock_backend.dart';
import 'package:weight_loss_challenge/models/user_model.dart';
import 'package:weight_loss_challenge/services/auth_service.dart';
import 'package:uuid/uuid.dart';

class AuthApi {
  final MockBackend _backend = MockBackend();
  final _uuid = const Uuid();

  Future<MockUser?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (_backend.users.values.any((user) => user.email == email)) {
      throw Exception('Email already in use');
    }
    final user = UserModel(
      id: _uuid.v4(),
      email: email,
      name: displayName ?? email.split('@')[0],
      currentWeight: 0,
      startWeight: 0,
      targetWeight: 0,
    );
    _backend.users[user.id] = user;
    return MockUser(id: user.id, email: user.email, displayName: user.name);
  }

  Future<MockUser?> signInWithEmailAndPassword(
      String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final user =
          _backend.users.values.firstWhere((user) => user.email == email);
      return MockUser(id: user.id, email: user.email, displayName: user.name);
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
