import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_routes.dart';
import 'dart:developer';

class ProfileController extends GetxController {
  final AuthService _authService = AuthService();

  var name = ''.obs;
  var email = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  void loadUserProfile() {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // DISPLAY NAME
      name.value = user.displayName ?? 'User';

      // EMAIL
      email.value = user.email ?? '-';
    }
  }

  Future<void> updateName(String newName) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await user.updateDisplayName(newName);

      await user.reload();

      name.value = newName;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.offAllNamed(Routes.LOGIN);

      log('User Logout', name: 'AUTH');

      Get.snackbar(
        'Berhasil',
        'Logout berhasil',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Logout gagal',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
