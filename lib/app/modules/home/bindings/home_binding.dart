import 'package:get/get.dart';
import '../controllers/home_controller.dart';

import '../../trainer/controllers/trainer_controller.dart';
import '../../trainer/controllers/workout_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<HomeController>(HomeController());
    Get.lazyPut<TrainerController>(() => TrainerController());
    Get.lazyPut<WorkoutController>(() => WorkoutController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
