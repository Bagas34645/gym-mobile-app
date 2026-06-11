import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/gym_button.dart';
import '../../../../core/widgets/gym_text_field.dart';

class ChangePasswordView extends StatelessWidget {
  ChangePasswordView({super.key});

  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: Text('Ubah Password', style: AppTextStyles.headingSmall),
        backgroundColor: AppColors.background,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          children: [
            GymTextField(
              label: 'Password Baru',
              hint: 'Masukkan password baru',

              prefixIcon: Icons.lock,

              isPassword: true,

              controller: passwordController,
            ),

            const SizedBox(height: 32),

            GymButton(
              text: 'Update Password',

              onPressed: () {
                Get.snackbar('Info', 'Fitur reset password berhasil dibuat');
              },
            ),
          ],
        ),
      ),
    );
  }
}
