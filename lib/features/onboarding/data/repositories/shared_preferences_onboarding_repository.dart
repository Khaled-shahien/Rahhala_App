import 'package:rahhala_app/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesOnboardingRepository implements OnboardingRepository {
  SharedPreferencesOnboardingRepository({
    required SharedPreferences preferences,
  }) : _preferences = preferences;

  final SharedPreferences _preferences;

  static const String _onboardingKey = 'onboarding_done';

  @override
  Future<bool> isOnboardingCompleted() async {
    return _preferences.getBool(_onboardingKey) ?? false;
  }

  @override
  Future<void> markOnboardingCompleted() async {
    await _preferences.setBool(_onboardingKey, true);
  }
}
