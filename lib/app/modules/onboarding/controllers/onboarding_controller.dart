import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class OnboardingController extends GetxController {
  var currentPage = 0.obs;

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void skip() {
    Get.offNamed(Routes.LOGIN);
  }

  void start() {
    Get.offNamed(Routes.LOGIN);
  }
}
