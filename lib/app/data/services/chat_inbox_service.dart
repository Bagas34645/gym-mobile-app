import 'dart:async';

import 'package:get/get.dart';

import '../../modules/chat/controllers/chat_controller.dart';
import '../../modules/chat/models/chat_model.dart';
import '../../modules/home/controllers/home_controller.dart';
import '../../routes/app_routes.dart';
import 'chat_service.dart';
import 'local_notification_service.dart';
import 'notification_service.dart';
import 'session_service.dart';

/// Realtime chat + polling inbox for admin notifications and chat alerts.
class ChatInboxService extends GetxService {
  static ChatInboxService get to => Get.find<ChatInboxService>();

  final hasUnreadChat = false.obs;
  final hasUnreadAny = false.obs;

  String? _listeningConversationId;
  bool _starting = false;
  Timer? _pollTimer;
  final Set<String> _shownIds = {};

  Future<ChatInboxService> init() async => this;

  Future<void> start() async {
    if (_starting) return;
    _starting = true;
    try {
      await LocalNotificationService.instance.init();
      await ChatService.instance.initEcho();
      await _subscribeActiveConversation();
      _startPoll();
      await _pollUnread(showBanners: false);
    } catch (e) {
      Get.log('ChatInboxService.start failed: $e');
      _startPoll();
    } finally {
      _starting = false;
    }
  }

  Future<void> stop() async {
    _pollTimer?.cancel();
    _pollTimer = null;
    _leaveCurrent();
    hasUnreadChat.value = false;
    hasUnreadAny.value = false;
    _shownIds.clear();
  }

  void clearChatUnreadFlag() {
    hasUnreadChat.value = false;
    _refreshHomeBadge();
  }

  Future<void> refreshUnreadFlags() async {
    try {
      final unread = await NotificationService.instance.unreadList();
      hasUnreadChat.value = unread.any((n) => n.isChat);
      hasUnreadAny.value = unread.isNotEmpty;
      _refreshHomeBadge();
    } catch (_) {}
  }

  void _refreshHomeBadge() {
    if (Get.isRegistered<HomeController>()) {
      unawaited(Get.find<HomeController>().refreshNotificationBadge());
    }
  }

  void _startPoll() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      unawaited(_pollUnread(showBanners: true));
    });
  }

  Future<void> _pollUnread({required bool showBanners}) async {
    try {
      final list = await NotificationService.instance.unreadList();
      hasUnreadChat.value = list.any((n) => n.isChat);
      hasUnreadAny.value = list.isNotEmpty;
      _refreshHomeBadge();

      if (!showBanners || list.isEmpty) return;

      final onNotificationPage = Get.currentRoute == Routes.NOTIFICATION;
      final onChatScreen =
          Get.currentRoute == Routes.CHAT_DETAIL || Get.currentRoute == Routes.CHAT;

      // Prefer showing the newest unread item that we haven't bannered yet.
      for (final item in list) {
        if (_shownIds.contains(item.id)) continue;

        if (item.isChat && onChatScreen) {
          _shownIds.add(item.id);
          continue;
        }
        if (!item.isChat && onNotificationPage) {
          _shownIds.add(item.id);
          continue;
        }

        _shownIds.add(item.id);
        await LocalNotificationService.instance.show(
          title: item.title,
          body: item.message,
          payload: item.isChat
              ? 'chat:${item.conversationId ?? ''}'
              : 'notification:${item.id}',
        );
        break;
      }
    } catch (e) {
      Get.log('Notification poll failed: $e');
    }
  }

  Future<void> _subscribeActiveConversation() async {
    try {
      final raw = await ChatService.instance.getConversations();
      ConversationModel? active;
      for (final item in raw) {
        if (item is! Map) continue;
        final c = ConversationModel.fromJson(Map<String, dynamic>.from(item));
        if (c.isActive) {
          active = c;
          break;
        }
      }
      if (active == null && raw.isNotEmpty && raw.first is Map) {
        active = ConversationModel.fromJson(
          Map<String, dynamic>.from(raw.first as Map),
        );
      }
      if (active != null) _listen(active.id);
    } catch (e) {
      Get.log('ChatInbox subscribe failed: $e');
    }
  }

  void watchConversation(String conversationId) {
    if (conversationId.isEmpty) return;
    _listen(conversationId);
  }

  void _leaveCurrent() {
    if (_listeningConversationId == null) return;
    ChatService.instance.echo?.leave('chat.$_listeningConversationId');
    _listeningConversationId = null;
  }

  void _listen(String conversationId) {
    final echo = ChatService.instance.echo;
    if (echo == null) return;
    final user = SessionService.to.currentUser;
    if (user == null) return;
    if (_listeningConversationId == conversationId) return;

    _leaveCurrent();
    _listeningConversationId = conversationId;

    echo.private('chat.$conversationId').listen('.message.sent', (event) {
      final raw =
          event is Map ? Map<String, dynamic>.from(event) : <String, dynamic>{};
      final data = raw.containsKey('id')
          ? raw
          : (raw['data'] is Map
              ? Map<String, dynamic>.from(raw['data'] as Map)
              : raw);
      if (!data.containsKey('id')) return;

      final message = MessageModel.fromJson(data, user.id);
      if (message.isMe) return;
      _onAdminChatMessage(message);
    });
  }

  void _onAdminChatMessage(MessageModel message) {
    if (_shownIds.contains('msg:${message.id}')) return;
    _shownIds.add('msg:${message.id}');

    hasUnreadChat.value = true;
    hasUnreadAny.value = true;
    _refreshHomeBadge();

    if (Get.isRegistered<ChatController>()) {
      final chat = Get.find<ChatController>();
      if (chat.currentConversationId.value == message.conversationId &&
          !chat.messages.any((m) => m.id == message.id)) {
        chat.messages.add(message);
      }
    }

    final onChatScreen =
        Get.currentRoute == Routes.CHAT_DETAIL || Get.currentRoute == Routes.CHAT;
    if (onChatScreen) return;

    unawaited(
      LocalNotificationService.instance.show(
        title: 'Pesan dari Admin Support',
        body: message.message,
        payload: 'chat:${message.conversationId}',
      ),
    );
  }
}
