import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/api_client.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/session_service.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  // Login State
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  var isLoginLoading = false.obs;
  var rememberMe = false.obs;

  // Register State
  final regNameController = TextEditingController();
  final regEmailController = TextEditingController();
  final regPhoneController = TextEditingController();
  final regPasswordController = TextEditingController();
  final regConfirmPasswordController = TextEditingController();
  var isRegisterLoading = false.obs;

  // Forgot Password State
  var currentStep = 1.obs; // 1: Email, 2: OTP, 3: New Password
  final forgotEmailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();
  var isForgotLoading = false.obs;

  @override
  void onClose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    regNameController.dispose();
    regEmailController.dispose();
    regPhoneController.dispose();
    regPasswordController.dispose();
    regConfirmPasswordController.dispose();
    forgotEmailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.onClose();
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  Future<void> login() async {
    final identifier = loginEmailController.text.trim();
    final password = loginPasswordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      _showError('Email/no. HP dan password wajib diisi');
      return;
    }

    isLoginLoading.value = true;
    try {
      await AuthService.instance.login(
        identifier: identifier,
        password: password,
      );
      await _loadSessionAndGoHome();
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Gagal masuk. Coba lagi.');
    } finally {
      isLoginLoading.value = false;
    }
  }

  Future<void> register() async {
    final name = regNameController.text.trim();
    final email = regEmailController.text.trim();
    final phone = regPhoneController.text.trim();
    final password = regPasswordController.text;
    final confirm = regConfirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      _showError('Semua data wajib diisi');
      return;
    }
    if (!RegExp(r'^08\d{8,11}$').hasMatch(phone)) {
      _showError('Nomor HP harus format Indonesia (cth: 081234567890)');
      return;
    }
    if (password.length < 8) {
      _showError('Password minimal 8 karakter');
      return;
    }
    if (password != confirm) {
      _showError('Konfirmasi password tidak cocok');
      return;
    }

    isRegisterLoading.value = true;
    try {
      // The API does not return tokens on register, so log in right after.
      await AuthService.instance.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: confirm,
      );
      await AuthService.instance.login(
        identifier: email,
        password: password,
      );
      await _loadSessionAndGoHome();
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Gagal mendaftar. Coba lagi.');
    } finally {
      isRegisterLoading.value = false;
    }
  }

  Future<void> _loadSessionAndGoHome() async {
    try {
      await SessionService.to.loadProfile();
    } catch (_) {
      // Non-fatal: the home screen will retry loading the profile.
    }
    Get.offAllNamed(Routes.HOME);
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

  Future<void> sendOtp() async {
    final identifier = forgotEmailController.text.trim();
    if (identifier.isEmpty) {
      _showError('Masukkan email atau nomor HP');
      return;
    }
    isForgotLoading.value = true;
    try {
      await AuthService.instance.forgotPassword(identifier: identifier);
      currentStep.value = 2;
      _showInfo('Kode terkirim', 'Kode OTP telah dikirim ke email/HP Anda.');
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Gagal mengirim OTP. Coba lagi.');
    } finally {
      isForgotLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    final code = otpController.text.trim();
    if (code.isEmpty) {
      _showError('Masukkan kode OTP');
      return;
    }
    isForgotLoading.value = true;
    try {
      await AuthService.instance.verifyOtp(
        identifier: forgotEmailController.text.trim(),
        code: code,
      );
      currentStep.value = 3;
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Verifikasi gagal. Coba lagi.');
    } finally {
      isForgotLoading.value = false;
    }
  }

  Future<void> resetPassword() async {
    final password = newPasswordController.text;
    final confirm = confirmNewPasswordController.text;
    if (password.length < 8) {
      _showError('Password minimal 8 karakter');
      return;
    }
    if (password != confirm) {
      _showError('Konfirmasi password tidak cocok');
      return;
    }
    isForgotLoading.value = true;
    try {
      await AuthService.instance.resetPassword(
        identifier: forgotEmailController.text.trim(),
        code: otpController.text.trim(),
        password: password,
        passwordConfirmation: confirm,
      );
      _showInfo('Sukses', 'Password berhasil diubah. Silakan masuk.');
      Get.offAllNamed(Routes.LOGIN);
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Gagal mengubah password. Coba lagi.');
    } finally {
      isForgotLoading.value = false;
    }
  }
}
