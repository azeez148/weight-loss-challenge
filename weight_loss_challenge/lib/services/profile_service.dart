import 'dart:async';
import 'package:weight_loss_challenge/api/profile_api.dart';
import '../models/user_model.dart';

class ProfileService {
  final ProfileApi _api = ProfileApi();
  final Map<String, UserModel> _profiles = {};
  final _profileController = StreamController<UserModel?>.broadcast();

  Stream<UserModel?> getProfileStream(String userId) {
    return _profileController.stream
        .map((profile) => profile?.id == userId ? profile : null);
  }

  UserModel? getProfile(String userId) {
    return _profiles[userId];
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
    final updatedProfile = await _api.updateProfile(
      userId: userId,
      email: email,
      name: name,
      targetWeight: targetWeight,
      currentWeight: currentWeight,
      height: height,
      lastRecordedDateTime: lastRecordedDateTime,
    );
    _profiles[userId] = updatedProfile;
    _profileController.add(updatedProfile);
    return updatedProfile;
  }

  void dispose() {
    _profileController.close();
  }
}
