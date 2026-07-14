import 'package:get/get.dart';
import '../../../data/services/chat_inbox_service.dart';
import '../../../data/services/session_service.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    // Wait until the first frame is rendered so the splash UI is visible,
    // then bootstrap with hard timeouts so we never freeze forever.
    Future.microtask(_bootstrap);
  }

  Future<void> _bootstrap() async {
    final session = SessionService.to;

    try {
      final hasSession = await session
          .hasSession()
          .timeout(const Duration(seconds: 3), onTimeout: () => false);

      await Future.delayed(const Duration(milliseconds: 1200));

      if (!hasSession) {
        Get.offAllNamed(Routes.ONBOARDING);
        return;
      }

      final user = await session
          .loadProfile()
          .timeout(const Duration(seconds: 12));

      if (user != null) {
        if (Get.isRegistered<ChatInboxService>()) {
          // ignore: unawaited_futures
          ChatInboxService.to.start();
        }
        Get.offAllNamed(Routes.HOME);
        return;
      }
    } catch (_) {
      // Network / timeout / storage failure — fall through to login.
    }

    try {
      await session
          .clearSession()
          .timeout(const Duration(seconds: 3));
    } catch (_) {
      // ignore clear failure
    }

    if (Get.currentRoute == Routes.SPLASH || Get.currentRoute == '/') {
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
