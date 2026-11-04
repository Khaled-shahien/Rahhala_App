/// Compile-time environment configuration.
///
/// Values come from `--dart-define-from-file=config/<flavor>.json` (or from
/// individual `--dart-define`s). Defaults point at the production backend so
/// a plain `flutter run` keeps working.
///
/// These are public endpoints, not secrets. Never put credentials here:
/// anything compiled into the app can be extracted from the binary.
class AppConfig {
  AppConfig._();

  static const String developmentFlavor = 'development';
  static const String stagingFlavor = 'staging';
  static const String productionFlavor = 'production';

  /// Current build flavor (`development`, `staging` or `production`).
  static const String flavor = String.fromEnvironment(
    'APP_FLAVOR',
    defaultValue: productionFlavor,
  );

  /// Base URL of the main Rahhala REST API.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://rahhallaweb2026.runasp.net',
  );

  /// Base URL of the chatbot (ANIS) backend.
  static const String chatBotBaseUrl = String.fromEnvironment(
    'CHATBOT_BASE_URL',
    defaultValue: 'https://express-js-on-vercel-ten-roan-21.vercel.app',
  );

  /// Optional URL of a remote JSON document used for force-update and
  /// maintenance mode (see `AppUpdateService`). Empty disables the check.
  static const String appConfigUrl = String.fromEnvironment('APP_CONFIG_URL');

  /// Time allowed to establish a TCP/TLS connection.
  static const Duration connectTimeout = Duration(seconds: 20);

  /// Time allowed between response bytes. AI trip generation is slow on the
  /// backend side, so this is deliberately generous.
  static const Duration receiveTimeout = Duration(seconds: 60);

  /// Time allowed to upload a request body (photos for image search).
  static const Duration sendTimeout = Duration(seconds: 60);

  static bool get isProduction => flavor == productionFlavor;
}
