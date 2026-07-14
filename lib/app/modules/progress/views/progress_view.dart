import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/gym_button.dart';
import '../../../../core/widgets/gym_card.dart';
import '../../../../core/widgets/gym_text_field.dart';
import '../../../../core/widgets/section_header.dart';
import '../controllers/progress_controller.dart';

class ProgressView extends GetView<ProgressController> {
  const ProgressView({super.key});

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
        title: Text('Analisis Progress', style: AppTextStyles.headingSmall),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          );
        }

        return RefreshIndicator(
          color: AppColors.accent,
          onRefresh: controller.loadAll,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummarySection(),
                const SizedBox(height: 32),
                _buildChartSection(),
                const SizedBox(height: 32),
                _buildWeightInputSection(),
                const SizedBox(height: 24),
                _buildWeightHistorySection(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSummarySection() {
    final data = controller.summary.value;
    final weight = controller.effectiveWeightKg;
    final bmi = controller.bmi;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Ringkasan Bulan Ini'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _summaryTile(
                icon: Icons.monitor_weight_outlined,
                label: 'Berat Terkini',
                value: weight != null
                    ? '${weight.toStringAsFixed(1)} kg'
                    : '-',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryTile(
                icon: Icons.event_available_outlined,
                label: 'Kehadiran',
                value: '${data?.attendanceThisMonth ?? 0}x',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _summaryTile(
                icon: Icons.fitness_center_outlined,
                label: 'Workout',
                value: '${data?.workoutsThisMonth ?? 0}x',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryTile(
                icon: Icons.speed_outlined,
                label: 'BMI',
                value: bmi != null
                    ? '${bmi.toStringAsFixed(1)}\n${controller.bmiCategory}'
                    : '-',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return GymCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accent, size: 22),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Grafik Progress'),
        const SizedBox(height: 12),
        Obx(() {
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ProgressChartType.values.map((type) {
              final selected = controller.chartType.value == type;
              return ChoiceChip(
                label: Text(type.label),
                selected: selected,
                onSelected: (_) => controller.setChartType(type),
                selectedColor: AppColors.accent,
                backgroundColor: AppColors.surface,
                labelStyle: AppTextStyles.bodySmall.copyWith(
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
                side: BorderSide(
                  color: selected ? AppColors.accent : AppColors.divider,
                ),
                showCheckmark: false,
              );
            }).toList(),
          );
        }),
        const SizedBox(height: 12),
        Obx(() {
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ProgressChartPeriod.values.map((period) {
              final selected = controller.chartPeriod.value == period;
              return ChoiceChip(
                label: Text(period.label),
                selected: selected,
                onSelected: (_) => controller.setChartPeriod(period),
                selectedColor: AppColors.surface2,
                backgroundColor: AppColors.surface,
                labelStyle: AppTextStyles.bodySmall.copyWith(
                  color: selected ? AppColors.accent : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
                side: BorderSide(
                  color: selected ? AppColors.accent : AppColors.divider,
                ),
                showCheckmark: false,
              );
            }).toList(),
          );
        }),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isChartLoading.value) {
            return const SizedBox(
              height: 220,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            );
          }
          return _buildChart();
        }),
      ],
    );
  }

  Widget _buildChart() {
    final data = controller.chartData.value;
    if (data == null || data.isEmpty) {
      return GymCard(
        child: SizedBox(
          height: 200,
          child: Center(
            child: Text(
              'Belum ada data untuk periode ini',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    final values = data.datasets.first.values;
    final labels = data.labels;
    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final yPadding = (maxY - minY).abs() < 1 ? 1.0 : (maxY - minY) * 0.15;

    final spots = List.generate(
      values.length,
      (i) => FlSpot(i.toDouble(), values[i]),
    );

    return GymCard(
      child: SizedBox(
        height: 220,
        child: LineChart(
          LineChartData(
            minY: minY - yPadding,
            maxY: maxY + yPadding,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => const FlLine(
                color: AppColors.divider,
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  getTitlesWidget: (value, _) => Text(
                    value.toStringAsFixed(0),
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval: labels.length > 6 ? (labels.length / 4).ceilToDouble() : 1,
                  getTitlesWidget: (value, _) {
                    final index = value.toInt();
                    if (index < 0 || index >= labels.length) {
                      return const SizedBox.shrink();
                    }
                    final label = labels[index];
                    final date = DateTime.tryParse(label);
                    final text = date != null
                        ? formatDateShort(date).split(' ').take(2).join(' ')
                        : label;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        text,
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: AppColors.accent,
                barWidth: 3,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.accent.withValues(alpha: 0.12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeightInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Catat Berat Badan'),
        const SizedBox(height: 16),
        GymCard(
          child: Column(
            children: [
              GymTextField(
                label: 'Berat (kg)',
                hint: 'Contoh: 72.5',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                controller: controller.weightController,
              ),
              const SizedBox(height: 16),
              GymTextField(
                label: 'Catatan (opsional)',
                hint: 'Setelah latihan pagi',
                controller: controller.notesController,
              ),
              const SizedBox(height: 20),
              Obx(
                () => GymButton(
                  text: 'Simpan',
                  isLoading: controller.isSubmitting.value,
                  onPressed: controller.submitWeight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeightHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Riwayat Berat Badan'),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.weightHistory.isEmpty) {
            return GymCard(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Belum ada riwayat berat badan',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }

          return Column(
            children: List.generate(controller.weightHistory.length, (index) {
              final entry = controller.weightHistory[index];
              final trend = controller.trendForIndex(index);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Dismissible(
                  key: ValueKey(entry.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    await controller.confirmDeleteWeight(entry);
                    return false;
                  },
                  child: GymCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${entry.weightKg.toStringAsFixed(1)} kg',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatDateLong(entry.recordedAt),
                                style: AppTextStyles.bodySmall,
                              ),
                              if (entry.notes != null &&
                                  entry.notes!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  entry.notes!,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (trend != null) _buildTrendBadge(trend),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () => controller.confirmDeleteWeight(entry),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ],
    );
  }

  Widget _buildTrendBadge(double trend) {
    final isUp = trend > 0;
    final isDown = trend < 0;
    final color = isUp
        ? AppColors.error
        : isDown
            ? AppColors.success
            : AppColors.textSecondary;
    final icon = isUp
        ? Icons.arrow_upward
        : isDown
            ? Icons.arrow_downward
            : Icons.remove;

    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 2),
          Text(
            trend.abs().toStringAsFixed(1),
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
