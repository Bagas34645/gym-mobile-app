import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    isLoginLoading.value = true;
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
    isLoginLoading.value = false;
    Get.offAllNamed(Routes.HOME);
  }

  Future<void> register() async {
    isRegisterLoading.value = true;
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
    isRegisterLoading.value = false;
    Get.offAllNamed(Routes.HOME);
  }

  void sendOtp() async {
    isForgotLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isForgotLoading.value = false;
    currentStep.value = 2;
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
    Get.snackbar("Sukses", "Password berhasil diubah", snackPosition: SnackPosition.BOTTOM);
    Get.offAllNamed(Routes.LOGIN);
  }
}
