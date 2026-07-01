import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/gym_button.dart';
import '../../../../core/widgets/gym_text_field.dart';

class RegisterOtpView extends GetView<AuthController> {
  const RegisterOtpView({super.key});
  @override
  Widget build(BuildContext context) {
    final argEmail = Get.arguments is Map
        ? (Get.arguments as Map)['email'] as String?
        : null;
    // Sinkronkan email dari argument tanpa memutasi observable saat build.
    if (argEmail != null &&
        argEmail.isNotEmpty &&
        controller.registerOtpEmail.value != argEmail) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.registerOtpEmail.value = argEmail;
      });
    }
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
            Text('Verifikasi Email', style: AppTextStyles.headingSmall),
            const SizedBox(height: 8),
            Obx(() {
              final email = controller.registerOtpEmail.value;
              return Text(
                'Kami telah mengirim kode OTP ke ${email.isEmpty ? 'email Anda' : email}.\nMasukkan kode tersebut untuk menyelesaikan pendaftaran.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              );
            }),
            const SizedBox(height: 32),
            GymTextField(
              label: 'Kode OTP',
              hint: 'Masukkan 6 digit kode',
              prefixIcon: Icons.lock_clock_outlined,
              controller: controller.regOtpController,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak menerima kode? Periksa folder spam atau coba lagi beberapa saat.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            Obx(
              () => GymButton(
                text: 'Verifikasi OTP',
                isLoading: controller.isRegisterOtpLoading.value,
                onPressed: controller.verifyRegistrationOtp,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Obx(() {
                if (controller.resendSeconds.value > 0) {
                  return Text(
                    controller.resendLabel,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  );
                }
                return GestureDetector(
                  onTap: controller.resendRegistrationOtp,
                  child: Text(
                    'Kirim ulang kode',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
