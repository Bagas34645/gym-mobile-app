import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(milliseconds: 2500), () {
      Get.offNamed(Routes.ONBOARDING);
    });
  }
}
