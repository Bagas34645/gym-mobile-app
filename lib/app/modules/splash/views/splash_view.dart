import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Icon(
              Icons.fitness_center,
              size: 80,
              color: AppColors.accent,
            ),
            const SizedBox(height: 16),
            Text(
              'GYMFLOW',
              style: AppTextStyles.headingLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Train Smarter. Track Better.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const Spacer(),
            const SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                color: AppColors.accent,
                backgroundColor: AppColors.surface2,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
