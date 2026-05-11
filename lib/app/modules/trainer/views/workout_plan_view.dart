import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/trainer_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../routes/app_routes.dart';

class WorkoutPlanView extends GetView<TrainerController> {
  const WorkoutPlanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Program Latihan', style: AppTextStyles.headingSmall),
        backgroundColor: AppColors.background,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: controller.workoutPlans.length,
        itemBuilder: (context, index) {
          final plan = controller.workoutPlans[index];
          final exercises = plan['exercises'] as List;
          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ExpansionTile(
              title: Text(plan['day'], style: AppTextStyles.headingSmall),
              subtitle: Text(plan['focus'], style: AppTextStyles.bodyMedium.copyWith(color: AppColors.accent)),
              iconColor: AppColors.accent,
              collapsedIconColor: AppColors.textSecondary,
              children: exercises.isEmpty
                  ? [const Padding(padding: EdgeInsets.all(16.0), child: Text('Hari Istirahat', style: TextStyle(color: AppColors.textSecondary)))]
                  : exercises.map((ex) {
                      return ListTile(
                        leading: const Icon(Icons.fitness_center, color: AppColors.accent),
                        title: Text(ex['name'], style: AppTextStyles.bodyLarge),
                        subtitle: Text('${ex['sets']} Sets x ${ex['reps']} Reps', style: AppTextStyles.bodySmall),
                        trailing: IconButton(
                          icon: const Icon(Icons.play_circle_fill, color: AppColors.accent, size: 32),
                          onPressed: () => Get.toNamed(Routes.WORKOUT_TRACKING, arguments: ex),
                        ),
                      );
                    }).toList(),
            ),
          );
        },
      ),
    );
  }
}
