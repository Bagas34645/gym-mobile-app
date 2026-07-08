import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // permanent: true — controller dipakai bersama oleh semua layar auth
    // (Login, Register, OTP, Forgot Password) dan TIDAK boleh di-dispose saat
    // navigasi (mis. Get.offAllNamed). Kalau di-dispose, TextEditingController
    // di dalamnya ikut mati padahal layar Login masih memakainya.
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController(), permanent: true);
    }
  }
}
