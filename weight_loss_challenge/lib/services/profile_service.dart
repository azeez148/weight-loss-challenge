import 'dart:async';
import '../models/user_profile.dart';

class ProfileService {
  final Map<String, UserProfile> _profiles = {};
  final _profileController = StreamController<UserProfile?>.broadcast();

  Stream<UserProfile?> getProfileStream(String userId) {
    return _profileController.stream.map((profile) =>
        profile?.id == userId ? profile : null);
  }

  // Get user profile
  UserProfile? getProfile(String userId) {
    return _profiles[userId];
  }

  // Create or update profile
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
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final existingProfile = _profiles[userId];
    final updatedProfile = UserProfile(
      id: userId,
      email: email,
      displayName: displayName ?? existingProfile?.displayName ?? email.split('@')[0],
      targetWeight: targetWeight ?? existingProfile?.targetWeight,
      currentWeight: currentWeight ?? existingProfile?.currentWeight,
      height: height ?? existingProfile?.height,
      birthDate: birthDate ?? existingProfile?.birthDate,
      profileImageUrl: profileImageUrl ?? existingProfile?.profileImageUrl,
    );

    _profiles[userId] = updatedProfile;
    _profileController.add(updatedProfile);
    return updatedProfile;
  }

  // Delete profile
  Future<void> deleteProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _profiles.remove(userId);
    _profileController.add(null);
  }

  // Clean up resources
  void dispose() {
    _profileController.close();
  }
}
