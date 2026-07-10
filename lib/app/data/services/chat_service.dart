import 'dart:async';
import 'package:laravel_echo/laravel_echo.dart';
import 'package:pusher_client_fixed/pusher_client_fixed.dart';
import 'package:get/get.dart';
import '../../../core/config/app_config.dart';
import 'token_storage.dart';
import 'api_client.dart';

class ChatService {
  ChatService._();
  static final ChatService instance = ChatService._();

  Echo? _echo;
  PusherClient? _pusherClient;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initEcho() async {
    if (_isInitialized) return;

    final token = await TokenStorage.instance.accessToken;
    if (token == null) return;

    final options = PusherOptions(
      host: AppConfig.reverbHost,
      wsPort: AppConfig.reverbPort,
      encrypted: false,
      cluster: 'mt1',
      auth: PusherAuth(
        AppConfig.authUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );

    _pusherClient = PusherClient(
      AppConfig.reverbKey,
      options,
      autoConnect: false,
      enableLogging: true,
    );

    _echo = Echo(
      broadcaster: EchoBroadcasterType.Pusher,
      client: _pusherClient,
    );

    _pusherClient?.onConnectionError((error) {
      Get.log('Chat Connection Error: ${error?.message}');
    });

    // Gunakan Completer untuk menunggu koneksi benar-benar siap
    final completer = Completer<void>();
    _pusherClient?.onConnectionStateChange((state) {
      Get.log('Chat Connection State: ${state?.currentState}');
      if (state?.currentState == 'CONNECTED' && !completer.isCompleted) {
        _isInitialized = true;
        completer.complete();
      }
    });
    _pusherClient?.connect();

    // Tunggu maksimal 5 detik untuk koneksi siap
    await completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        Get.log('WebSocket timeout, mencoba lanjut...');
        _isInitialized = true; // tetap lanjut meski timeout
      },
    );

    // _pusherClient?.onConnectionStateChange((state) {
    //   Get.log('Chat Connection State: ${state?.currentState}');
    // });

    // _pusherClient?.connect();
    // _isInitialized = true;
  }

  Echo? get echo => _echo;

  void disconnect() {
    _pusherClient?.disconnect();
    _echo = null;
    _pusherClient = null;
    _isInitialized = false;
  }

  // API Helpers
  Future<List<dynamic>> getConversations() async {
    final res = await ApiClient.instance.get('/chat/conversations');
    return res['data'] ?? [];
  }

  // 1. Ubah int menjadi String untuk ID Percakapan
  Future<Map<String, dynamic>> startConversation(
    String subject,
    String message,
  ) async {
    final res = await ApiClient.instance.post(
      '/chat/conversations',
      data: {
        'subject': subject, // API minta subject
        'message': message, // API minta initial message
      },
    );
    return res['data'];
  }

  // 2. Ubah int menjadi String karena ID kita adalah UUID
  Future<List<dynamic>> getMessages(String conversationId) async {
    final res = await ApiClient.instance.get(
      '/chat/conversations/$conversationId/messages',
    );
    return res['data'] ?? [];
  }

  // 3. Ubah int menjadi String untuk conversationId
  Future<Map<String, dynamic>> sendMessage(
    String conversationId,
    String message,
  ) async {
    final res = await ApiClient.instance.post(
      '/chat/conversations/$conversationId/messages',
      data: {'message': message},
    );
    return res['data'];
  }
}
