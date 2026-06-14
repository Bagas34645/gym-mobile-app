import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../data/services/auth_service.dart';
import 'dart:developer';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();
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
    if (!loginFormKey.currentState!.validate()) {
      return;
    }
    try {
      isLoginLoading.value = true;

      await _authService.login(
        loginEmailController.text.trim(),
        loginPasswordController.text.trim(),
      );

      log('Login Sukses: ${loginEmailController.text}', name: 'AUTH');

      Get.snackbar(
        "Sukses",
        "Login Berhasil",
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.offAllNamed(Routes.HOME);
    } on FirebaseAuthException catch (e) {
      log('Login Failed: ${e.message}', name: 'AUTH', error: e);

      Get.snackbar(
        "Login Gagal",
        e.message ?? "Terjadi kesalahan",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoginLoading.value = false;
    }
  }

  Future<void> register() async {
    try {
      if (regPasswordController.text != regConfirmPasswordController.text) {
        Get.snackbar("Error", "Password tidak sama");
        return;
      }

      isRegisterLoading.value = true;

      final userCredential = await _authService.register(
        regEmailController.text.trim(),
        regPasswordController.text.trim(),
      );

      // simpan nama user
      await userCredential.user?.updateDisplayName(
        regNameController.text.trim(),
      );

      log('Register Success: ${regEmailController.text}', name: 'AUTH');

      Get.snackbar(
        "Sukses",
        "Registrasi berhasil",
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.offAllNamed(Routes.HOME);
    } on FirebaseAuthException catch (e) {
      log('Login Failed: ${e.message}', name: 'AUTH', error: e);

      Get.snackbar(
        "Register Gagal",
        e.message ?? "Terjadi kesalahan",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isRegisterLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      isLoginLoading.value = true;

      await _authService.signInWithGoogle();

      Get.snackbar("Sukses", "Login Google berhasil");

      Get.offAllNamed(Routes.HOME);
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Google Sign In Gagal", e.message ?? "Terjadi kesalahan");
    } finally {
      isLoginLoading.value = false;
    }
  }

  Future<void> sendResetPassword() async {
    try {
      isForgotLoading.value = true;

      await _authService.resetPassword(forgotEmailController.text.trim());

      Get.snackbar("Sukses", "Link reset password telah dikirim ke email");

      Get.offAllNamed(Routes.LOGIN);
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? "Terjadi kesalahan");
    } finally {
      isForgotLoading.value = false;
    }
  }

  void verifyOtp() async {
    isForgotLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isForgotLoading.value = false;
    currentStep.value = 3;
  }

  void resetPassword() async {
    isForgotLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isForgotLoading.value = false;
    Get.snackbar(
      "Sukses",
      "Password berhasil diubah",
      snackPosition: SnackPosition.BOTTOM,
    );
    Get.offAllNamed(Routes.LOGIN);
  }
}
