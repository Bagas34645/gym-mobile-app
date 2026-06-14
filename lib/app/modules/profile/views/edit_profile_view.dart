import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/gym_button.dart';
import '../../../../core/widgets/gym_text_field.dart';
import '../controllers/profile_controller.dart';

class EditProfileView extends StatelessWidget {
  EditProfileView({super.key});

  final ProfileController controller =
      Get.find<ProfileController>();

  final TextEditingController nameController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {

    nameController.text =
        controller.name.value;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: Text(
          'Edit Profil',
          style: AppTextStyles.headingSmall,
        ),
        backgroundColor: AppColors.background,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          children: [

            GymTextField(
              label: 'Nama',
              hint: 'Masukkan nama',

              prefixIcon: Icons.person,

              controller: nameController,
            ),

            const SizedBox(height: 32),

            GymButton(
              text: 'Simpan',

              onPressed: () async {

                controller.updateName(
                  nameController.text,
                );

                Get.snackbar(
                  'Berhasil',
                  'Profil berhasil diperbarui',
                );

                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}