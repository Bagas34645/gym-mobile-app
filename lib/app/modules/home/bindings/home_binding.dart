import 'package:get/get.dart';
import '../controllers/home_controller.dart';

import '../../trainer/controllers/trainer_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<HomeController>(HomeController());
    Get.put<TrainerController>(TrainerController());
    Get.put<ProfileController>(ProfileController());
  }
}
