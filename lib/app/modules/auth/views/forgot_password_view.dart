import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/gym_button.dart';
import '../../../../core/widgets/gym_text_field.dart';

class ForgotPasswordView extends GetView<AuthController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.currentStep.value == 1) {
          return _buildStep1();
        } else if (controller.currentStep.value == 2) {
          return _buildStep2();
        } else {
          return _buildStep3();
        }
      }),
    );
  }

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reset Password', style: AppTextStyles.headingSmall),
          const SizedBox(height: 8),
          Text('Masukkan email atau nomor HP yang terdaftar', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 32),
          GymTextField(
            label: 'Email / Nomor HP',
            hint: 'Masukkan email atau nomor HP',
            prefixIcon: Icons.email_outlined,
            controller: controller.forgotEmailController,
          ),
          const SizedBox(height: 32),
          GymButton(
            text: 'Kirim Kode OTP',
            isLoading: controller.isForgotLoading.value,
            onPressed: controller.sendResetPassword,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Masukkan Kode OTP', style: AppTextStyles.headingSmall),
          const SizedBox(height: 8),
          Text('Kode OTP telah dikirimkan ke email/HP Anda', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 32),
          GymTextField(
            label: 'Kode OTP',
            hint: 'Masukkan 6 digit kode',
            prefixIcon: Icons.lock_clock_outlined,
            controller: controller.otpController,
          ),
          const SizedBox(height: 16),
          Center(
            child: Text('Kirim ulang dalam 00:59', style: AppTextStyles.bodySmall),
          ),
          const SizedBox(height: 32),
          GymButton(
            text: 'Verifikasi',
            isLoading: controller.isForgotLoading.value,
            onPressed: controller.verifyOtp,
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Buat Password Baru', style: AppTextStyles.headingSmall),
          const SizedBox(height: 8),
          Text('Silakan buat password baru untuk akun Anda', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 32),
          GymTextField(
            label: 'Password Baru',
            hint: 'Masukkan password baru',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            controller: controller.newPasswordController,
          ),
          const SizedBox(height: 16),
          GymTextField(
            label: 'Konfirmasi Password',
            hint: 'Masukkan ulang password baru',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            controller: controller.confirmNewPasswordController,
          ),
          const SizedBox(height: 32),
          GymButton(
            text: 'Simpan Password',
            isLoading: controller.isForgotLoading.value,
            onPressed: controller.resetPassword,
          ),
        ],
      ),
    );
  }
}
