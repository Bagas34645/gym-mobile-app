import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/api_client.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/session_service.dart';
import '../../../routes/app_routes.dart';

class ProfileController extends GetxController {
  final SessionService _session = SessionService.to;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  Rxn<UserModel> get user => _session.user;

  // Edit profile form
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final goalController = TextEditingController();

  // Change password form
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    if (_session.currentUser == null) {
      refreshProfile();
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    goalController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> refreshProfile() async {
    isLoading.value = true;
    try {
      await _session.loadProfile();
    } catch (_) {
      // ignore; UI shows whatever is cached
    } finally {
      isLoading.value = false;
    }
  }

  void _syncEditForm() {
    final u = _session.currentUser;
    nameController.text = u?.name ?? '';
    ageController.text = u?.age?.toString() ?? '';
    heightController.text = u?.heightCm?.toString() ?? '';
    weightController.text = u?.weightKg?.toString() ?? '';
    goalController.text = u?.fitnessGoal ?? '';
  }

  void prepareEditForm() => _syncEditForm();

  Future<void> saveProfile() async {
    isSaving.value = true;
    try {
      await _session.updateProfile(
        name: nameController.text.trim().isEmpty
            ? null
            : nameController.text.trim(),
        age: int.tryParse(ageController.text.trim()),
        heightCm: int.tryParse(heightController.text.trim()),
        weightKg: double.tryParse(weightController.text.trim()),
        fitnessGoal: goalController.text.trim().isEmpty
            ? null
            : goalController.text.trim(),
      );
      Get.back();
      _showInfo('Berhasil', 'Profil berhasil diperbarui');
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Gagal memperbarui profil');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> savePassword() async {
    if (newPasswordController.text.length < 8) {
      _showError('Password baru minimal 8 karakter');
      return;
    }
    if (newPasswordController.text != confirmPasswordController.text) {
      _showError('Konfirmasi password tidak cocok');
      return;
    }
    isSaving.value = true;
    try {
      await AuthService.instance.changePassword(
        currentPassword: currentPasswordController.text,
        password: newPasswordController.text,
        passwordConfirmation: confirmPasswordController.text,
      );
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      Get.back();
      _showInfo('Berhasil', 'Password berhasil diubah');
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Gagal mengubah password');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> logout() async {
    await AuthService.instance.logout();
    _session.clear();
    Get.offAllNamed(Routes.LOGIN);
  }

  void _showInfo(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Gagal',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFEF4444),
      colorText: Colors.white,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }
}
