import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../../data/models/user_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/gym_button.dart';
import '../../../../core/widgets/gym_text_field.dart';
import '../../chat/controllers/chat_controller.dart';
import '../../../routes/app_routes.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Saya', style: AppTextStyles.headingSmall),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: controller.refreshProfile,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Obx(() {
                final u = controller.user.value;
                final photo = u?.profilePhotoUrl;
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.surface2,
                      backgroundImage: (photo != null && photo.isNotEmpty)
                          ? NetworkImage(photo)
                          : null,
                      child: (photo == null || photo.isEmpty)
                          ? const Icon(
                              Icons.person,
                              color: AppColors.textPrimary,
                              size: 50,
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(u?.name ?? '-', style: AppTextStyles.headingSmall),
                    const SizedBox(height: 4),
                    Text(
                      u?.email ?? '-',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      u?.phone ?? '-',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 24),
              Obx(() => _buildStatsRow(controller.user.value)),
              const SizedBox(height: 32),
              _buildMenuSection('Akun', [
                _buildMenuItem(
                  Icons.person_outline,
                  'Edit Profil',
                  () => _openEditProfile(context),
                ),
                _buildMenuItem(
                  Icons.lock_outline,
                  'Ubah Password',
                  () => _openChangePassword(context),
                ),
                _buildMenuItem(
                  Icons.chat_bubble_outline,
                  'Pesan / Chat',
                  () => ChatController.openFromMenu(),
                ),
              ]),
              const SizedBox(height: 24),
              _buildMenuSection('Lainnya', [
                _buildMenuItem(
                  Icons.rate_review_outlined,
                  'Kirim Feedback',
                  () => Get.toNamed(Routes.FEEDBACK),
                ),
                _buildMenuItem(
                  Icons.privacy_tip_outlined,
                  'Kebijakan Privasi',
                  () {},
                ),
                _buildMenuItem(Icons.info_outline, 'Tentang Aplikasi', () {}),
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
      ),
    );
  }

  Widget _buildStatsRow(UserModel? user) {
    String fmt(num? v, String suffix) => v == null ? '-' : '$v$suffix';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _stat('Usia', user?.age == null ? '-' : '${user!.age} th'),
          _divider(),
          _stat('Tinggi', fmt(user?.heightCm, ' cm')),
          _divider(),
          _stat('Berat', fmt(user?.weightKg, ' kg')),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 32, color: AppColors.divider);

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
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

  void _openEditProfile(BuildContext context) {
    controller.prepareEditForm();
    Get.bottomSheet(
      isScrollControlled: true,
      Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edit Profil', style: AppTextStyles.headingSmall),
                const SizedBox(height: 24),
                GymTextField(
                  label: 'Nama',
                  hint: 'Nama lengkap',
                  controller: controller.nameController,
                ),
                const SizedBox(height: 16),
                GymTextField(
                  label: 'Usia',
                  hint: 'Tahun',
                  keyboardType: TextInputType.number,
                  controller: controller.ageController,
                ),
                const SizedBox(height: 16),
                GymTextField(
                  label: 'Tinggi (cm)',
                  hint: 'cm',
                  keyboardType: TextInputType.number,
                  controller: controller.heightController,
                ),
                const SizedBox(height: 16),
                GymTextField(
                  label: 'Berat (kg)',
                  hint: 'kg',
                  keyboardType: TextInputType.number,
                  controller: controller.weightController,
                ),
                const SizedBox(height: 16),
                GymTextField(
                  label: 'Target Fitness',
                  hint: 'cth: Menurunkan berat badan',
                  controller: controller.goalController,
                ),
                const SizedBox(height: 24),
                Obx(
                  () => GymButton(
                    text: 'Simpan',
                    isLoading: controller.isSaving.value,
                    onPressed: controller.saveProfile,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openChangePassword(BuildContext context) {
    Get.bottomSheet(
      isScrollControlled: true,
      Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ubah Password', style: AppTextStyles.headingSmall),
                const SizedBox(height: 24),
                GymTextField(
                  label: 'Password Saat Ini',
                  hint: 'Masukkan password lama',
                  isPassword: true,
                  controller: controller.currentPasswordController,
                ),
                const SizedBox(height: 16),
                GymTextField(
                  label: 'Password Baru',
                  hint: 'Minimal 8 karakter',
                  isPassword: true,
                  controller: controller.newPasswordController,
                ),
                const SizedBox(height: 16),
                GymTextField(
                  label: 'Konfirmasi Password',
                  hint: 'Ulangi password baru',
                  isPassword: true,
                  controller: controller.confirmPasswordController,
                ),
                const SizedBox(height: 24),
                Obx(
                  () => GymButton(
                    text: 'Simpan',
                    isLoading: controller.isSaving.value,
                    onPressed: controller.savePassword,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
