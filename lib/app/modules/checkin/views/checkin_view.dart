import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/checkin_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class CheckinView extends GetView<CheckinController> {
  const CheckinView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          );
        }
        return NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _buildSliverAppBar(innerBoxIsScrolled),
          ],
          body: RefreshIndicator(
            onRefresh: () async => controller.fetchAttendanceHistory(),
            color: AppColors.accent,
            backgroundColor: AppColors.surface,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Stats Row
                  _buildStatsRow(),
                  const SizedBox(height: 24),

                  // ── Face Registration Card
                  _buildFaceRegistrationCard(),
                  const SizedBox(height: 28),

                  // ── Info banner: how check-in works
                  _buildCheckinInfoBanner(),
                  const SizedBox(height: 28),

                  // ── Attendance History Header + filter
                  _buildHistoryHeader(),
                  const SizedBox(height: 16),

                  // ── History list
                  _buildAttendanceHistory(),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── Sliver AppBar ────────────────────────────────────────────
  Widget _buildSliverAppBar(bool innerBoxIsScrolled) {
    return SliverAppBar(
      backgroundColor: AppColors.surface,
      expandedHeight: 100,
      floating: true,
      snap: true,
      pinned: true,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Absensi & Check-in',
                style: AppTextStyles.headingSmall.copyWith(letterSpacing: 0.5)),
            Text(
              DateFormat('EEEE, d MMMM yyyy', 'id').format(DateTime.now()),
              style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  // ── Stats Row ────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'Bulan Ini',
            value: '${controller.thisMonthCount}x',
            icon: Icons.calendar_month_outlined,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: 'Minggu Ini',
            value: '${controller.thisWeekCount}x',
            icon: Icons.today_outlined,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: 'Total',
            value: '${controller.attendanceHistory.length}x',
            icon: Icons.bar_chart_outlined,
            color: const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodySmall.copyWith(fontSize: 10)),
        ],
      ),
    );
  }

  // ── Face Registration Card ────────────────────────────────────
  Widget _buildFaceRegistrationCard() {
    final status = controller.faceStatus.value;
    final isRegistered = status == 'verified';
    final isPending = status == 'pending';
    final isRejected = status == 'rejected';

    final accentColor = isRegistered
        ? AppColors.success
        : isPending
            ? const Color(0xFFF59E0B)
            : isRejected
                ? AppColors.error
                : AppColors.accent;

    final title = isRegistered
        ? 'Wajah Terverifikasi'
        : isPending
            ? 'Menunggu Verifikasi'
            : isRejected
                ? 'Pendaftaran Ditolak'
                : 'Daftar Wajah';

    final subtitle = isRegistered
        ? 'Wajah Anda aktif. Check-in otomatis tersedia di kiosk resepsionis gym.'
        : isPending
            ? 'Foto wajah Anda sedang ditinjau admin. Mohon tunggu persetujuan.'
            : isRejected
                ? (controller.rejectionReason.value.isNotEmpty
                    ? 'Ditolak: ${controller.rejectionReason.value}. Silakan daftar ulang.'
                    : 'Pendaftaran ditolak. Silakan daftar ulang dengan foto yang jelas.')
                : 'Daftarkan wajah untuk bisa check-in otomatis di gym.';

    final buttonLabel = isRegistered
        ? 'Perbarui Wajah'
        : isPending
            ? 'Daftar Ulang'
            : isRejected
                ? 'Daftar Ulang'
                : 'Mulai Daftar';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withOpacity(0.13),
            AppColors.surface2,
          ],
        ),
        border: Border.all(
          color: accentColor.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Avatar circle
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withOpacity(0.14),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    isRegistered
                        ? Icons.face_retouching_natural
                        : isPending
                            ? Icons.hourglass_top
                            : isRejected
                                ? Icons.error_outline
                                : Icons.face_outlined,
                    size: 38,
                    color: accentColor,
                  ),
                  if (isRegistered)
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check,
                            color: Colors.white, size: 12),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isRegistered || isPending) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isRegistered ? 'AKTIF' : 'PENDING',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 38,
                    child: ElevatedButton.icon(
                      onPressed: controller.startFaceRegistration,
                      icon: Icon(
                        isRegistered || isPending
                            ? Icons.refresh
                            : Icons.add_a_photo_outlined,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: Text(
                        buttonLabel,
                        style: AppTextStyles.button.copyWith(fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Info Banner ───────────────────────────────────────────────
  Widget _buildCheckinInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.accent, size: 18),
              const SizedBox(width: 8),
              Text(
                'Cara Check-in di Gym',
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStep('1', 'Daftarkan wajah Anda di aplikasi ini'),
          _buildStep('2', 'Tunggu admin memverifikasi foto wajah Anda'),
          _buildStep('3', 'Datang ke kiosk resepsionis gym'),
          _buildStep('4', 'Posisikan wajah di kamera, absen otomatis ✓'),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // ── History Header + Filter ───────────────────────────────────
  Widget _buildHistoryHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Riwayat Kehadiran', style: AppTextStyles.headingSmall),
        const SizedBox(height: 12),
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: controller.filterOptions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = controller.filterOptions[index];
              final isSelected = controller.selectedFilter.value == filter;
              return GestureDetector(
                onTap: () => controller.setFilter(filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accent : AppColors.surface,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.accent
                          : AppColors.divider,
                    ),
                  ),
                  child: Text(
                    filter,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Attendance History List ───────────────────────────────────
  Widget _buildAttendanceHistory() {
    final list = controller.filteredAttendance;

    if (list.isEmpty) {
      return _buildEmptyHistory();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final attendance = list[index];
        final isToday = _isToday(attendance.checkInTime);
        final dateStr = isToday
            ? 'Hari Ini'
            : DateFormat('EEE, d MMM yyyy', 'id')
                .format(attendance.checkInTime);
        final timeStr = DateFormat('HH:mm').format(attendance.checkInTime);
        final isFace = attendance.method == 'face_recognition';

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + (index * 60)),
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isToday
                    ? AppColors.accent.withOpacity(0.3)
                    : AppColors.divider,
                width: isToday ? 1.5 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Left: date column
                  Container(
                    width: 48,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isToday
                          ? AppColors.accent.withOpacity(0.12)
                          : AppColors.surface2,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('dd').format(attendance.checkInTime),
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isToday
                                ? AppColors.accent
                                : AppColors.textPrimary,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          DateFormat('MMM', 'id')
                              .format(attendance.checkInTime)
                              .toUpperCase(),
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 10,
                            color: isToday
                                ? AppColors.accent
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Middle: info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Check-in Gym',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isToday) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'HARI INI',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                size: 12, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '$dateStr · $timeStr WIB',
                              style: AppTextStyles.bodySmall
                                  .copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              isFace
                                  ? Icons.face_retouching_natural
                                  : Icons.fingerprint,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isFace
                                  ? 'Face Recognition'
                                  : 'Manual',
                              style: AppTextStyles.bodySmall
                                  .copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Right: status badge
                  _buildStatusBadge(attendance.status),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    final isHadir = status == 'Hadir';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isHadir
            ? AppColors.success.withOpacity(0.12)
            : AppColors.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isHadir ? Icons.check_circle : Icons.cancel_outlined,
            size: 12,
            color: isHadir ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: AppTextStyles.bodySmall.copyWith(
              color: isHadir ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(Icons.history_toggle_off,
                size: 56,
                color: AppColors.textSecondary.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Riwayat',
              style: AppTextStyles.bodyLarge
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            Text(
              'Riwayat kehadiran akan muncul\nsetelah Anda melakukan check-in.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
