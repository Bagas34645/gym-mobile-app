import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/membership_model.dart';
import '../../../data/services/api_client.dart';
import '../../../data/services/membership_service.dart';
import '../../../data/services/payment_service.dart';
import '../../../routes/app_routes.dart';

class MembershipController extends GetxController {
  final MembershipService _service = MembershipService.instance;
  final PaymentService _paymentService = PaymentService.instance;

  final RxBool isLoading = false.obs;
  final Rxn<ActiveMembership> active = Rxn<ActiveMembership>();
  final RxList<MembershipPackage> allPackages = <MembershipPackage>[].obs;
  final RxList<MembershipHistoryEntry> historyList =
      <MembershipHistoryEntry>[].obs;

  // Packages tab: Harian | Bulanan | Tahunan
  final RxString selectedPackageType = 'Bulanan'.obs;

  // Renewal/checkout state
  final RxInt renewalStep = 1.obs; // 1: confirm, 2: payment, 3: success
  final RxString selectedPaymentMethod = ''.obs; // midtrans | cash
  final RxString paymentResultType =
      'cash_pending'.obs; // cash_pending | midtrans_success | midtrans_failed
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
    paymentResultType.value = 'cash_pending';
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
      processPayment();
    } else {
      Get.offAllNamed(Routes.HOME);
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
      if (selectedPaymentMethod.value == 'midtrans') {
        await _processMidtransPayment(pkg);
      } else {
        await _service.renew(
          packageId: pkg.id,
          paymentMethod: 'cash',
        );
        paymentResultType.value = 'cash_pending';
        renewalStep.value = 3;
      }
      if (Get.isDialogOpen ?? false) Get.back();
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

  Future<void> _processMidtransPayment(MembershipPackage pkg) async {
    final snap = await _paymentService.createSnapPayment(pkg.id);

    if (Get.isDialogOpen ?? false) Get.back();

    final completed = await Get.toNamed(
      Routes.MIDTRANS_PAYMENT,
      arguments: {
        'redirect_url': snap.redirectUrl,
        'order_id': snap.orderId,
      },
    );

    if (completed != true) {
      paymentResultType.value = 'midtrans_failed';
      renewalStep.value = 3;
      return;
    }

    final paid = await _pollPaymentStatus(snap.orderId);
    paymentResultType.value = paid ? 'midtrans_success' : 'midtrans_failed';
    renewalStep.value = 3;
  }

  Future<bool> _pollPaymentStatus(String orderId) async {
    for (var attempt = 0; attempt < 15; attempt++) {
      await Future.delayed(const Duration(seconds: 2));
      try {
        final status = await _paymentService.getPaymentStatus(orderId);
        if (status.isPaid) return true;
        if (status.renewalStatus == 'rejected') return false;
      } on ApiException {
        // keep polling
      }
    }
    return false;
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
