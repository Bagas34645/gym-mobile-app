import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/membership_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/gym_button.dart';

class PackagesView extends GetView<MembershipController> {
  const PackagesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih Paket', style: AppTextStyles.headingSmall),
        backgroundColor: AppColors.background,
      ),
      body: Column(
        children: [
          _buildToggleChips(),
          Expanded(
            child: Obx(() {
              final pkgs = controller.packages;
              return ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: pkgs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 24),
                itemBuilder: (context, index) {
                  return _buildPackageCard(pkgs[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['Harian', 'Bulanan', 'Tahunan'].map((type) {
            final isSelected = controller.selectedPackageType.value == type;
            return GestureDetector(
              onTap: () => controller.changePackageType(type),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent : AppColors.surface2,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  type,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPackageCard(Map<String, dynamic> pkg) {
    final isPopular = pkg['isPopular'] as bool;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: isPopular
            ? Border.all(color: AppColors.accent, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPopular)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Center(
                child: Text(
                  'TERPOPULER',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pkg['name'], style: AppTextStyles.headingSmall),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      pkg['price'],
                      style: AppTextStyles.headingMedium.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6.0, left: 4.0),
                      child: Text(
                        pkg['period'],
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                ...((pkg['benefits'] as List<String>).map(
                  (b) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(b, style: AppTextStyles.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                )),
                const SizedBox(height: 32),
                GymButton(
                  text: 'Pilih Paket',
                  type: isPopular ? ButtonType.primary : ButtonType.secondary,
                  onPressed: () => controller.proceedToRenewal(pkg),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
