import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/trainer_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/gym_button.dart';
import '../../../../core/widgets/gym_text_field.dart';

class WorkoutTrackingView extends GetView<TrainerController> {
  const WorkoutTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final exerciseName = args?['name'] ?? 'Latihan';
    final sets = args?['sets'] ?? '3';

    final weightController = TextEditingController();
    final repsController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Tracking Latihan', style: AppTextStyles.headingSmall),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.fitness_center, size: 80, color: AppColors.accent),
            const SizedBox(height: 24),
            Text(exerciseName, style: AppTextStyles.headingMedium),
            const SizedBox(height: 8),
            Text('Target: $sets Sets', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 48),
            
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Obx(() => Column(
                children: [
                  Text('SET ${controller.currentSet.value}', style: AppTextStyles.headingSmall.copyWith(color: AppColors.accent)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: GymTextField(
                          label: 'Berat (kg)',
                          hint: '0',
                          controller: weightController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GymTextField(
                          label: 'Repetisi',
                          hint: '0',
                          controller: repsController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  GymButton(
                    text: 'Selesaikan Set',
                    onPressed: () {
                      controller.logSet(weightController.text, repsController.text);
                      weightController.clear();
                      repsController.clear();
                    },
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }
}
