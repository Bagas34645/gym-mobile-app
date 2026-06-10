import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/membership_controller.dart';
import '../../../data/models/membership_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';

class MembershipHistoryView extends GetView<MembershipController> {
  const MembershipHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Membership', style: AppTextStyles.headingSmall),
        backgroundColor: AppColors.background,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.historyList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.historyList.isEmpty) {
          return Center(
            child: Text('Belum ada riwayat membership',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: controller.historyList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 24),
          itemBuilder: (context, index) {
            final item = controller.historyList[index];
            final isLast = index == controller.historyList.length - 1;
            return _buildTimelineItem(item, isLast);
          },
        );
      }),
    );
  }

  Widget _buildTimelineItem(MembershipHistoryEntry item, bool isLast) {
    final approved = item.status == 'approved';
    final rejected = item.status == 'rejected';
    final statusColor = approved
        ? AppColors.success
        : (rejected ? AppColors.error : AppColors.accent);
    final statusLabel = approved
        ? 'Disetujui'
        : (rejected ? 'Ditolak' : 'Menunggu');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: statusColor,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 120,
                color: AppColors.surface2,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(item.packageName,
                            style: AppTextStyles.bodyLarge
                                .copyWith(fontWeight: FontWeight.bold))),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusLabel,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Berlaku hingga ${formatDateShort(item.newEndDate)}',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Text(formatRupiah(item.amountPaid),
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.accent, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
