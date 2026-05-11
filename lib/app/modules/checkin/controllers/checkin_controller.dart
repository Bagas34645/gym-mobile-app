import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/attendance_model.dart';
import '../../../routes/app_routes.dart';

class CheckinController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  // ── Loading states ──────────────────────────────────────────
  final RxBool isLoading = true.obs;
  final RxBool isUploadingFace = false.obs;

  // ── Attendance ──────────────────────────────────────────────
  final RxList<AttendanceModel> attendanceHistory = <AttendanceModel>[].obs;

  // ── Face registration ────────────────────────────────────────
  final RxBool isFaceRegistered = false.obs;
  final RxList<File> capturedImages = <File>[].obs;
  final RxInt captureStep = 0.obs; // 0-4 (5 shots)
  final RxBool isCapturing = false.obs;

  static const int totalCaptureSteps = 5;

  final List<String> captureInstructions = const [
    'Hadapkan wajah ke depan',
    'Miringkan sedikit ke kiri',
    'Miringkan sedikit ke kanan',
    'Angkat sedikit ke atas',
    'Tundukkan sedikit ke bawah',
  ];

  final List<IconData> captureIcons = const [
    Icons.face,
    Icons.turn_left,
    Icons.turn_right,
    Icons.keyboard_arrow_up,
    Icons.keyboard_arrow_down,
  ];

  // ── Filter ───────────────────────────────────────────────────
  final RxString selectedFilter = 'Semua'.obs;
  final List<String> filterOptions = ['Semua', 'Minggu Ini', 'Bulan Ini'];

  @override
  void onInit() {
    super.onInit();
    fetchAttendanceHistory();
  }

  // ── Attendance History ───────────────────────────────────────
  void fetchAttendanceHistory() async {
    isLoading.value = true;
    // Simulate API call: GET /api/attendance/history
    await Future.delayed(const Duration(milliseconds: 1200));

    final now = DateTime.now();
    attendanceHistory.value = [
      AttendanceModel(
        id: '1',
        checkInTime: now.subtract(const Duration(hours: 2)),
        status: 'Hadir',
        method: 'face_recognition',
      ),
      AttendanceModel(
        id: '2',
        checkInTime: now.subtract(const Duration(days: 1, hours: 8)),
        status: 'Hadir',
        method: 'face_recognition',
      ),
      AttendanceModel(
        id: '3',
        checkInTime: now.subtract(const Duration(days: 3, hours: 5)),
        status: 'Hadir',
        method: 'face_recognition',
      ),
      AttendanceModel(
        id: '4',
        checkInTime: now.subtract(const Duration(days: 5, hours: 3)),
        status: 'Hadir',
        method: 'face_recognition',
      ),
      AttendanceModel(
        id: '5',
        checkInTime: now.subtract(const Duration(days: 8, hours: 7)),
        status: 'Hadir',
        method: 'face_recognition',
      ),
      AttendanceModel(
        id: '6',
        checkInTime: now.subtract(const Duration(days: 12, hours: 2)),
        status: 'Hadir',
        method: 'face_recognition',
      ),
    ];

    // Simulate face-registration status from API
    isFaceRegistered.value = true;
    isLoading.value = false;
  }

  List<AttendanceModel> get filteredAttendance {
    final now = DateTime.now();
    switch (selectedFilter.value) {
      case 'Minggu Ini':
        final weekAgo = now.subtract(const Duration(days: 7));
        return attendanceHistory
            .where((a) => a.checkInTime.isAfter(weekAgo))
            .toList();
      case 'Bulan Ini':
        return attendanceHistory
            .where((a) =>
                a.checkInTime.month == now.month &&
                a.checkInTime.year == now.year)
            .toList();
      default:
        return attendanceHistory;
    }
  }

  // ── Face Registration flow ───────────────────────────────────
  void startFaceRegistration() {
    capturedImages.clear();
    captureStep.value = 0;
    Get.toNamed(Routes.FACE_REGISTER);
  }

  Future<void> captureNextImage() async {
    if (captureStep.value >= totalCaptureSteps) return;

    isCapturing.value = true;
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
        maxWidth: 640,
        maxHeight: 640,
      );

      if (image != null) {
        capturedImages.add(File(image.path));
        captureStep.value++;

        if (captureStep.value >= totalCaptureSteps) {
          await uploadFaceImages();
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengakses kamera. Pastikan izin kamera diberikan.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    } finally {
      isCapturing.value = false;
    }
  }

  Future<void> uploadFaceImages() async {
    isUploadingFace.value = true;
    // Simulate API call: POST /api/members/face-register (multipart/form-data)
    await Future.delayed(const Duration(seconds: 2));

    isUploadingFace.value = false;
    isFaceRegistered.value = true;

    // Return to checkin page after success
    Get.back();
    await Future.delayed(const Duration(milliseconds: 300));

    Get.snackbar(
      'Berhasil! 🎉',
      'Wajah Anda berhasil didaftarkan. Kini Anda bisa check-in otomatis di gym.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void retakeImages() {
    capturedImages.clear();
    captureStep.value = 0;
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  // ── Stats ────────────────────────────────────────────────────
  int get thisMonthCount {
    final now = DateTime.now();
    return attendanceHistory
        .where((a) =>
            a.checkInTime.month == now.month &&
            a.checkInTime.year == now.year)
        .length;
  }

  int get thisWeekCount {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return attendanceHistory
        .where((a) => a.checkInTime.isAfter(weekAgo))
        .length;
  }
}
