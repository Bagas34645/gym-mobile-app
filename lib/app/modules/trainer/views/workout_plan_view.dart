import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/workout_controller.dart';
import '../../../data/models/workout_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../routes/app_routes.dart';

class WorkoutPlanView extends GetView<WorkoutController> {
  const WorkoutPlanView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<WorkoutController>()) {
      Get.put(WorkoutController());
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Program Latihan', style: AppTextStyles.headingSmall),
        backgroundColor: AppColors.background,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.plans.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.plans.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.fitness_center,
                      color: AppColors.textSecondary, size: 64),
                  const SizedBox(height: 16),
                  Text('Belum ada program latihan',
                      style: AppTextStyles.headingSmall,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(
                    'Program akan muncul setelah trainer membuatkan untuk Anda.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.loadPlans,
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: controller.plans.length,
            itemBuilder: (context, index) {
              return _buildPlanCard(controller.plans[index]);
            },
          ),
        );
      }),
    );
  }

  Widget _buildPlanCard(WorkoutPlanModel plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        title: Text(plan.name, style: AppTextStyles.headingSmall),
        subtitle: Text(
            plan.goal ?? '${plan.exercises.length} latihan',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.accent)),
        iconColor: AppColors.accent,
        collapsedIconColor: AppColors.textSecondary,
        children: plan.exercises.isEmpty
            ? [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Belum ada latihan',
                      style: TextStyle(color: AppColors.textSecondary)),
                )
              ]
            : plan.exercises.map((ex) {
                return ListTile(
                  leading: const Icon(Icons.fitness_center,
                      color: AppColors.accent),
                  title: Text(ex.name, style: AppTextStyles.bodyLarge),
                  subtitle: Text('${ex.sets} Sets x ${ex.reps} Reps',
                      style: AppTextStyles.bodySmall),
                  trailing: IconButton(
                    icon: const Icon(Icons.play_circle_fill,
                        color: AppColors.accent, size: 32),
                    onPressed: () {
                      controller.startTracking(
                        exerciseName: ex.name,
                        totalSets: ex.sets,
                        planId: plan.id,
                      );
                      Get.toNamed(Routes.WORKOUT_TRACKING, arguments: {
                        'name': ex.name,
                        'sets': ex.sets,
                      });
                    },
                  ),
                );
              }).toList(),
      ),
    );
  }
}
