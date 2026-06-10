import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/workout_model.dart';
import '../../../data/services/api_client.dart';
import '../../../data/services/workout_service.dart';

class WorkoutController extends GetxController {
  final WorkoutService _service = WorkoutService.instance;

  final RxBool isLoading = false.obs;
  final RxList<WorkoutPlanModel> plans = <WorkoutPlanModel>[].obs;

  // ── Tracking state ─────────────────────────────────────────────
  final RxInt currentSet = 1.obs;
  final RxBool isLogging = false.obs;
  int _totalSets = 3;
  String _trackingExercise = '';
  String? _trackingPlanId;
  final List<Map<String, dynamic>> _loggedSets = [];

  @override
  void onInit() {
    super.onInit();
    loadPlans();
  }

  Future<void> loadPlans() async {
    isLoading.value = true;
    try {
      plans.value = await _service.plans();
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Gagal memuat program latihan');
    } finally {
      isLoading.value = false;
    }
  }

  void startTracking({
    required String exerciseName,
    required int totalSets,
    String? planId,
  }) {
    _trackingExercise = exerciseName;
    _totalSets = totalSets <= 0 ? 1 : totalSets;
    _trackingPlanId = planId;
    _loggedSets.clear();
    currentSet.value = 1;
  }

  int get totalSets => _totalSets;

  Future<void> logSet(String weight, String reps) async {
    if (reps.trim().isEmpty) {
      _showError('Repetisi harus diisi');
      return;
    }
    _loggedSets.add({
      'weight': double.tryParse(weight.trim()) ?? 0,
      'reps': int.tryParse(reps.trim()) ?? 0,
    });

    if (currentSet.value < _totalSets) {
      currentSet.value++;
      Get.snackbar('Berhasil', 'Set ${currentSet.value - 1} dicatat!',
          snackPosition: SnackPosition.BOTTOM);
    } else {
      await _finishExercise();
    }
  }

  Future<void> _finishExercise() async {
    isLogging.value = true;
    try {
      final lastReps = _loggedSets.isNotEmpty ? _loggedSets.last['reps'] : 0;
      final lastWeight =
          _loggedSets.isNotEmpty ? _loggedSets.last['weight'] : 0.0;
      await _service.logWorkout(
        workoutPlanId: _trackingPlanId,
        exercises: [
          {
            'exercise_name': _trackingExercise,
            'sets': _loggedSets.length,
            'reps': lastReps,
            'weight_kg': lastWeight,
          }
        ],
      );
      Get.back();
      Get.snackbar('Selesai', 'Latihan "$_trackingExercise" tercatat!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white));
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Gagal menyimpan latihan');
    } finally {
      isLogging.value = false;
    }
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
