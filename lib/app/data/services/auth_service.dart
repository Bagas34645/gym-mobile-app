import 'dart:io';

import 'package:dio/dio.dart';

import 'api_client.dart';
import 'token_storage.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final ApiClient _api = ApiClient.instance;

  /// Logs in with email/phone + password and persists the tokens.
  /// Returns the `member` payload from the API.
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final body = await _api.post(
      '/auth/login',
      data: {'identifier': identifier, 'password': password},
      skipAuth: true,
    );

    final data = body['data'] as Map<String, dynamic>;
    await TokenStorage.instance.saveTokens(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
    );
    return (data['member'] as Map<String, dynamic>?) ?? {};
  }

  /// Registers a new member. The API does NOT return tokens here — the caller
  /// must log in afterwards. Returns the created member payload.
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    final body = await _api.post(
      '/auth/register',
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
      skipAuth: true,
    );
    return (body['data'] as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> me() async {
    final body = await _api.get('/auth/me');
    return (body['data'] as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    int? age,
    int? heightCm,
    double? weightKg,
    String? fitnessGoal,
    File? photo,
  }) async {
    final form = <String, dynamic>{
      if (name != null) 'name': name,
      if (age != null) 'age': age,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (fitnessGoal != null) 'fitness_goal': fitnessGoal,
    };
    if (photo != null) {
      form['profile_photo'] = await MultipartFile.fromFile(
        photo.path,
        filename: 'profile.jpg',
      );
    }
    final body = await _api.putMultipart('/auth/me', FormData.fromMap(form));
    return (body['data'] as Map<String, dynamic>?) ?? {};
  }

  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _api.put(
      '/auth/me/password',
      data: {
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  Future<int> forgotPassword({
    required String identifier,
    String method = 'email',
  }) async {
    final body = await _api.post(
      '/auth/forgot-password',
      data: {'identifier': identifier, 'method': method},
      skipAuth: true,
    );
    final data = body['data'] as Map<String, dynamic>?;
    return (data?['expires_in'] as num?)?.toInt() ?? 300;
  }

  Future<void> verifyOtp({
    required String identifier,
    required String code,
  }) async {
    await _api.post(
      '/auth/verify-otp',
      data: {'identifier': identifier, 'code': code},
      skipAuth: true,
    );
  }

  Future<void> resendOtp({required String identifier}) async {
    await _api.post(
      '/auth/resend-otp',
      data: {'identifier': identifier},
      skipAuth: true,
    );
  }

  Future<void> resetPassword({
    required String identifier,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _api.post(
      '/auth/reset-password',
      data: {
        'identifier': identifier,
        'code': code,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
      skipAuth: true,
    );
  }

  Future<void> logout() async {
    try {
      final refresh = await TokenStorage.instance.refreshToken;
      await _api.post(
        '/auth/logout',
        data: refresh != null ? {'refresh_token': refresh} : null,
      );
    } catch (_) {
      // best-effort; clear locally regardless
    }
    await TokenStorage.instance.clear();
  }
}
