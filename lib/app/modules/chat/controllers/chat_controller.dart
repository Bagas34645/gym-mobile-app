import 'dart:async';

import 'package:get/get.dart';
import 'package:gym_mobile_flutter/app/data/services/api_client.dart';
import 'package:gym_mobile_flutter/app/data/services/chat_inbox_service.dart';
import 'package:gym_mobile_flutter/app/data/services/chat_service.dart';
import 'package:gym_mobile_flutter/app/data/services/session_service.dart';
import 'package:gym_mobile_flutter/app/routes/app_routes.dart';

import '../models/chat_model.dart';

class ChatController extends GetxController {
  final conversations = <ConversationModel>[].obs;
  final messages = <MessageModel>[].obs;
  final isLoading = false.obs;
  final isSending = false.obs;

  final currentConversationId = RxnString();

  @override
  void onInit() {
    super.onInit();
    unawaited(ChatService.instance.initEcho());
    if (Get.isRegistered<ChatInboxService>()) {
      unawaited(ChatInboxService.to.start());
    }
  }

  /// Entry from Home / Profile → opens typing screen directly.
  static Future<void> openFromMenu() async {
    if (!Get.isRegistered<ChatController>()) {
      Get.put(ChatController());
    }
    if (Get.isRegistered<ChatInboxService>()) {
      ChatInboxService.to.clearChatUnreadFlag();
    }
    await Get.find<ChatController>().openSupportChat();
  }

  Future<void> openSupportChat() async {
    isLoading.value = true;
    try {
      await fetchConversations(showError: false);
      final existing = activeConversation;
      if (existing != null) {
        await _bindConversation(existing);
      } else {
        currentConversationId.value = null;
        messages.clear();
      }
    } finally {
      isLoading.value = false;
    }

    if (Get.currentRoute == Routes.CHAT_DETAIL) {
      return;
    }
    if (Get.currentRoute == Routes.CHAT) {
      Get.offNamed(Routes.CHAT_DETAIL);
    } else {
      Get.toNamed(Routes.CHAT_DETAIL);
    }
  }

  Future<void> fetchConversations({bool showError = true}) async {
    try {
      final data = await ChatService.instance.getConversations();
      conversations.value = data
          .map((json) => ConversationModel.fromJson(_asMap(json)))
          .toList();
    } catch (e) {
      if (showError) {
        _showError('Gagal memuat percakapan', e);
      }
      if (showError) rethrow;
    }
  }

  ConversationModel? get activeConversation {
    for (final conversation in conversations) {
      if (conversation.isActive) {
        return conversation;
      }
    }
    return null;
  }

  Future<void> _bindConversation(ConversationModel conversation) async {
    currentConversationId.value = conversation.id;
    messages.clear();
    unawaited(ChatService.instance.initEcho());
    await fetchMessages(conversation.id);
    if (Get.isRegistered<ChatInboxService>()) {
      ChatInboxService.to.watchConversation(conversation.id);
      ChatInboxService.to.clearChatUnreadFlag();
    }
  }

  Future<void> openChat(ConversationModel conversation) async {
    await _bindConversation(conversation);
    if (Get.currentRoute != Routes.CHAT_DETAIL) {
      Get.toNamed(Routes.CHAT_DETAIL);
    }
  }

  Future<void> fetchMessages(String conversationId) async {
    isLoading.value = true;
    try {
      final user = SessionService.to.currentUser;
      if (user == null) {
        throw ApiException('Sesi tidak ditemukan. Silakan login ulang.');
      }

      final data = await ChatService.instance.getMessages(conversationId);
      messages.value = data
          .map((json) => MessageModel.fromJson(_asMap(json), user.id))
          .toList();
    } catch (e) {
      _showError('Gagal memuat pesan', e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    isSending.value = true;
    try {
      final user = SessionService.to.currentUser;
      if (user == null) {
        throw ApiException('Sesi tidak ditemukan. Silakan login ulang.');
      }

      if (currentConversationId.value == null) {
        final response = await ChatService.instance.startConversation(
          'Admin Support',
          trimmed,
        );
        final conversation = ConversationModel.fromJson(response);
        if (!conversations.any((c) => c.id == conversation.id)) {
          conversations.insert(0, conversation);
        }
        currentConversationId.value = conversation.id;

        try {
          messages.assignAll(
            await _loadMessagesAsModels(conversation.id, user.id),
          );
        } catch (_) {
          messages.assignAll([
            MessageModel(
              id: 'local-${DateTime.now().millisecondsSinceEpoch}',
              conversationId: conversation.id,
              senderId: user.id,
              message: trimmed,
              createdAt: DateTime.now(),
              isMe: true,
            ),
          ]);
        }
        if (Get.isRegistered<ChatInboxService>()) {
          ChatInboxService.to.watchConversation(conversation.id);
        }
        return;
      }

      final res = await ChatService.instance.sendMessage(
        currentConversationId.value!,
        trimmed,
      );
      final newMessage = MessageModel.fromJson(res, user.id);
      if (!messages.any((m) => m.id == newMessage.id)) {
        messages.add(newMessage);
      }
    } catch (e) {
      _showError('Gagal mengirim pesan', e);
    } finally {
      isSending.value = false;
    }
  }

  Future<List<MessageModel>> _loadMessagesAsModels(
    String conversationId,
    String userId,
  ) async {
    final data = await ChatService.instance.getMessages(conversationId);
    return data
        .map((json) => MessageModel.fromJson(_asMap(json), userId))
        .toList();
  }

  /// Leaving chat must NOT unsubscribe Echo — inbox notifications rely on it.
  void leaveChat([String? conversationId]) {}

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    throw ApiException('Format data chat tidak valid');
  }

  void _showError(String title, Object error) {
    final message = error is ApiException ? error.message : error.toString();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }
}
