import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym_mobile_flutter/app/modules/profile/views/about_app_view.dart';
import 'package:gym_mobile_flutter/app/modules/profile/views/change_password_view.dart';
import 'package:gym_mobile_flutter/app/modules/profile/views/edit_profile_view.dart';
import 'package:gym_mobile_flutter/app/modules/profile/views/help_support_view.dart';
import 'package:gym_mobile_flutter/app/modules/profile/views/privacy_policy_view.dart';
import '../controllers/profile_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/gym_button.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject if not yet injected
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Saya', style: AppTextStyles.headingSmall),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.surface2,
              child: Icon(Icons.person, color: AppColors.textPrimary, size: 50),
            ),
            const SizedBox(height: 16),
            Obx(
              () => Text(
                controller.name.value,
                style: AppTextStyles.headingSmall,
              ),
            ),
            const SizedBox(height: 4),
            Obx(
              () => Text(
                controller.email.value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 32),

            _buildMenuSection('Akun', [
              _buildMenuItem(
                Icons.person_outline,
                'Edit Profil',
                () => Get.to(() => EditProfileView()),
              ),
              _buildMenuItem(
                Icons.lock_outline,
                'Ubah Password',
                () => Get.to(() => ChangePasswordView()),
              ),
            ]),

            const SizedBox(height: 24),

            _buildMenuSection('Lainnya', [
              _buildMenuItem(
                Icons.help_outline,
                'Bantuan & Dukungan',
                () => Get.to(() => HelpSupportView()),
              ),
              _buildMenuItem(
                Icons.privacy_tip_outlined,
                'Kebijakan Privasi',
                () => Get.to(() => PrivacyPolicyView()),
              ),
              _buildMenuItem(
                Icons.info_outline,
                'Tentang Aplikasi',
                () => Get.to(() => AboutAppView()),
              ),
            ]),

            const SizedBox(height: 32),
            GymButton(
              text: 'Keluar',
              type: ButtonType.danger,
              onPressed: () {
                Get.defaultDialog(
                  title: 'Konfirmasi Keluar',
                  titleStyle: AppTextStyles.headingSmall,
                  middleText: 'Apakah Anda yakin ingin keluar dari akun?',
                  middleTextStyle: AppTextStyles.bodyMedium,
                  backgroundColor: AppColors.surface,
                  textConfirm: 'Keluar',
                  textCancel: 'Batal',
                  confirmTextColor: Colors.white,
                  cancelTextColor: AppColors.accent,
                  buttonColor: AppColors.error,
                  onConfirm: controller.logout,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.headingSmall.copyWith(fontSize: 18)),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.accent),
      title: Text(title, style: AppTextStyles.bodyLarge),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
