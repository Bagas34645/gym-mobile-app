import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/gym_button.dart';
import '../controllers/feedback_controller.dart';

class FeedbackView extends GetView<FeedbackController> {
  const FeedbackView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text('Kirim Feedback', style: AppTextStyles.headingSmall),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bantu kami menjadi lebih baik',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 28),
              Text('Rating', style: AppTextStyles.bodySmall),
              const SizedBox(height: 12),
              Obx(() => Row(
                    children: List.generate(5, (index) {
                      final star = index + 1;
                      final selected = controller.rating.value >= star;
                      return GestureDetector(
                        onTap: () => controller.setRating(star),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            selected ? Icons.star : Icons.star_border,
                            color: selected
                                ? const Color(0xFFFBBF24)
                                : AppColors.textSecondary,
                            size: 36,
                          ),
                        ),
                      );
                    }),
                  )),
              const SizedBox(height: 28),
              Text('Kategori', style: AppTextStyles.bodySmall),
              const SizedBox(height: 12),
              Obx(() {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: FeedbackController.categories.map((cat) {
                    final selected =
                        controller.selectedCategory.value == cat.value;
                    return ChoiceChip(
                      label: Text(cat.label),
                      selected: selected,
                      onSelected: (_) => controller.setCategory(cat.value),
                      selectedColor: AppColors.accent,
                      backgroundColor: AppColors.surface,
                      labelStyle: AppTextStyles.bodySmall.copyWith(
                        color: selected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                      side: BorderSide(
                        color: selected
                            ? AppColors.accent
                            : AppColors.divider,
                      ),
                      showCheckmark: false,
                    );
                  }).toList(),
                );
              }),
              const SizedBox(height: 28),
              Text('Komentar (opsional)', style: AppTextStyles.bodySmall),
              const SizedBox(height: 8),
              TextField(
                controller: controller.messageController,
                maxLines: 5,
                minLines: 4,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Ceritakan pengalaman Anda di gym…',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.accent),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Kirim secara anonim',
                    style: AppTextStyles.bodyLarge,
                  ),
                  subtitle: Text(
                    'Nama Anda tidak ditampilkan ke admin',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  value: controller.isAnonymous.value,
                  activeThumbColor: AppColors.accent,
                  onChanged: controller.toggleAnonymous,
                ),
              ),
              const SizedBox(height: 32),
              Obx(
                () => GymButton(
                  text: 'Kirim Feedback',
                  isLoading: controller.isSubmitting.value,
                  onPressed: controller.submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
