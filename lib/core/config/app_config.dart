class AppConfig {
  AppConfig._();

  /// Base URL of the Laravel API (prefix `/v1`).
  ///
  /// Override at build time with:
  /// `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/v1`
  ///
  /// Note: Android emulators reach the host machine via `10.0.2.2`, not
  /// `localhost`.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/v1',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
