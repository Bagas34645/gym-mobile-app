import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import 'dart:developer';

class HomeController extends GetxController {
  Future<void> showToken() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final token = await user.getIdToken();

      log('JWT TOKEN: $token', name: 'AUTH');
      log('User Session Active: ${user.email}', name: 'AUTH');
    }
  }

  var currentIndex = 0.obs;

  // Dashboard Data
  var userName = 'User'.obs;
  var remainingDays = 23.obs;
  var hasNotification = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    showToken();
  }

  void loadUserData() {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      userName.value = user.displayName ?? user.email ?? 'User';
    }
  }

  void changeTab(int index) {
    if (index == 2) {
      // Check-in tab
      Get.toNamed(Routes.CHECKIN);
      return; // Do not change tab, open checkin screen
    }
    currentIndex.value = index;
  }

  void openTrainerList() {
    Get.toNamed(Routes.TRAINER);
  }
}
