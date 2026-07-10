import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  String? _listeningConversationId;

  @override
  void onInit() {
    super.onInit();
    fetchConversations();
    ChatService.instance.initEcho();
  }

  @override
  void onClose() {
    if (_listeningConversationId != null) {
      ChatService.instance.echo?.leave('chat.$_listeningConversationId');
    }
    super.onClose();
  }

  Future<void> fetchConversations() async {
    isLoading.value = true;
    try {
      final data = await ChatService.instance.getConversations();
      conversations.value = data
          .map(
            (json) => ConversationModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat percakapan: $e');
    } finally {
      isLoading.value = false;
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

  Future<void> startOrOpenChat({String? initialMessage}) async {
    final existing = activeConversation;
    if (existing != null) {
      await openChat(existing);
      if (initialMessage != null && initialMessage.trim().isNotEmpty) {
        await sendMessage(initialMessage);
      }
      return;
    }

    final message = initialMessage?.trim();
    if (message == null || message.isEmpty) {
      return;
    }

    isSending.value = true;
    try {
      final response = await ChatService.instance.startConversation(
        'Admin Support',
        message,
      );

      final conversation = ConversationModel.fromJson(response);
      if (!conversations.any((c) => c.id == conversation.id)) {
        conversations.insert(0, conversation);
      }

      await openChat(conversation);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memulai percakapan: $e');
    } finally {
      isSending.value = false;
    }
  }

  Future<void> openChat(ConversationModel conversation) async {
    if (_listeningConversationId != null &&
        _listeningConversationId != conversation.id) {
      ChatService.instance.echo?.leave('chat.$_listeningConversationId');
      _listeningConversationId = null;
    }

    currentConversationId.value = conversation.id;
    messages.clear();
    await Get.toNamed(Routes.CHAT_DETAIL);

    if (!ChatService.instance.isInitialized) {
      await ChatService.instance.initEcho();
    }

    await fetchMessages(conversation.id);
    listenToMessages(conversation.id);
  }

  Future<void> fetchMessages(String conversationId) async {
    isLoading.value = true;
    try {
      final user = SessionService.to.currentUser;
      if (user == null) return;

      final data = await ChatService.instance.getMessages(conversationId);
      messages.value = data
          .map(
            (json) =>
                MessageModel.fromJson(json as Map<String, dynamic>, user.id),
          )
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat pesan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void listenToMessages(String conversationId) {
    final echo = ChatService.instance.echo;
    if (echo == null) {
      Get.log('Echo unavailable — chat will not update in realtime');
      return;
    }

    final user = SessionService.to.currentUser;
    if (user == null) return;

    if (_listeningConversationId != null &&
        _listeningConversationId != conversationId) {
      echo.leave('chat.$_listeningConversationId');
    }

    _listeningConversationId = conversationId;
    echo.private('chat.$conversationId').listen('.message.sent', (event) {
      final data = event is Map ? Map<String, dynamic>.from(event) : <String, dynamic>{};
      if (!data.containsKey('id')) return;

      final newMessage = MessageModel.fromJson(data, user.id);
      if (!messages.any((m) => m.id == newMessage.id)) {
        messages.add(newMessage);
      }
    });
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || currentConversationId.value == null) return;

    isSending.value = true;
    try {
      final user = SessionService.to.currentUser;
      if (user == null) return;

      final res = await ChatService.instance.sendMessage(
        currentConversationId.value!,
        text,
      );
      final newMessage = MessageModel.fromJson(res, user.id);

      if (!messages.any((m) => m.id == newMessage.id)) {
        messages.add(newMessage);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengirim pesan: $e');
    } finally {
      isSending.value = false;
    }
  }

  void leaveChat(String conversationId) {
    ChatService.instance.echo?.leave('chat.$conversationId');
    if (_listeningConversationId == conversationId) {
      _listeningConversationId = null;
    }
    currentConversationId.value = null;
  }

  Future<String?> promptInitialMessage() async {
    final controller = TextEditingController();
    final result = await Get.dialog<String>(
      AlertDialog(
        title: const Text('Chat dengan Admin'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Tulis pesan untuk admin...',
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Batal')),
          TextButton(
            onPressed: () => Get.back(result: controller.text.trim()),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }
}
