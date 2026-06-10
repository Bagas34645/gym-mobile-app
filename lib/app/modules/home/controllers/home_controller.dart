import 'package:get/get.dart';
import '../../../data/models/membership_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/membership_service.dart';
import '../../../data/services/session_service.dart';
import '../../../routes/app_routes.dart';

class HomeController extends GetxController {
  final SessionService _session = SessionService.to;

  var currentIndex = 0.obs;

  final RxBool isLoading = false.obs;
  final Rxn<ActiveMembership> membership = Rxn<ActiveMembership>();
  final RxBool hasNotification = false.obs;

  UserModel? get user => _session.currentUser;
  String get userName => _session.currentUser?.name ?? 'Member';

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    try {
      // Make sure we have a profile (in case we deep-linked into home).
      if (_session.currentUser == null) {
        await _session.loadProfile();
      }
      membership.value = await MembershipService.instance.active();
    } catch (_) {
      // Keep whatever we have; dashboard degrades gracefully.
    } finally {
      isLoading.value = false;
    }
  }

  int get remainingDays => membership.value?.remainingDays ?? 0;
  bool get hasActiveMembership => membership.value?.isActive ?? false;

  void changeTab(int index) {
    if (index == 2) {
      // Check-in tab opens the dedicated screen instead of switching tabs.
      Get.toNamed(Routes.CHECKIN);
      return;
    }
    currentIndex.value = index;
  }

  void openTrainerList() {
    Get.toNamed(Routes.TRAINER);
  }
}
