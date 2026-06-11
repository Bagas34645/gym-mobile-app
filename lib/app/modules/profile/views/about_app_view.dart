import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AboutAppView extends StatelessWidget {
  const AboutAppView({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: Text(
          'Tentang Aplikasi',
          style: AppTextStyles.headingSmall,
        ),
        backgroundColor: AppColors.background,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(
              'GYMFLOW',
              style: AppTextStyles.headingMedium,
            ),

            const SizedBox(height: 16),

            Text(
              'Aplikasi mobile fitness dan gym management berbasis Flutter dan Firebase.',
              style: AppTextStyles.bodyLarge,
            ),

            const SizedBox(height: 16),

            Text(
              'Versi 1.0.0',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}