import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/membership_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/gym_button.dart';
import '../../../../core/widgets/gym_card.dart';
import '../../../routes/app_routes.dart';

class MembershipStatusView extends GetView<MembershipController> {
  const MembershipStatusView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Membership Saya', style: AppTextStyles.headingSmall),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 32),
            Text('Benefit Paket', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildBenefitList(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GymButton(
          text: 'Perpanjang Membership',
          onPressed: () => Get.toNamed(Routes.PACKAGES),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.surface2, AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.workspace_premium, color: AppColors.accent, size: 32),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: controller.isActive.value ? AppColors.success.withOpacity(0.2) : AppColors.error.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  controller.isActive.value ? 'AKTIF' : 'TIDAK AKTIF',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: controller.isActive.value ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(controller.packageName.value, style: AppTextStyles.headingSmall),
          const SizedBox(height: 8),
          Text('${controller.startDate.value} - ${controller.endDate.value}', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: controller.progressPercentage.value,
                    backgroundColor: AppColors.background,
                    color: AppColors.accent,
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${controller.remainingDays.value}', style: AppTextStyles.headingMedium.copyWith(color: AppColors.accent)),
                  Text('Hari lagi', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: TextButton(
              onPressed: () => Get.toNamed(Routes.MEMBERSHIP_HISTORY),
              child: Text('Lihat Riwayat Membership', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.accent)),
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildBenefitList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.benefits.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return GymCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 24),
              const SizedBox(width: 16),
              Expanded(child: Text(controller.benefits[index], style: AppTextStyles.bodyMedium)),
            ],
          ),
        );
      },
    );
  }
}
