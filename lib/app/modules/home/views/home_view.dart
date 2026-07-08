import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../core/widgets/gym_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../routes/app_routes.dart';
import '../../trainer/views/workout_plan_view.dart';
import '../../trainer/views/trainer_list_view.dart';
import '../../profile/views/profile_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          return IndexedStack(
            index: controller.currentIndex.value,
            children: [
              _buildDashboard(context),
              const WorkoutPlanView(),
              const SizedBox(), // Check-in is handled via routing
              const TrainerListView(),
              const ProfileView(),
            ],
          );
        }),
      ),
      bottomNavigationBar: Obx(() => GymBottomNavBar(
        currentIndex: controller.currentIndex.value,
        onTap: controller.changeTab,
      )),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.loadDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildMembershipCard(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Workout Hari Ini',
              onSeeAll: () => controller.changeTab(1),
            ),
            const SizedBox(height: 16),
            _buildTodayWorkout(),
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Aktivitas Terbaru',
              onSeeAll: () => Get.toNamed(Routes.CHECKIN),
            ),
            const SizedBox(height: 16),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.surface2,
              child: Icon(Icons.person, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                      'Halo, ${controller.userName} 💪',
                      style: AppTextStyles.bodyLarge
                          .copyWith(fontWeight: FontWeight.bold),
                    )),
                Text(
                  formatDateLong(DateTime.now()),
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ],
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary),
              onPressed: () {},
            ),
            if (controller.hasNotification.value)
              Positioned(
                top: 10,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMembershipCard() {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.MEMBERSHIP),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.surface2, AppColors.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border:
              const Border(left: BorderSide(color: AppColors.accent, width: 4)),
        ),
        child: Obx(() {
          final m = controller.membership.value;
          final active = m?.isActive ?? false;

          if (m == null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'BELUM ADA MEMBERSHIP',
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Aktifkan membership Anda',
                    style: AppTextStyles.bodyLarge),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => Get.toNamed(Routes.PACKAGES),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.accent),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text('Lihat Paket',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.accent)),
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: (active ? AppColors.accent : AppColors.error)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  active ? 'MEMBERSHIP AKTIF' : 'MEMBERSHIP TIDAK AKTIF',
                  style: AppTextStyles.bodySmall.copyWith(
                      color: active ? AppColors.accent : AppColors.error,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Text(m.packageName, style: AppTextStyles.bodyLarge),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${m.remainingDays}',
                      style: AppTextStyles.headingMedium
                          .copyWith(color: AppColors.accent, fontSize: 40)),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text('Hari tersisa',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                        'Berlaku hingga ${formatDateLong(m.endDate)}',
                        style: AppTextStyles.bodySmall),
                  ),
                  OutlinedButton(
                    onPressed: () => Get.toNamed(Routes.PACKAGES),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.accent),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      minimumSize: const Size(80, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text('Perpanjang',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.accent)),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionItem(Icons.qr_code_scanner, 'Check-in', () => Get.toNamed(Routes.CHECKIN)),
        _buildActionItem(Icons.people_outline, 'Trainer', controller.openTrainerList),
        _buildActionItem(Icons.auto_graph, 'Progress', () {}),
        _buildActionItem(Icons.chat_bubble_outline, 'Chat', () {}),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildTodayWorkout() {
    return Obx(() {
      final plan = controller.todayWorkout.value;
      if (plan == null) {
        return GymCard(
          child: Text(
            'Belum ada program latihan aktif',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        );
      }

      return GestureDetector(
        onTap: () => Get.toNamed(Routes.WORKOUT_PLAN),
        child: GymCard(
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.fitness_center, color: AppColors.accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${plan.exercises.length} Latihan',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildRecentActivity() {
    return Obx(() {
      final items = controller.recentAttendance;
      if (items.isEmpty) {
        return GymCard(
          child: Text(
            'Belum ada aktivitas check-in',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        );
      }

      return SizedBox(
        height: 80,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              width: 240,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.door_front_door_outlined, color: AppColors.accent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Check-in Gym',
                          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${formatDateShort(item.checkInTime)}, ${formatTime(item.checkInTime)}',
                          style: AppTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}
