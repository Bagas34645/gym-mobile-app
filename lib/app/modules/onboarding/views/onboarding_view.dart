import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/onboarding_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/gym_button.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: controller.skip,
                child: Text('Lewati', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.accent)),
              ),
            ),
            Expanded(
              child: PageView(
                onPageChanged: controller.onPageChanged,
                children: [
                  _buildSlide(
                    icon: Icons.fitness_center,
                    title: 'Kelola Membership Mudah',
                    description: 'Atur paket langganan dan pantau masa aktif membership Anda secara langsung dari aplikasi.',
                  ),
                  _buildSlide(
                    icon: Icons.qr_code_scanner,
                    title: 'Check-in Tanpa Antri',
                    description: 'Gunakan fitur face recognition atau QR Code untuk check-in gym dengan cepat.',
                  ),
                  _buildSlide(
                    icon: Icons.auto_graph,
                    title: 'Pantau Progres Harianmu',
                    description: 'Catat latihan dan berat badan, lalu pantau perkembangan Anda melalui grafik.',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: controller.currentPage.value == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: controller.currentPage.value == index ? AppColors.accent : AppColors.surface2,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  )),
                  const SizedBox(height: 32),
                  Obx(() {
                    if (controller.currentPage.value == 2) {
                      return GymButton(
                        text: 'Mulai Sekarang',
                        onPressed: controller.start,
                      );
                    }
                    return const SizedBox(height: 56);
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide({required IconData icon, required String title, required String description}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 120, color: AppColors.accent),
          const SizedBox(height: 48),
          Text(title, style: AppTextStyles.headingSmall, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(description, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
