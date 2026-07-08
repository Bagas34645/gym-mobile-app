import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/api_client.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/google_auth_service.dart';
import '../../../data/services/session_service.dart';
import '../../../data/services/token_storage.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  // Login State
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  var isLoginLoading = false.obs;
  var rememberMe = false.obs;
  var isGoogleLoading = false.obs;

  // Register State
  final regNameController = TextEditingController();
  final regEmailController = TextEditingController();
  final regPhoneController = TextEditingController();
  final regPasswordController = TextEditingController();
  final regConfirmPasswordController = TextEditingController();
  var isRegisterLoading = false.obs;
  var registerOtpEmail = ''.obs;
  var isRegisterOtpLoading = false.obs;

  // OTP register dan forgot password punya controller masing-masing.
  final regOtpController = TextEditingController();
  final forgotOtpController = TextEditingController();

  // Forgot Password State
  var currentStep = 1.obs;
  final forgotEmailController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();
  var isForgotLoading = false.obs;

  // Cooldown kirim ulang OTP (dipakai register & forgot password).
  var resendSeconds = 0.obs;
  Timer? _resendTimer;

  @override
  void onInit() {
    super.onInit();
    _loadRememberedIdentifier();
  }

  Future<void> _loadRememberedIdentifier() async {
    final saved = await TokenStorage.instance.rememberedIdentifier;
    if (saved != null && saved.isNotEmpty) {
      loginEmailController.text = saved;
      rememberMe.value = true;
    }
  }

  @override
  void onClose() {
    // Binding memakai fenix:true, jadi controller akan di-recreate otomatis
    // bila dibutuhkan lagi. Resource tetap wajib dilepas di sini.
    _resendTimer?.cancel();
    loginEmailController.dispose();
    loginPasswordController.dispose();
    regNameController.dispose();
    regEmailController.dispose();
    regPhoneController.dispose();
    regPasswordController.dispose();
    regConfirmPasswordController.dispose();
    regOtpController.dispose();
    forgotOtpController.dispose();
    forgotEmailController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.onClose();
  }

  String get resendLabel {
    final s = resendSeconds.value;
    final mm = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return 'Kirim ulang dalam $mm:$ss';
  }

  void _startResendCooldown([int seconds = 60]) {
    _resendTimer?.cancel();
    resendSeconds.value = seconds;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds.value <= 1) {
        resendSeconds.value = 0;
        timer.cancel();
      } else {
        resendSeconds.value -= 1;
      }
    });
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
      if (rememberMe.value) {
        await TokenStorage.instance.saveRememberedIdentifier(identifier);
      } else {
        await TokenStorage.instance.clearRememberedIdentifier();
      }
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
      final result = await AuthService.instance.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: confirm,
      );
      registerOtpEmail.value = email;
      regOtpController.clear();
      _startResendCooldown(result.expiresIn);
      Get.toNamed(Routes.REGISTER_OTP, arguments: {'email': email});
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Gagal mendaftar. Coba lagi.');
    } finally {
      isRegisterLoading.value = false;
    }
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
      forgotOtpController.clear();
      _startResendCooldown();
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
    final code = forgotOtpController.text.trim();
    if (!_isValidOtp(code)) return;
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

  Future<void> verifyRegistrationOtp() async {
    final code = regOtpController.text.trim();
    if (!_isValidOtp(code)) return;
    if (registerOtpEmail.value.isEmpty) {
      _showError('Email pendaftar tidak ditemukan. Silakan daftar ulang.');
      return;
    }
    isRegisterOtpLoading.value = true;
    try {
      await AuthService.instance.verifyOtp(
        identifier: registerOtpEmail.value,
        code: code,
      );
      _showInfo('Sukses', 'OTP terverifikasi. Silakan masuk.');
      await Future.delayed(const Duration(seconds: 2));
      registerOtpEmail.value = '';
      regOtpController.clear();
      Get.offAllNamed(Routes.LOGIN);
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Verifikasi gagal. Coba lagi.');
    } finally {
      isRegisterOtpLoading.value = false;
    }
  }

  Future<void> resendRegistrationOtp() async {
    if (resendSeconds.value > 0) return;
    if (registerOtpEmail.value.isEmpty) {
      _showError('Email pendaftar tidak ditemukan. Silakan daftar ulang.');
      return;
    }
    isRegisterOtpLoading.value = true;
    try {
      await AuthService.instance.resendOtp(identifier: registerOtpEmail.value);
      regOtpController.clear();
      _startResendCooldown();
      _showInfo('Kode dikirim', 'Kode OTP baru telah dikirim ke email Anda.');
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Gagal mengirim ulang OTP. Coba lagi.');
    } finally {
      isRegisterOtpLoading.value = false;
    }
  }

  Future<void> resendForgotOtp() async {
    if (resendSeconds.value > 0) return;
    await sendOtp();
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
        // ✅ Pakai forgotOtpController
        code: forgotOtpController.text.trim(),
        password: password,
        passwordConfirmation: confirm,
      );
      _showInfo('Sukses', 'Password berhasil diubah. Silakan masuk.');
      // ✅ Tunggu snackbar muncul dulu, lalu delete controller dan navigasi
      await Future.delayed(const Duration(seconds: 2));
      _resetForgotState();
      Get.offAllNamed(Routes.LOGIN);
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Gagal mengubah password. Coba lagi.');
    } finally {
      isForgotLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    isGoogleLoading.value = true;
    try {
      final idToken = await GoogleAuthService.instance.signInAndGetIdToken();
      if (idToken == null) {
        // idToken null berarti user membatalkan dialog pilih akun.
        return;
      }
      await AuthService.instance.googleLogin(idToken: idToken);
      await _loadSessionAndGoHome();
    } on GoogleSignInException catch (e) {
      _showError(e.message);
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Gagal login dengan Google. Coba lagi.');
    } finally {
      isGoogleLoading.value = false;
    }
  }

  Future<void> _loadSessionAndGoHome() async {
    try {
      await SessionService.to.loadProfile();
    } catch (_) {}
    Get.offAllNamed(Routes.HOME);
  }

  bool _isValidOtp(String code) {
    if (code.isEmpty) {
      _showError('Masukkan kode OTP');
      return false;
    }
    if (code.length != 6 || int.tryParse(code) == null) {
      _showError('Kode OTP harus 6 digit angka');
      return false;
    }
    return true;
  }

  void _resetForgotState() {
    _resendTimer?.cancel();
    resendSeconds.value = 0;
    currentStep.value = 1;
    forgotEmailController.clear();
    forgotOtpController.clear();
    newPasswordController.clear();
    confirmNewPasswordController.clear();
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
}
