import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/api_client.dart';
import '../../../data/services/feedback_service.dart';

class FeedbackCategory {
  const FeedbackCategory(this.value, this.label);

  final String value;
  final String label;
}

class FeedbackController extends GetxController {
  static const categories = <FeedbackCategory>[
    FeedbackCategory('facility', 'Fasilitas'),
    FeedbackCategory('trainer', 'Trainer'),
    FeedbackCategory('service', 'Pelayanan'),
    FeedbackCategory('cleanliness', 'Kebersihan'),
    FeedbackCategory('other', 'Lainnya'),
  ];

  final rating = 0.obs;
  final selectedCategory = RxnString();
  final isAnonymous = false.obs;
  final isSubmitting = false.obs;

  final messageController = TextEditingController();

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  void setRating(int value) => rating.value = value;

  void setCategory(String value) => selectedCategory.value = value;

  void toggleAnonymous(bool value) => isAnonymous.value = value;

  Future<void> submit() async {
    if (rating.value < 1 || rating.value > 5) {
      _showError('Pilih rating 1–5 bintang');
      return;
    }
    if (selectedCategory.value == null) {
      _showError('Pilih kategori feedback');
      return;
    }

    isSubmitting.value = true;
    try {
      await FeedbackService.instance.submit(
        rating: rating.value,
        category: selectedCategory.value!,
        message: messageController.text.trim(),
        isAnonymous: isAnonymous.value,
      );
      Get.back();
      _showInfo('Berhasil', 'Terima kasih atas feedback Anda');
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Gagal mengirim feedback');
    } finally {
      isSubmitting.value = false;
    }
  }

  void _showInfo(String title, String message) {
    Get.snackbar(
      title,
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
