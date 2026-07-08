import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure persistence for the JWT access/refresh tokens.
class TokenStorage {
  TokenStorage._();

  static final TokenStorage instance = TokenStorage._();

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _rememberedIdentifierKey = 'remembered_identifier';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  Future<String?> get accessToken => _storage.read(key: _accessKey);

  Future<String?> get refreshToken => _storage.read(key: _refreshKey);

  Future<bool> get hasSession async => (await accessToken) != null;

  Future<void> saveRememberedIdentifier(String identifier) async {
    await _storage.write(key: _rememberedIdentifierKey, value: identifier);
  }

  Future<String?> get rememberedIdentifier =>
      _storage.read(key: _rememberedIdentifierKey);

  Future<void> clearRememberedIdentifier() async {
    await _storage.delete(key: _rememberedIdentifierKey);
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}
