import 'package:get/get.dart';
import '../../../data/models/attendance_model.dart';
import '../../../data/models/membership_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/workout_model.dart';
import '../../../data/services/attendance_service.dart';
import '../../../data/services/membership_service.dart';
import '../../../data/services/notification_service.dart';
import '../../../data/services/session_service.dart';
import '../../../data/services/workout_service.dart';
import '../../../routes/app_routes.dart';

class HomeController extends GetxController {
  final SessionService _session = SessionService.to;

  var currentIndex = 0.obs;

  final RxBool isLoading = false.obs;
  final Rxn<ActiveMembership> membership = Rxn<ActiveMembership>();
  final RxBool hasNotification = false.obs;
  final Rxn<WorkoutPlanModel> todayWorkout = Rxn<WorkoutPlanModel>();
  final RxList<AttendanceModel> recentAttendance = <AttendanceModel>[].obs;

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
      if (_session.currentUser == null) {
        await _session.loadProfile();
      }

      final results = await Future.wait([
        MembershipService.instance.active(),
        WorkoutService.instance.plans(),
        AttendanceService.instance.history(perPage: 5),
        NotificationService.instance.hasUnread(),
      ]);

      membership.value = results[0] as ActiveMembership?;
      final plans = results[1] as List<WorkoutPlanModel>;
      todayWorkout.value = plans.isNotEmpty ? plans.first : null;
      recentAttendance.value = results[2] as List<AttendanceModel>;
      hasNotification.value = results[3] as bool;
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
      Get.toNamed(Routes.CHECKIN);
      return;
    }
    currentIndex.value = index;
  }

  void openTrainerList() {
    Get.toNamed(Routes.TRAINER);
  }
}
