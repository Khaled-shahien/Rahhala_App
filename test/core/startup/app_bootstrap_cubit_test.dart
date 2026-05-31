import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rahhala_app/core/auth/auth_session_service.dart';
import 'package:rahhala_app/core/startup/app_bootstrap_cubit.dart';
import 'package:rahhala_app/core/startup/app_bootstrap_service.dart';
import 'package:rahhala_app/features/onboarding/domain/repositories/onboarding_repository.dart';

class _FakeOnboardingRepository implements OnboardingRepository {
  _FakeOnboardingRepository(this.completed);

  bool completed;

  @override
  Future<bool> isOnboardingCompleted() async => completed;

  @override
  Future<void> markOnboardingCompleted() async {
    completed = true;
  }
}

class _FakeAuthSessionService implements AuthSessionService {
  _FakeAuthSessionService({required this.hasToken});

  @override
  final bool hasToken;

  @override
  String? get token => hasToken ? 'token' : null;

  @override
  String? get username => null;

  @override
  String? get email => null;

  @override
  String? get fullName => null;

  @override
  String? get profileImageUrl => null;

  @override
  String get displayName => 'User';

  @override
  CurrentUserBasicInfo get currentUser => const CurrentUserBasicInfo();

  @override
  Future<void> saveSession({
    String? token,
    String? username,
    String? email,
    String? fullName,
    String? profileImageUrl,
  }) async {}

  @override
  Future<void> clearSession() async {}

  @override
  Future<void> logout() async {}
}

class _MockAppBootstrapService extends Mock implements AppBootstrapService {}

void main() {
  Future<BootstrapResult> initialize({
    required bool onboardingCompleted,
    required bool authenticated,
  }) {
    final service = AppBootstrapService(
      onboardingRepository: _FakeOnboardingRepository(onboardingCompleted),
      authSessionService: _FakeAuthSessionService(hasToken: authenticated),
    );
    return service.initialize();
  }

  test('routes to onboarding before onboarding is completed', () async {
    final result = await initialize(
      onboardingCompleted: false,
      authenticated: true,
    );

    expect(result.destination, BootstrapDestination.onboarding);
  });

  test('routes authenticated users to home', () async {
    final result = await initialize(
      onboardingCompleted: true,
      authenticated: true,
    );

    expect(result.destination, BootstrapDestination.home);
  });

  test('routes unauthenticated users to welcome', () async {
    final result = await initialize(
      onboardingCompleted: true,
      authenticated: false,
    );

    expect(result.destination, BootstrapDestination.welcome);
  });

  blocTest<AppBootstrapCubit, AppBootstrapState>(
    'emits loading then ready',
    build: () {
      final service = _MockAppBootstrapService();
      when(() => service.initialize()).thenAnswer(
        (_) async => const BootstrapResult(
          destination: BootstrapDestination.home,
          hasCompletedOnboarding: true,
          isAuthenticated: true,
        ),
      );
      return AppBootstrapCubit(service: service);
    },
    act: (cubit) => cubit.initialize(),
    wait: const Duration(seconds: 4),
    expect: () => [
      const AppBootstrapLoading(),
      isA<AppBootstrapReady>().having(
        (state) => state.result.destination,
        'destination',
        BootstrapDestination.home,
      ),
    ],
  );
}
