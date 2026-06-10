import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/trainer_controller.dart';
import '../../../data/models/trainer_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';

class TrainerDetailView extends GetView<TrainerController> {
  const TrainerDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Trainer', style: AppTextStyles.headingSmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        final t = controller.selectedTrainer.value;
        if (t == null) return const Center(child: Text('Tidak ada data'));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.surface2,
                      child: Icon(Icons.person, color: AppColors.textPrimary, size: 50),
                    ),
                    const SizedBox(height: 16),
                    Text(t.name, style: AppTextStyles.headingMedium),
                    const SizedBox(height: 4),
                    Text(t.specialization, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.accent)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem(Icons.star, t.averageRating.toStringAsFixed(1), 'Rating'),
                  _buildStatItem(Icons.work, '${t.experienceYears} Th', 'Pengalaman'),
                  _buildStatItem(Icons.payments, formatRupiah(t.hourlyRate), 'Per Sesi'),
                ],
              ),
              const SizedBox(height: 32),
              Text('Tentang', style: AppTextStyles.headingSmall),
              const SizedBox(height: 8),
              Text(
                (t.bio?.isNotEmpty ?? false)
                    ? t.bio!
                    : 'Belum ada deskripsi untuk trainer ini.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary, height: 1.5),
              ),
              if (t.certification != null && t.certification!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.verified, color: AppColors.accent, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(t.certification!,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textSecondary)),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 32),
              Text('Jadwal Tersedia', style: AppTextStyles.headingSmall),
              const SizedBox(height: 16),
              if (controller.isLoadingDetail.value)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (t.schedules.isEmpty)
                Text('Tidak ada jadwal tersedia',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary))
              else
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: t.schedules
                      .where((s) => s.status == 'active')
                      .map((s) {
                    return ActionChip(
                      label: Text(s.label, style: AppTextStyles.bodyMedium),
                      backgroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: AppColors.accent),
                      ),
                      onPressed: () => _confirmBooking(context, s),
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accent, size: 28),
        const SizedBox(height: 8),
        Text(value, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }

  void _confirmBooking(BuildContext context, TrainerSchedule schedule) {
    Get.defaultDialog(
      title: 'Konfirmasi Booking',
      titleStyle: AppTextStyles.headingSmall,
      middleText:
          'Pesan sesi pada ${schedule.dayName}, ${schedule.timeRange}?',
      middleTextStyle: AppTextStyles.bodyMedium,
      backgroundColor: AppColors.surface,
      textConfirm: 'Ya',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      cancelTextColor: AppColors.accent,
      buttonColor: AppColors.accent,
      onConfirm: () {
        Get.back(); // close dialog
        controller.bookSchedule(schedule);
      },
    );
  }
}
