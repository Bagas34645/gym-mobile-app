import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/gym_button.dart';
import '../../../../core/widgets/gym_text_field.dart';
import '../../../routes/app_routes.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Icon(
                  Icons.fitness_center,
                  size: 60,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text('GYMFLOW', style: AppTextStyles.headingMedium),
              ),
              const SizedBox(height: 40),
              Text(
                'Selamat Datang Kembali 👊',
                style: AppTextStyles.headingSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Silakan masuk untuk melanjutkan',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              GymTextField(
                label: 'Email / Nomor HP',
                hint: 'Masukkan email atau nomor HP',
                prefixIcon: Icons.person_outline,
                controller: controller.loginEmailController,
              ),
              const SizedBox(height: 16),
              GymTextField(
                label: 'Password',
                hint: 'Masukkan password',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                controller: controller.loginPasswordController,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                    () => Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: controller.rememberMe.value,
                            onChanged: (_) => controller.toggleRememberMe(),
                            activeColor: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('Ingat Saya', style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed(Routes.FORGOT_PASSWORD),
                    child: Text(
                      'Lupa Password?',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Obx(
                () => GymButton(
                  text: 'Masuk',
                  isLoading: controller.isLoginLoading.value,
                  onPressed: controller.login,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('atau', style: AppTextStyles.bodySmall),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    icon: controller.isGoogleLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.g_mobiledata,
                            size: 32,
                            color: Colors.white,
                          ),
                    label: Text(
                      'Lanjutkan dengan Google',
                      style: AppTextStyles.button.copyWith(color: Colors.white),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.divider),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    // ✅ Hubungkan ke method
                    onPressed: controller.isGoogleLoading.value
                        ? null
                        : controller.loginWithGoogle,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Belum punya akun? ', style: AppTextStyles.bodyMedium),
                  GestureDetector(
                    onTap: () => Get.toNamed(Routes.REGISTER),
                    child: Text(
                      'Daftar',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
