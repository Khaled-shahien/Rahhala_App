import 'package:equatable/equatable.dart';
import 'package:rahhala_app/core/auth/auth_session_service.dart';
import 'package:rahhala_app/features/onboarding/domain/repositories/onboarding_repository.dart';

enum BootstrapDestination { onboarding, home, welcome }

class BootstrapResult extends Equatable {
  const BootstrapResult({
    required this.destination,
    required this.hasCompletedOnboarding,
    required this.isAuthenticated,
  });

  final BootstrapDestination destination;
  final bool hasCompletedOnboarding;
  final bool isAuthenticated;

  @override
  List<Object?> get props => [
        destination,
        hasCompletedOnboarding,
        isAuthenticated,
      ];
}

class AppBootstrapService {
  AppBootstrapService({
    required OnboardingRepository onboardingRepository,
    required AuthSessionService authSessionService,
  })  : _onboardingRepository = onboardingRepository,
        _authSessionService = authSessionService;

  final OnboardingRepository _onboardingRepository;
  final AuthSessionService _authSessionService;

  Future<BootstrapResult> initialize() async {
    final hasCompletedOnboarding =
        await _onboardingRepository.isOnboardingCompleted();
    final isAuthenticated = _authSessionService.hasToken;

    return BootstrapResult(
      hasCompletedOnboarding: hasCompletedOnboarding,
      isAuthenticated: isAuthenticated,
      destination: !hasCompletedOnboarding
          ? BootstrapDestination.onboarding
          : isAuthenticated
              ? BootstrapDestination.home
              : BootstrapDestination.welcome,
    );
  }
}
