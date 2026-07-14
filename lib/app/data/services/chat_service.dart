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
  Future<void>? _initFuture;

  bool get isInitialized => _isInitialized;

  Future<void> initEcho() async {
    if (_isInitialized) return;
    if (_initFuture != null) return _initFuture;

    _initFuture = _doInitEcho();
    try {
      await _initFuture;
    } finally {
      _initFuture = null;
    }
  }

  Future<void> _doInitEcho() async {
    try {
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

      await completer.future.timeout(const Duration(seconds: 5));
    } on TimeoutException {
      Get.log('WebSocket timeout — chat REST tetap berfungsi');
      // Keep instance for possible later reconnect; mark not ready.
      _isInitialized = false;
    } catch (e) {
      Get.log('Echo init failed: $e');
      disconnect();
    }
  }

  Echo? get echo => _echo;

  void disconnect() {
    try {
      _pusherClient?.disconnect();
    } catch (_) {}
    _echo = null;
    _pusherClient = null;
    _isInitialized = false;
    _initFuture = null;
  }

  Future<List<dynamic>> getConversations() async {
    final res = await ApiClient.instance.get('/chat/conversations');
    final data = res['data'];
    if (data is List) return data;
    return const [];
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
    return _requireMap(res['data'], 'Respons buat percakapan tidak valid');
  }

  Future<List<dynamic>> getMessages(String conversationId) async {
    final res = await ApiClient.instance.get(
      '/chat/conversations/$conversationId/messages',
    );
    final data = res['data'];
    if (data is List) return data;
    return const [];
  }

  Future<Map<String, dynamic>> sendMessage(
    String conversationId,
    String message,
  ) async {
    final res = await ApiClient.instance.post(
      '/chat/conversations/$conversationId/messages',
      data: {'message': message},
    );
    return _requireMap(res['data'], 'Respons kirim pesan tidak valid');
  }

  Map<String, dynamic> _requireMap(dynamic value, String errorMessage) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    throw ApiException(errorMessage);
  }
}
