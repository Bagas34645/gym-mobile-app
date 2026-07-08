import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/membership_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/gym_button.dart';
import '../../../../core/widgets/gym_card.dart';
import '../../../routes/app_routes.dart';

class RenewalView extends GetView<MembershipController> {
  const RenewalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perpanjang Membership', style: AppTextStyles.headingSmall),
        backgroundColor: AppColors.background,
      ),
      body: Obx(() {
        if (controller.renewalStep.value == 1) return _buildStep1();
        if (controller.renewalStep.value == 2) return _buildStep2();
        return _buildStep3();
      }),
      bottomNavigationBar: Obx(() {
        if (controller.renewalStep.value == 3) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: GymButton(
            text: controller.renewalStep.value == 1
                ? 'Lanjutkan Pembayaran'
                : 'Bayar Sekarang',
            onPressed: controller.nextRenewalStep,
          ),
        );
      }),
    );
  }

  Widget _buildStep1() {
    final pkg = controller.selectedPackageForRenewal;
    if (pkg == null) {
      return const Center(child: Text('Tidak ada paket terpilih'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Konfirmasi Paket', style: AppTextStyles.headingSmall),
          const SizedBox(height: 24),
          GymCard(
            highlighted: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pkg.name, style: AppTextStyles.headingSmall),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatRupiah(pkg.price),
                      style: AppTextStyles.headingMedium
                          .copyWith(color: AppColors.accent),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6.0, left: 4.0),
                      child: Text(
                        controller.periodLabel(pkg),
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Durasi ${pkg.durationDays} hari',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    final pkg = controller.selectedPackageForRenewal!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ringkasan Order', style: AppTextStyles.headingSmall),
          const SizedBox(height: 16),
          GymCard(
            child: Column(
              children: [
                _buildSummaryRow('Paket', pkg.name),
                const SizedBox(height: 12),
                _buildSummaryRow('Periode', '${pkg.durationDays} Hari'),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                _buildSummaryRow(
                  'Total Pembayaran',
                  formatRupiah(pkg.price),
                  isTotal: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text('Metode Pembayaran', style: AppTextStyles.headingSmall),
          const SizedBox(height: 16),
          _buildPaymentMethodOption(
            'Bayar Online (Midtrans)',
            Icons.payment,
            'midtrans',
          ),
          const SizedBox(height: 12),
          _buildPaymentMethodOption(
            'Tunai (di Gym)',
            Icons.payments,
            'cash',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppColors.accent : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodOption(String title, IconData icon, String value) {
    return Obx(() {
      final isSelected = controller.selectedPaymentMethod.value == value;
      return GestureDetector(
        onTap: () => controller.selectedPaymentMethod.value = value,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.accent : AppColors.divider,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.accent),
              const SizedBox(width: 16),
              Expanded(child: Text(title, style: AppTextStyles.bodyLarge)),
              if (isSelected)
                const Icon(Icons.check_circle, color: AppColors.accent),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStep3() {
    return Obx(() {
      final resultType = controller.paymentResultType.value;

      if (resultType == 'midtrans_success') {
        return _buildResult(
          icon: Icons.check_circle,
          iconColor: AppColors.success,
          title: 'Pembayaran Berhasil!',
          message:
              'Membership Anda telah aktif. Terima kasih telah melakukan pembayaran.',
        );
      }

      if (resultType == 'midtrans_failed') {
        return _buildResult(
          icon: Icons.error_outline,
          iconColor: AppColors.error,
          title: 'Pembayaran Belum Selesai',
          message:
              'Pembayaran belum dikonfirmasi. Silakan coba lagi atau hubungi admin jika sudah membayar.',
        );
      }

      return _buildResult(
        icon: Icons.check_circle,
        iconColor: AppColors.success,
        title: 'Permintaan Terkirim!',
        message:
            'Perpanjangan membership Anda sedang menunggu verifikasi admin. '
            'Anda akan diberi tahu setelah disetujui.',
      );
    });
  }

  Widget _buildResult({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 100),
            const SizedBox(height: 32),
            Text(title, style: AppTextStyles.headingSmall),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 48),
            GymButton(
              text: 'Kembali ke Home',
              onPressed: () => Get.offAllNamed(Routes.HOME),
            ),
          ],
        ),
      ),
    );
  }
}
