import 'package:get/get.dart';
import '../controllers/trainer_controller.dart';

class TrainerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrainerController>(() => TrainerController());
  }
}
