import 'dart:async';
import 'package:weight_loss_challenge/api/profile_api.dart';
import '../models/user_profile.dart';

class ProfileService {
  final ProfileApi _api = ProfileApi();
  final Map<String, UserProfile> _profiles = {};
  final _profileController = StreamController<UserProfile?>.broadcast();

  Stream<UserProfile?> getProfileStream(String userId) {
    return _profileController.stream
        .map((profile) => profile?.id == userId ? profile : null);
  }

  UserProfile? getProfile(String userId) {
    return _profiles[userId];
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
    final updatedProfile = await _api.updateProfile(
      userId: userId,
      email: email,
      displayName: displayName,
      targetWeight: targetWeight,
      currentWeight: currentWeight,
      height: height,
      birthDate: birthDate,
      profileImageUrl: profileImageUrl,
    );
    _profiles[userId] = updatedProfile;
    _profileController.add(updatedProfile);
    return updatedProfile;
  }

  void dispose() {
    _profileController.close();
  }
}
