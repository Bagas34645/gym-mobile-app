import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/models/trainer_model.dart';
import '../../../data/services/api_client.dart';
import '../../../data/services/trainer_service.dart';

class TrainerController extends GetxController {
  final TrainerService _service = TrainerService.instance;

  final RxBool isLoading = false.obs;
  final RxBool isLoadingDetail = false.obs;
  final RxBool isBooking = false.obs;

  final RxList<TrainerModel> trainers = <TrainerModel>[].obs;
  final Rxn<TrainerModel> selectedTrainer = Rxn<TrainerModel>();

  @override
  void onInit() {
    super.onInit();
    loadTrainers();
  }

  Future<void> loadTrainers() async {
    isLoading.value = true;
    try {
      trainers.value = await _service.list();
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Gagal memuat data trainer');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectTrainer(TrainerModel trainer) async {
    selectedTrainer.value = trainer;
    isLoadingDetail.value = true;
    try {
      // Fetch full detail (schedules, bio, certification).
      selectedTrainer.value = await _service.detail(trainer.id);
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      // keep the list payload we already have
    } finally {
      isLoadingDetail.value = false;
    }
  }

  /// Computes the next calendar date (yyyy-MM-dd) matching the schedule's
  /// day-of-week, starting from today.
  String _nextDateForDay(int dayOfWeek) {
    final now = DateTime.now();
    // Dart: Monday=1..Sunday=7; API: Sunday=0..Saturday=6.
    final todayApi = now.weekday % 7;
    var delta = (dayOfWeek - todayApi) % 7;
    if (delta < 0) delta += 7;
    if (delta == 0) delta = 7; // always book a future date
    final date = now.add(Duration(days: delta));
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> bookSchedule(TrainerSchedule schedule) async {
    final trainer = selectedTrainer.value;
    if (trainer == null) return;

    isBooking.value = true;
    try {
      final sessionDate = _nextDateForDay(schedule.dayOfWeek);
      final data = await _service.book(
        trainerId: trainer.id,
        scheduleId: schedule.id,
        sessionDate: sessionDate,
      );
      Get.back(); // back to trainer list
      Get.snackbar(
        'Booking Berhasil',
        'Sesi dengan ${trainer.name} pada '
            '${data['session_date'] ?? sessionDate} '
            '(${data['session_time'] ?? schedule.timeRange}) telah dipesan.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Gagal memesan sesi');
    } finally {
      isBooking.value = false;
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
