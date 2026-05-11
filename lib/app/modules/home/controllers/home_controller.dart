import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class HomeController extends GetxController {
  var currentIndex = 0.obs;

  // Dashboard Data
  var userName = 'Budi'.obs;
  var remainingDays = 23.obs;
  var hasNotification = true.obs;

  void changeTab(int index) {
    if (index == 2) { // Check-in tab
      Get.toNamed(Routes.CHECKIN);
      return; // Do not change tab, open checkin screen
    }
    currentIndex.value = index;
  }

  void openTrainerList() {
    Get.toNamed(Routes.TRAINER);
  }
}
