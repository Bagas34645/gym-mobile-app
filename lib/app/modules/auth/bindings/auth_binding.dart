import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // ✅ fenix: true — otomatis recreate controller kalau sudah di-dispose
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
  }
}
