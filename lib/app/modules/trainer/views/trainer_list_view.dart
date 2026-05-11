import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/trainer_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../routes/app_routes.dart';

class TrainerListView extends GetView<TrainerController> {
  const TrainerListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih Trainer', style: AppTextStyles.headingSmall),
        backgroundColor: AppColors.background,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: controller.trainers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final t = controller.trainers[index];
          return GestureDetector(
            onTap: () {
              controller.selectTrainer(t);
              Get.toNamed(Routes.TRAINER_DETAIL);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surface2),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.surface2,
                    child: Icon(Icons.person, color: AppColors.textPrimary, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t['name'], style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(t['specialty'], style: AppTextStyles.bodySmall.copyWith(color: AppColors.accent)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.orange, size: 16),
                            const SizedBox(width: 4),
                            Text('${t['rating']}', style: AppTextStyles.bodySmall),
                            Text(' (${t['reviews']})', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                            const Spacer(),
                            Text(t['experience'], style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
