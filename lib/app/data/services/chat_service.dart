import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:laravel_echo/laravel_echo.dart';
import 'package:pusher_client_fixed/pusher_client_fixed.dart';

import '../../../core/config/app_config.dart';
import 'api_client.dart';
import 'token_storage.dart';

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
      encrypted: AppConfig.reverbEncrypted,
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
      enableLogging: kDebugMode,
    );

    _echo = Echo(
      broadcaster: EchoBroadcasterType.Pusher,
      client: _pusherClient,
    );

    _pusherClient?.onConnectionError((error) {
      Get.log('Chat connection error: ${error?.message}');
    });

    final completer = Completer<void>();
    _pusherClient?.onConnectionStateChange((state) {
      Get.log('Chat connection state: ${state?.currentState}');
      if (state?.currentState == 'CONNECTED' && !completer.isCompleted) {
        _isInitialized = true;
        completer.complete();
      }
    });
    _pusherClient?.connect();

    try {
      await completer.future.timeout(const Duration(seconds: 5));
    } on TimeoutException {
      Get.log('WebSocket timeout — realtime chat unavailable');
      disconnect();
    }
  }

  Echo? get echo => _echo;

  void disconnect() {
    _pusherClient?.disconnect();
    _echo = null;
    _pusherClient = null;
    _isInitialized = false;
  }

  Future<List<dynamic>> getConversations() async {
    final res = await ApiClient.instance.get('/chat/conversations');
    return res['data'] ?? [];
  }

  Future<Map<String, dynamic>> startConversation(
    String subject,
    String message,
  ) async {
    final res = await ApiClient.instance.post(
      '/chat/conversations',
      data: {
        'subject': subject,
        'message': message,
      },
    );
    return res['data'] as Map<String, dynamic>;
  }

  Future<List<dynamic>> getMessages(String conversationId) async {
    final res = await ApiClient.instance.get(
      '/chat/conversations/$conversationId/messages',
    );
    return res['data'] ?? [];
  }

  Future<Map<String, dynamic>> sendMessage(
    String conversationId,
    String message,
  ) async {
    final res = await ApiClient.instance.post(
      '/chat/conversations/$conversationId/messages',
      data: {'message': message},
    );
    return res['data'] as Map<String, dynamic>;
  }
}
