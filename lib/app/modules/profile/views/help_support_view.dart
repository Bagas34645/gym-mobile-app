import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class HelpSupportView extends StatelessWidget {
  const HelpSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: Text('Bantuan & Dukungan', style: AppTextStyles.headingSmall),
        backgroundColor: AppColors.background,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text('Hubungi Kami', style: AppTextStyles.headingSmall),

            const SizedBox(height: 16),

            Text('Email: support@gymflow.com', style: AppTextStyles.bodyLarge),

            const SizedBox(height: 8),

            Text('WhatsApp: 08123456789', style: AppTextStyles.bodyLarge),
          ],
        ),
      ),
    );
  }
}
