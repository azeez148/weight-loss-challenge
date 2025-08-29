import 'package:weight_loss_challenge/api/mock_backend.dart';
import 'package:weight_loss_challenge/models/user_profile.dart';

class ProfileApi {
  final MockBackend _backend = MockBackend();

  Future<UserProfile?> getProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _backend.profiles[userId];
  }

  Future<UserProfile> updateProfile({
    required String userId,
    required String email,
    String? displayName,
    double? targetWeight,
    double? currentWeight,
    double? height,
    DateTime? birthDate,
    String? profileImageUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final currentProfile = _backend.profiles[userId];
    final updatedProfile = UserProfile(
      id: userId,
      email: email,
      displayName: displayName ?? currentProfile?.displayName ?? '',
      targetWeight: targetWeight ?? currentProfile?.targetWeight,
      currentWeight: currentWeight ?? currentProfile?.currentWeight,
      height: height ?? currentProfile?.height,
      birthDate: birthDate ?? currentProfile?.birthDate,
      profileImageUrl: profileImageUrl ?? currentProfile?.profileImageUrl,
      startWeight: currentProfile?.startWeight,
    );
    _backend.profiles[userId] = updatedProfile;
    return updatedProfile;
  }
}
