import 'parse_utils.dart';

/// Mirrors the `GET /auth/me` payload.
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? profilePhotoUrl;
  final int? age;
  final int? heightCm;
  final double? weightKg;
  final String? fitnessGoal;
  final String membershipStatus;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role = 'member',
    this.profilePhotoUrl,
    this.age,
    this.heightCm,
    this.weightKg,
    this.fitnessGoal,
    this.membershipStatus = 'inactive',
  });

  bool get isMembershipActive => membershipStatus == 'active';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: json['role']?.toString() ?? 'member',
      profilePhotoUrl: json['profile_photo_url']?.toString(),
      age: asInt(json['age']),
      heightCm: asInt(json['height_cm']),
      weightKg: asDouble(json['weight_kg']),
      fitnessGoal: json['fitness_goal']?.toString(),
      membershipStatus: json['membership_status']?.toString() ?? 'inactive',
    );
  }

  UserModel copyWith({
    String? name,
    String? profilePhotoUrl,
    int? age,
    int? heightCm,
    double? weightKg,
    String? fitnessGoal,
    String? membershipStatus,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone,
      role: role,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      membershipStatus: membershipStatus ?? this.membershipStatus,
    );
  }
}
