import 'package:get/get.dart';
import 'package:gym_mobile_flutter/app/data/services/notification_service.dart';
import 'package:gym_mobile_flutter/app/modules/chat/controllers/chat_controller.dart';
import 'package:gym_mobile_flutter/app/modules/home/controllers/home_controller.dart';
import 'package:gym_mobile_flutter/app/modules/notification/models/notification_model.dart';
import 'package:gym_mobile_flutter/app/data/services/chat_inbox_service.dart';

class NotificationListController extends GetxController {
  final items = <AppNotification>[].obs;
  final isLoading = false.obs;
  final isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load({bool refresh = false}) async {
    if (refresh) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }
    try {
      items.assignAll(await NotificationService.instance.list(perPage: 50));
      if (Get.isRegistered<ChatInboxService>()) {
        await ChatInboxService.to.refreshUnreadFlags();
      }
      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().refreshNotificationBadge();
      }
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Tidak dapat memuat notifikasi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> markAllRead() async {
    try {
      await NotificationService.instance.markAllRead();
      for (var i = 0; i < items.length; i++) {
        final n = items[i];
        if (!n.isRead) {
          items[i] = AppNotification(
            id: n.id,
            title: n.title,
            message: n.message,
            type: n.type,
            data: n.data,
            isRead: true,
            createdAt: n.createdAt,
          );
        }
      }
      items.refresh();
      if (Get.isRegistered<ChatInboxService>()) {
        ChatInboxService.to.clearChatUnreadFlag();
        await ChatInboxService.to.refreshUnreadFlags();
      }
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().hasNotification.value = false;
      }
    } catch (_) {
      Get.snackbar('Gagal', 'Tidak dapat menandai dibaca',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> openItem(AppNotification item) async {
    try {
      if (!item.isRead) {
        await NotificationService.instance.markRead(item.id);
        final idx = items.indexWhere((e) => e.id == item.id);
        if (idx >= 0) {
          final n = items[idx];
          items[idx] = AppNotification(
            id: n.id,
            title: n.title,
            message: n.message,
            type: n.type,
            data: n.data,
            isRead: true,
            createdAt: n.createdAt,
          );
          items.refresh();
        }
        if (Get.isRegistered<ChatInboxService>()) {
          await ChatInboxService.to.refreshUnreadFlags();
        }
        if (Get.isRegistered<HomeController>()) {
          await Get.find<HomeController>().refreshNotificationBadge();
        }
      }
    } catch (_) {}

    if (item.isChat) {
      await ChatController.openFromMenu();
    }
  }
}
