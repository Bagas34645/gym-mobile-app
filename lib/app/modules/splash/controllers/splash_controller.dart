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

    try {
      final user = await session.loadProfile();
      if (user != null) {
        Get.offAllNamed(Routes.HOME);
        return;
      }
    } catch (_) {
      // ignore
    }
    await session.clearSession();
    Get.offAllNamed(Routes.LOGIN);
  }
}
