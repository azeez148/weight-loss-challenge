import 'package:weight_loss_challenge/api/mock_backend.dart';
import 'package:weight_loss_challenge/models/user_model.dart';

class ProfileApi {
  final MockBackend _backend = MockBackend();

  Future<UserModel?> getProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _backend.users[userId];
  }

  Future<UserModel> updateProfile({
    required String userId,
    required String email,
    String? name,
    double? targetWeight,
    double? currentWeight,
    double? height,
    DateTime? lastRecordedDateTime,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final currentUser = _backend.users[userId];
    final updatedUser = UserModel(
      id: userId,
      email: email,
      name: name ?? currentUser?.name ?? '',
      targetWeight: targetWeight ?? currentUser?.targetWeight ?? 0.0,
      currentWeight: currentWeight ?? currentUser?.currentWeight ?? 0.0,
      height: height ?? currentUser?.height,
      lastRecordedDateTime: lastRecordedDateTime ?? currentUser?.lastRecordedDateTime,
      startWeight: currentUser?.startWeight ?? 0.0,
    );
    _backend.users[userId] = updatedUser;
    return updatedUser;
  }
}
