import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/attendance_model.dart';
import '../../../data/services/api_client.dart';
import '../../../data/services/attendance_service.dart';
import '../../../routes/app_routes.dart';

class CheckinController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final AttendanceService _attendanceService = AttendanceService.instance;

  // ── Loading states ──────────────────────────────────────────
  final RxBool isLoading = true.obs;
  final RxBool isUploadingFace = false.obs;

  // ── Attendance ──────────────────────────────────────────────
  final RxList<AttendanceModel> attendanceHistory = <AttendanceModel>[].obs;

  // ── Face registration ────────────────────────────────────────
  // faceStatus: 'none' | 'pending' | 'verified' | 'rejected'
  final RxString faceStatus = 'none'.obs;
  final RxString rejectionReason = ''.obs;
  final RxList<File> capturedImages = <File>[].obs;
  final RxInt captureStep = 0.obs; // 0-4 (5 shots)
  final RxBool isCapturing = false.obs;

  bool get isFaceRegistered => faceStatus.value == 'verified';
  bool get isFacePending => faceStatus.value == 'pending';
  bool get isFaceRejected => faceStatus.value == 'rejected';

  static const int totalCaptureSteps = 1;

  final List<String> captureInstructions = const [
    'Hadapkan wajah ke depan kamera',
  ];

  final List<IconData> captureIcons = const [
    Icons.face,
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
  Future<void> fetchAttendanceHistory() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _attendanceService.faceStatus(),
        _attendanceService.history(perPage: 50),
      ]);

      final status = results[0] as Map<String, dynamic>;
      final history = results[1] as List<AttendanceModel>;

      faceStatus.value = (status['status'] ?? 'none').toString();
      rejectionReason.value = (status['rejection_reason'] ?? '').toString();
      attendanceHistory.value = history;
    } on ApiException catch (e) {
      _showSnackbar('Gagal memuat data', e.message, isError: true);
    } catch (_) {
      _showSnackbar('Gagal memuat data', 'Periksa koneksi Anda.', isError: true);
    } finally {
      isLoading.value = false;
    }
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
    if (capturedImages.isEmpty) return;

    isUploadingFace.value = true;
    try {
      // Backend accepts a single image; send the frontal (first) capture.
      await _attendanceService.registerFace(capturedImages.first);
      faceStatus.value = 'pending';
      rejectionReason.value = '';

      // Return to checkin page after success
      Get.back();
      await Future.delayed(const Duration(milliseconds: 300));

      _showSnackbar(
        'Berhasil dikirim',
        'Wajah Anda menunggu verifikasi admin. Anda akan bisa check-in setelah disetujui.',
        isError: false,
      );
    } on ApiException catch (e) {
      _showSnackbar('Pendaftaran gagal', e.message, isError: true);
    } catch (_) {
      _showSnackbar('Pendaftaran gagal', 'Periksa koneksi Anda.', isError: true);
    } finally {
      isUploadingFace.value = false;
    }
  }

  void _showSnackbar(String title, String message, {required bool isError}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle,
        color: Colors.white,
      ),
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
