import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/membership_model.dart';
import '../../../data/services/api_client.dart';
import '../../../data/services/membership_service.dart';
import '../../../routes/app_routes.dart';

class MembershipController extends GetxController {
  final MembershipService _service = MembershipService.instance;
  final ImagePicker _picker = ImagePicker();

  final RxBool isLoading = false.obs;
  final Rxn<ActiveMembership> active = Rxn<ActiveMembership>();
  final RxList<MembershipPackage> allPackages = <MembershipPackage>[].obs;
  final RxList<MembershipHistoryEntry> historyList =
      <MembershipHistoryEntry>[].obs;

  // Packages tab: Harian | Bulanan | Tahunan
  final RxString selectedPackageType = 'Bulanan'.obs;

  // Renewal/checkout state
  final RxInt renewalStep = 1.obs; // 1: confirm, 2: payment, 3: success
  final RxString selectedPaymentMethod = ''.obs; // transfer | cash | qris
  final Rxn<File> paymentProof = Rxn<File>();
  final RxBool isProcessing = false.obs;
  MembershipPackage? selectedPackageForRenewal;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _service.active(),
        _service.packages(),
        _service.history(),
      ]);
      active.value = results[0] as ActiveMembership?;
      allPackages.value = results[1] as List<MembershipPackage>;
      historyList.value = results[2] as List<MembershipHistoryEntry>;
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Gagal memuat data membership');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Status ──────────────────────────────────────────────────────
  bool get isActive => active.value?.isActive ?? false;
  String get packageName => active.value?.packageName ?? 'Tidak ada paket';
  int get remainingDays => active.value?.remainingDays ?? 0;

  double get progressPercentage {
    final m = active.value;
    if (m == null || m.startDate == null || m.endDate == null) return 0;
    final total = m.endDate!.difference(m.startDate!).inDays;
    if (total <= 0) return 0;
    return (m.remainingDays / total).clamp(0.0, 1.0);
  }

  /// Benefits resolved by matching the active package name against the catalog.
  List<String> get benefits {
    final name = active.value?.packageName;
    if (name == null) return const [];
    final match = allPackages.firstWhereOrNull((p) => p.name == name);
    return match?.benefits ?? const [];
  }

  // ── Packages ────────────────────────────────────────────────────
  void changePackageType(String type) => selectedPackageType.value = type;

  List<MembershipPackage> get packages {
    switch (selectedPackageType.value) {
      case 'Harian':
        return allPackages
            .where((p) => p.type == 'daily' || p.type == 'weekly')
            .toList();
      case 'Tahunan':
        return allPackages.where((p) => p.type == 'yearly').toList();
      case 'Bulanan':
      default:
        return allPackages.where((p) => p.type == 'monthly').toList();
    }
  }

  bool isPopular(MembershipPackage pkg) {
    final list = packages;
    if (list.length < 2) return false;
    final maxPrice = list.map((p) => p.price).reduce((a, b) => a > b ? a : b);
    return pkg.price == maxPrice;
  }

  String periodLabel(MembershipPackage pkg) {
    switch (pkg.type) {
      case 'daily':
        return '/hari';
      case 'weekly':
        return '/minggu';
      case 'yearly':
        return '/tahun';
      case 'monthly':
      default:
        return '/bulan';
    }
  }

  // ── Renewal ─────────────────────────────────────────────────────
  void proceedToRenewal(MembershipPackage pkg) {
    selectedPackageForRenewal = pkg;
    renewalStep.value = 1;
    selectedPaymentMethod.value = '';
    paymentProof.value = null;
    Get.toNamed(Routes.RENEWAL);
  }

  void nextRenewalStep() {
    if (renewalStep.value == 1) {
      renewalStep.value = 2;
    } else if (renewalStep.value == 2) {
      if (selectedPaymentMethod.value.isEmpty) {
        _showError('Pilih metode pembayaran terlebih dahulu');
        return;
      }
      if (selectedPaymentMethod.value == 'transfer' &&
          paymentProof.value == null) {
        _showError('Unggah bukti transfer terlebih dahulu');
        return;
      }
      processPayment();
    } else {
      Get.offAllNamed(Routes.HOME);
    }
  }

  Future<void> pickPaymentProof() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) {
      paymentProof.value = File(image.path);
    }
  }

  Future<void> processPayment() async {
    final pkg = selectedPackageForRenewal;
    if (pkg == null) return;

    isProcessing.value = true;
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    try {
      await _service.renew(
        packageId: pkg.id,
        paymentMethod: selectedPaymentMethod.value,
        paymentProof: paymentProof.value,
      );
      if (Get.isDialogOpen ?? false) Get.back();
      renewalStep.value = 3;
      await loadAll();
    } on ApiException catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      _showError(e.message);
    } catch (_) {
      if (Get.isDialogOpen ?? false) Get.back();
      _showError('Gagal memproses perpanjangan');
    } finally {
      isProcessing.value = false;
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
