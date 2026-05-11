import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/gym_button.dart';
import '../../../../core/widgets/gym_text_field.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Buat Akun Baru', style: AppTextStyles.headingSmall),
            const SizedBox(height: 8),
            Text('Bergabunglah dan mulai perjalanan fitness-mu', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 32),
            GymTextField(
              label: 'Nama Lengkap',
              hint: 'Masukkan nama lengkap',
              prefixIcon: Icons.person_outline,
              controller: controller.regNameController,
            ),
            const SizedBox(height: 16),
            GymTextField(
              label: 'Email',
              hint: 'Masukkan alamat email',
              prefixIcon: Icons.email_outlined,
              controller: controller.regEmailController,
            ),
            const SizedBox(height: 16),
            GymTextField(
              label: 'Nomor HP',
              hint: 'Masukkan nomor HP',
              prefixIcon: Icons.phone_outlined,
              controller: controller.regPhoneController,
            ),
            const SizedBox(height: 16),
            GymTextField(
              label: 'Password',
              hint: 'Buat password',
              prefixIcon: Icons.lock_outline,
              isPassword: true,
              controller: controller.regPasswordController,
            ),
            const SizedBox(height: 16),
            GymTextField(
              label: 'Konfirmasi Password',
              hint: 'Masukkan ulang password',
              prefixIcon: Icons.lock_outline,
              isPassword: true,
              controller: controller.regConfirmPasswordController,
            ),
            const SizedBox(height: 32),
            Obx(() => GymButton(
              text: 'Daftar Sekarang',
              isLoading: controller.isRegisterLoading.value,
              onPressed: controller.register,
            )),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('atau daftar dengan', style: AppTextStyles.bodySmall),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.g_mobiledata, size: 32, color: Colors.white),
                label: Text('Google', style: AppTextStyles.button.copyWith(color: Colors.white)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.divider),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                ),
                onPressed: () {},
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Sudah punya akun? ', style: AppTextStyles.bodyMedium),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Text('Masuk', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.accent, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
