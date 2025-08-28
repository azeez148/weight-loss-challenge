class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final double? targetWeight;
  final double? currentWeight;
  final double? height;
  final DateTime? birthDate;
  final String? profileImageUrl;

  UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    this.targetWeight,
    this.currentWeight,
    this.height,
    this.birthDate,
    this.profileImageUrl,
  });

  double? get bmi {
    if (height == null || currentWeight == null) return null;
    final heightInMeters = height! / 100; // Convert cm to meters
    return currentWeight! / (heightInMeters * heightInMeters);
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    double? targetWeight,
    double? currentWeight,
    double? height,
    DateTime? birthDate,
    String? profileImageUrl,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      targetWeight: targetWeight ?? this.targetWeight,
      currentWeight: currentWeight ?? this.currentWeight,
      height: height ?? this.height,
      birthDate: birthDate ?? this.birthDate,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'targetWeight': targetWeight,
      'currentWeight': currentWeight,
      'height': height,
      'birthDate': birthDate?.toIso8601String(),
      'profileImageUrl': profileImageUrl,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String,
      targetWeight: map['targetWeight'] as double?,
      currentWeight: map['currentWeight'] as double?,
      height: map['height'] as double?,
      birthDate: map['birthDate'] != null ? DateTime.parse(map['birthDate'] as String) : null,
      profileImageUrl: map['profileImageUrl'] as String?,
    );
  }
}
