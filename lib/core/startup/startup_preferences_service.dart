import 'package:shared_preferences/shared_preferences.dart';

/// Service abstracting startup-related SharedPreferences access.
///
/// Replaces direct [SharedPreferences] usage in [SplashScreen] and
/// [OnboardingScreen] with a testable, injectable service.
///
/// The storage key `onboarding_done` is intentionally preserved
/// to avoid forcing existing users through onboarding again.
class StartupPreferencesService {
  StartupPreferencesService({required SharedPreferences preferences})
      : _preferences = preferences;

  final SharedPreferences _preferences;

  /// The storage key used for onboarding completion state.
  ///
  /// Must remain `onboarding_done` for backward compatibility
  /// with the existing app install base.
  static const String _onboardingKey = 'onboarding_done';

  /// Whether the user has completed the onboarding flow.
  bool get isOnboardingCompleted =>
      _preferences.getBool(_onboardingKey) ?? false;

  /// Mark onboarding as completed so it won't be shown again.
  Future<void> markOnboardingCompleted() async {
    await _preferences.setBool(_onboardingKey, true);
  }
}
