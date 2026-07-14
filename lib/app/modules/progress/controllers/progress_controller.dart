import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/progress_model.dart';
import '../../../data/services/api_client.dart';
import '../../../data/services/progress_service.dart';
import '../../../data/services/session_service.dart';

enum ProgressChartType {
  weight('weight', 'Berat'),
  attendance('attendance', 'Kehadiran'),
  workout('workout', 'Latihan');

  const ProgressChartType(this.apiValue, this.label);

  final String apiValue;
  final String label;
}

enum ProgressChartPeriod {
  week('7d', '1W'),
  month('30d', '1M'),
  quarter('90d', '3M');

  const ProgressChartPeriod(this.apiValue, this.label);

  final String apiValue;
  final String label;
}

class ProgressController extends GetxController {
  final isLoading = true.obs;
  final isChartLoading = false.obs;
  final isSubmitting = false.obs;

  final summary = Rxn<ProgressSummary>();
  final weightHistory = <ProgressWeight>[].obs;
  final chartData = Rxn<ProgressChartData>();

  final chartType = ProgressChartType.weight.obs;
  final chartPeriod = ProgressChartPeriod.month.obs;

  final weightController = TextEditingController();
  final notesController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  @override
  void onClose() {
    weightController.dispose();
    notesController.dispose();
    super.onClose();
  }

  int? get heightCm {
    // Read through .obs so Obx rebuilds when profile is refreshed.
    return SessionService.to.user.value?.heightCm;
  }

  /// Prefer progress log; fall back to weight saved on the member profile.
  double? get effectiveWeightKg {
    return summary.value?.latestWeightKg ??
        SessionService.to.user.value?.weightKg;
  }

  double? get bmi {
    final weight = effectiveWeightKg;
    final height = heightCm;
    if (weight == null || height == null || height <= 0) return null;
    final heightM = height / 100;
    return weight / (heightM * heightM);
  }

  String get bmiCategory {
    final value = bmi;
    if (value == null) return '';
    if (value < 18.5) return 'Kurus';
    if (value < 25) return 'Normal';
    if (value < 30) return 'Gemuk';
    return 'Obesitas';
  }

  double? trendForIndex(int index) {
    if (index >= weightHistory.length - 1) return null;
    return weightHistory[index].weightKg - weightHistory[index + 1].weightKg;
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    try {
      // Use cached session profile for BMI; avoid extra /auth/me on every open.
      await Future.wait([
        _loadSummary(),
        _loadWeightHistory(),
        _loadChart(),
      ]);
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Gagal memuat data progress');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadSummary() async {
    summary.value = await ProgressService.instance.getSummary();
  }

  Future<void> _loadWeightHistory() async {
    weightHistory.assignAll(await ProgressService.instance.getWeightHistory());
  }

  Future<void> _refreshAfterWeightChange() async {
    await Future.wait([
      _loadSummary(),
      _loadWeightHistory(),
      if (chartType.value == ProgressChartType.weight) _loadChart(),
    ]);
  }

  Future<void> _loadChart() async {
    isChartLoading.value = true;
    try {
      chartData.value = await ProgressService.instance.getChart(
        type: chartType.value.apiValue,
        period: chartPeriod.value.apiValue,
      );
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Gagal memuat grafik');
    } finally {
      isChartLoading.value = false;
    }
  }

  Future<void> setChartType(ProgressChartType type) async {
    if (chartType.value == type) return;
    chartType.value = type;
    await _loadChart();
  }

  Future<void> setChartPeriod(ProgressChartPeriod period) async {
    if (chartPeriod.value == period) return;
    chartPeriod.value = period;
    await _loadChart();
  }

  Future<void> submitWeight() async {
    final raw = weightController.text.trim().replaceAll(',', '.');
    final weight = double.tryParse(raw);
    if (weight == null || weight < 20 || weight > 500) {
      _showError('Masukkan berat badan antara 20–500 kg');
      return;
    }

    isSubmitting.value = true;
    try {
      await ProgressService.instance.storeWeight(
        weightKg: weight,
        notes: notesController.text.trim(),
      );
      weightController.clear();
      notesController.clear();
      _patchSessionWeight(weight);
      await _refreshAfterWeightChange();
      _showSuccess('Berat badan berhasil disimpan');
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Gagal mencatat berat badan');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deleteWeight(String id) async {
    try {
      await ProgressService.instance.deleteWeight(id);
      await _refreshAfterWeightChange();
      _showSuccess('Data berat badan dihapus');
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Gagal menghapus data berat badan');
    }
  }

  void _patchSessionWeight(double weightKg) {
    final user = SessionService.to.user.value;
    if (user == null) return;
    SessionService.to.user.value = user.copyWith(weightKg: weightKg);
  }

  Future<void> confirmDeleteWeight(ProgressWeight entry) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFF131B2F),
        title: const Text('Hapus data?'),
        content: Text(
          'Hapus catatan berat ${entry.weightKg.toStringAsFixed(1)} kg?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Hapus', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await deleteWeight(entry.id);
    }
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Berhasil',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Gagal',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFEF4444),
      colorText: Colors.white,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }
}
