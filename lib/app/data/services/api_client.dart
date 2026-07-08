import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import '../../../core/config/app_config.dart';
import '../../routes/app_routes.dart';
import 'token_storage.dart';

/// Thrown for failed API calls so callers can show the backend message.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.errorCode, this.errors});

  final String message;
  final int? statusCode;
  final String? errorCode;
  final Map<String, dynamic>? errors;

  @override
  String toString() => message;
}

/// Singleton Dio wrapper that injects the Bearer token, unwraps the standard
/// `{ success, message, data }` envelope, and transparently refreshes the
/// access token on a 401.
class ApiClient {
  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.extra['skipAuth'] != true) {
            final token = await TokenStorage.instance.accessToken;
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final response = error.response;
          final isUnauthorized = response?.statusCode == 401;
          final alreadyRetried = error.requestOptions.extra['retried'] == true;
          final skipAuth = error.requestOptions.extra['skipAuth'] == true;

          if (isUnauthorized && !alreadyRetried && !skipAuth) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              try {
                final clone = await _retry(error.requestOptions);
                return handler.resolve(clone);
              } catch (_) {
                // fall through to logout below
              }
            }
            await _forceLogout();
          }
          handler.next(error);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._();

  late final Dio _dio;

  Future<bool> _refreshToken() async {
    final refresh = await TokenStorage.instance.refreshToken;
    if (refresh == null) return false;
    try {
      final res = await Dio(BaseOptions(baseUrl: AppConfig.baseUrl)).post(
        '/auth/refresh',
        data: {'refresh_token': refresh},
      );
      final data = res.data['data'] as Map<String, dynamic>?;
      if (data != null && data['access_token'] != null) {
        await TokenStorage.instance.saveTokens(
          accessToken: data['access_token'] as String,
          refreshToken: (data['refresh_token'] ?? refresh) as String,
        );
        return true;
      }
    } catch (_) {
      // ignore
    }
    return false;
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final freshToken = await TokenStorage.instance.accessToken;
    return _dio.fetch(
      requestOptions
        ..extra['retried'] = true
        ..headers['Authorization'] = freshToken != null ? 'Bearer $freshToken' : null,
    );
  }

  Future<void> _forceLogout() async {
    await TokenStorage.instance.clear();
    if (Get.currentRoute != Routes.LOGIN) {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  // ── Public helpers ──────────────────────────────────────────────

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    return _unwrap(() => _dio.get(path, queryParameters: query));
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Object? data,
    bool skipAuth = false,
  }) async {
    return _unwrap(
      () => _dio.post(
        path,
        data: data,
        options: Options(extra: {'skipAuth': skipAuth}),
      ),
    );
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Object? data,
  }) async {
    return _unwrap(() => _dio.put(path, data: data));
  }

  Future<Map<String, dynamic>> delete(String path) async {
    return _unwrap(() => _dio.delete(path));
  }

  Future<Map<String, dynamic>> postMultipart(
    String path,
    FormData formData,
  ) async {
    return _unwrap(() => _dio.post(path, data: formData));
  }

  /// Laravel doesn't parse `multipart/form-data` on PUT, so we POST with a
  /// `_method=PUT` override (method spoofing) which Laravel understands.
  Future<Map<String, dynamic>> putMultipart(
    String path,
    FormData formData,
  ) async {
    formData.fields.add(const MapEntry('_method', 'PUT'));
    return _unwrap(() => _dio.post(path, data: formData));
  }

  Future<Map<String, dynamic>> _unwrap(
    Future<Response<dynamic>> Function() call,
  ) async {
    try {
      final res = await call();
      final body = res.data;
      if (body is Map<String, dynamic>) {
        if (body['success'] == true) return body;
        throw ApiException(
          (body['message'] ?? 'Terjadi kesalahan').toString(),
          statusCode: res.statusCode,
          errorCode: body['error_code']?.toString(),
          errors: body['errors'] as Map<String, dynamic>?,
        );
      }
      throw ApiException('Respons tidak valid', statusCode: res.statusCode);
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        throw ApiException(
          (data['message'] ?? 'Gagal terhubung ke server').toString(),
          statusCode: e.response?.statusCode,
          errorCode: data['error_code']?.toString(),
          errors: data['errors'] as Map<String, dynamic>?,
        );
      }
      throw ApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
