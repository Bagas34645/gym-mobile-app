import 'package:get/get.dart';
import 'package:gym_mobile_flutter/app/data/services/chat_service.dart';
import 'package:gym_mobile_flutter/app/data/services/session_service.dart';
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
    fetchConversations();
    ChatService.instance.initEcho();
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

  Future<void> openChat(ConversationModel conversation) async {
    currentConversationId.value = conversation.id;
    messages.clear();
    Get.toNamed('/chat-detail');
    if (!ChatService.instance.isInitialized) {
      Get.log('Inisialisasi ulang');
      await ChatService.instance.initEcho();
    }

    await fetchMessages(conversation.id);
    listenToMessages(conversation.id);
  }

  Future<void> startConversation(String initialMessage) async {
    if (initialMessage.trim().isEmpty) return;

    isSending.value = true;
    try {
      final response = await ChatService.instance.startConversation(
        'Admin Support',
        initialMessage,
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

  // Listen to real-time messages using Echo
  void listenToMessages(String conversationId) {
    final echo = ChatService.instance.echo;
    if (echo == null) {
      Get.log('Gagal meendengarkan chat ');
      return;
    }
    final user = SessionService.to.currentUser;
    if (user == null) return;
    echo.private('chat.$conversationId').listen('MessageSent', (e) {
      Get.log('New message received: $e');
      final Map<String, dynamic> data = e is Map
          ? Map<String, dynamic>.from(e)
          : {};

      if (data.containsKey('id')) {
        final newMessage = MessageModel.fromJson(data, user.id);
        if (!messages.any((m) => m.id == newMessage.id)) {
          messages.add(newMessage);
        }
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
    currentConversationId.value = null;
  }
}
