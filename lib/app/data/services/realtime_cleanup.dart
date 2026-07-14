import 'package:get/get.dart';

import 'chat_inbox_service.dart';
import 'chat_service.dart';

/// Isolates Echo/Pusher teardown so `AuthService` does not need a hard import
/// that pulls realtime natives into every auth/splash code path.
void disconnectChatRealtime() {
  try {
    if (Get.isRegistered<ChatInboxService>()) {
      ChatInboxService.to.stop();
    }
  } catch (_) {}
  try {
    ChatService.instance.disconnect();
  } catch (_) {
    // Chat may never have been initialized this session.
  }
}
