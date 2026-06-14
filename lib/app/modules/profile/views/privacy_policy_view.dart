import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: Text('Kebijakan Privasi', style: AppTextStyles.headingSmall),
        backgroundColor: AppColors.background,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Text(
          'Aplikasi GymFlow menjaga keamanan data pengguna dan tidak membagikan informasi pribadi kepada pihak ketiga.',
          style: AppTextStyles.bodyLarge,
        ),
      ),
    );
  }
}
