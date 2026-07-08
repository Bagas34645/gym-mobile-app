import 'dart:io';

import 'package:get/get.dart';

import '../models/user_model.dart';
import 'auth_service.dart';
import 'token_storage.dart';

/// App-wide holder for the authenticated member. Kept permanently in memory
/// (registered in `main`) so any screen can read the current profile reactively.
class SessionService extends GetxService {
  static SessionService get to => Get.find<SessionService>();

  final Rxn<UserModel> user = Rxn<UserModel>();

  UserModel? get currentUser => user.value;

  Future<bool> hasSession() => TokenStorage.instance.hasSession;

  /// Loads (or refreshes) the profile from `GET /auth/me`.
  Future<UserModel?> loadProfile() async {
    final data = await AuthService.instance.me();
    if (data.isEmpty) return null;
    final model = UserModel.fromJson(data);
    user.value = model;
    return model;
  }

  Future<UserModel?> updateProfile({
    String? name,
    int? age,
    int? heightCm,
    double? weightKg,
    String? fitnessGoal,
    File? photo,
  }) async {
    final data = await AuthService.instance.updateProfile(
      name: name,
      age: age,
      heightCm: heightCm,
      weightKg: weightKg,
      fitnessGoal: fitnessGoal,
      photo: photo,
    );
    if (data.isNotEmpty) {
      user.value = UserModel.fromJson(data);
    }
    return user.value;
  }

  Future<void> clearSession() async {
    await TokenStorage.instance.clear();
    user.value = null;
  }
}
