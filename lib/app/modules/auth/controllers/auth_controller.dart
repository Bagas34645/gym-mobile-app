import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym_mobile_flutter/app/data/services/google_auth_service.dart';
// import 'package:gym_mobile_flutter/app/data/services/token_storage.dart';
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

  // ✅ Pisah OTP controller: register punya sendiri, forgot password punya sendiri
  final regOtpController = TextEditingController();
  final forgotOtpController = TextEditingController();

  // Forgot Password State
  var currentStep = 1.obs;
  final forgotEmailController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();
  var isForgotLoading = false.obs;

  @override
  void onClose() {
    // loginEmailController.dispose();
    // loginPasswordController.dispose();
    // regNameController.dispose();
    // regEmailController.dispose();
    // regPhoneController.dispose();
    // regPasswordController.dispose();
    // regConfirmPasswordController.dispose();
    // ✅ Dispose keduanya
    // regOtpController.dispose();
    // forgotOtpController.dispose();
    // forgotEmailController.dispose();
    // newPasswordController.dispose();
    // confirmNewPasswordController.dispose();
    super.onClose();
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  Future<void> login() async {
    final identifier = loginEmailController.text.trim();
    final password = loginPasswordController.text;

    // 🔍 Debug sementara
    // print('DEBUG LOGIN - identifier: "$identifier"');
    // print('DEBUG LOGIN - password: "$password"');
    // print(
    //   'DEBUG LOGIN - controller hashCode: ${loginEmailController.hashCode}',
    // );

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
      await AuthService.instance.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: confirm,
      );
      registerOtpEmail.value = email;
      // ✅ Clear OTP register saat navigasi ke halaman OTP
      regOtpController.clear();
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
      // ✅ Clear OTP forgot saat step berpindah
      forgotOtpController.clear();
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
    // ✅ Pakai forgotOtpController
    final code = forgotOtpController.text.trim();
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

  Future<void> verifyRegistrationOtp() async {
    // ✅ Pakai regOtpController
    final code = regOtpController.text.trim();
    if (code.isEmpty) {
      _showError('Masukkan kode OTP');
      return;
    }
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
    if (registerOtpEmail.value.isEmpty) {
      _showError('Email pendaftar tidak ditemukan. Silakan daftar ulang.');
      return;
    }
    isRegisterOtpLoading.value = true;
    try {
      await AuthService.instance.resendOtp(identifier: registerOtpEmail.value);
      // ✅ Clear regOtpController saat resend
      regOtpController.clear();
      _showInfo('Kode dikirim', 'Kode OTP baru telah dikirim ke email Anda.');
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Gagal mengirim ulang OTP. Coba lagi.');
    } finally {
      isRegisterOtpLoading.value = false;
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

  // Tambah method
  Future<void> loginWithGoogle() async {
    isGoogleLoading.value = true;
    try {
      final idToken = await GoogleAuthService.instance.signInAndGetIdToken();
      if (idToken == null) {
        _showError('Login Google dibatalkan.');
        return;
      }
      await AuthService.instance.googleLogin(idToken: idToken);
      await _loadSessionAndGoHome();
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Gagal login dengan Google. Coba lagi.');
    } finally {
      isGoogleLoading.value = false;
    }
  }

  // Future<void> googleLogin({required String idToken}) async {
  //   final body = await _api.post(
  //     '/auth/login/google',
  //     data: {'id_token': idToken},
  //     skipAuth: true,
  //   );
  //   final data = body['data'] as Map<String, dynamic>;
  //   await TokenStorage.instance.saveTokens(
  //     accessToken: data['access_token'] as String,
  //     refreshToken: data['refresh_token'] as String,
  //   );
  // }

  Future<void> _loadSessionAndGoHome() async {
    try {
      await SessionService.to.loadProfile();
    } catch (_) {}
    Get.offAllNamed(Routes.HOME);
  }

  void _resetForgotState() {
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
