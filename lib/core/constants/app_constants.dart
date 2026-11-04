/// General app constants.
///
/// Environment-specific values (URLs, flavor, feature flags) live in
/// `AppConfig` (`lib/core/config/app_config.dart`).
class AppConstants {
  AppConstants._();

  /// App name (brand, not localized).
  static const String appName = 'Rahhala';

  /// Privacy policy URL. It must be live before store submission
  /// (docs/HUMAN_ACTIONS.md).
  static const String privacyPolicyUrl = 'https://rahhala.com/privacy';

  /// Terms of service URL.
  static const String termsOfServiceUrl = 'https://rahhala.com/terms';

  /// Enable analytics tracking. Off by default; enable per flavor through
  /// `config/<flavor>.json` once Firebase is configured and consent copy exists.
  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: false,
  );

  /// Enable crash reporting. Off by default; enable per flavor through
  /// `config/<flavor>.json` once Firebase is configured.
  static const bool enableCrashReporting = bool.fromEnvironment(
    'ENABLE_CRASH_REPORTING',
    defaultValue: false,
  );
}
