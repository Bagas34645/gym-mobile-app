import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class MembershipController extends GetxController {
  // Membership Status State
  var isActive = true.obs;
  var packageName = 'Paket Bulanan Premium'.obs;
  var startDate = '1 Juli 2025'.obs;
  var endDate = '31 Juli 2025'.obs;
  var remainingDays = 23.obs;
  var progressPercentage = 0.75.obs; // 75% remaining

  List<String> benefits = [
    'Akses gym tanpa batas',
    'Gratis 1x Personal Trainer',
    'Akses kelas grup',
    'Fasilitas loker premium',
  ];

  // Packages List State
  var selectedPackageType = 'Bulanan'.obs; // Harian, Bulanan, Tahunan

  List<Map<String, dynamic>> get packages {
    if (selectedPackageType.value == 'Harian') {
      return [
        {
          'id': 1,
          'name': 'Day Pass',
          'price': 'Rp 50.000',
          'period': '/hari',
          'isPopular': false,
          'benefits': ['Akses gym 1 hari', 'Loker standar'],
        }
      ];
    } else if (selectedPackageType.value == 'Bulanan') {
      return [
        {
          'id': 2,
          'name': 'Basic Monthly',
          'price': 'Rp 300.000',
          'period': '/bulan',
          'isPopular': false,
          'benefits': ['Akses gym tanpa batas', 'Loker standar'],
        },
        {
          'id': 3,
          'name': 'Premium Monthly',
          'price': 'Rp 450.000',
          'period': '/bulan',
          'isPopular': true,
          'benefits': ['Akses gym tanpa batas', 'Gratis 1x PT', 'Akses kelas grup', 'Loker premium'],
        }
      ];
    } else {
      return [
        {
          'id': 4,
          'name': 'Yearly VIP',
          'price': 'Rp 4.500.000',
          'period': '/tahun',
          'isPopular': true,
          'benefits': ['Semua fitur Premium', 'Gratis 12x PT', 'Merchandise eksklusif', 'Loker VIP'],
        }
      ];
    }
  }

  // Renewal/Checkout State
  var renewalStep = 1.obs; // 1: Select Package, 2: Payment, 3: Success
  var selectedPaymentMethod = ''.obs;
  Map<String, dynamic>? selectedPackageForRenewal;

  void changePackageType(String type) {
    selectedPackageType.value = type;
  }

  void proceedToRenewal(Map<String, dynamic> pkg) {
    selectedPackageForRenewal = pkg;
    renewalStep.value = 1;
    selectedPaymentMethod.value = '';
    Get.toNamed(Routes.RENEWAL);
  }

  void nextRenewalStep() {
    if (renewalStep.value == 1) {
      renewalStep.value = 2;
    } else if (renewalStep.value == 2) {
      if (selectedPaymentMethod.value.isEmpty) {
        Get.snackbar('Peringatan', 'Pilih metode pembayaran terlebih dahulu', snackPosition: SnackPosition.BOTTOM);
        return;
      }
      processPayment();
    } else {
      Get.offAllNamed(Routes.HOME);
    }
  }

  void processPayment() async {
    // Simulate loading
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    await Future.delayed(const Duration(seconds: 2));
    Get.back(); // close dialog
    renewalStep.value = 3;
    isActive.value = true;
    remainingDays.value += 30; // Mock extension
  }

  // History State
  List<Map<String, dynamic>> history = [
    {
      'packageName': 'Paket Bulanan Premium',
      'startDate': '1 Jul 2025',
      'endDate': '31 Jul 2025',
      'status': 'Aktif',
      'price': 'Rp 450.000',
    },
    {
      'packageName': 'Basic Monthly',
      'startDate': '1 Jun 2025',
      'endDate': '30 Jun 2025',
      'status': 'Expired',
      'price': 'Rp 300.000',
    },
    {
      'packageName': 'Day Pass',
      'startDate': '15 Mei 2025',
      'endDate': '15 Mei 2025',
      'status': 'Expired',
      'price': 'Rp 50.000',
    }
  ];
}
