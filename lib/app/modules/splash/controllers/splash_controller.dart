import 'package:get/get.dart';
import '../../../data/services/session_service.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final session = SessionService.to;
    final hasSession = await session.hasSession();

    // Keep the splash visible briefly for branding.
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!hasSession) {
      Get.offAllNamed(Routes.ONBOARDING);
      return;
    }

    // We have stored tokens — try to load the profile. If it fails (expired
    // tokens, etc.) fall back to onboarding/login.
    try {
      final user = await session.loadProfile();
      if (user != null) {
        Get.offAllNamed(Routes.HOME);
        return;
      }
    } catch (_) {
      // ignore and route to onboarding below
    }
    Get.offAllNamed(Routes.ONBOARDING);
  }
}
