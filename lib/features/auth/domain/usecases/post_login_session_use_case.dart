import 'package:equatable/equatable.dart';
import 'package:rahhala_app/core/auth/auth_session_service.dart';
import 'package:rahhala_app/core/logging/app_logger.dart';
import 'package:rahhala_app/features/auth/domain/entities/login.dart';
import 'package:rahhala_app/features/profile/domain/repositories/user_repository.dart';

class PostLoginSessionResult extends Equatable {
  const PostLoginSessionResult({
    required this.email,
    required this.displayName,
    this.profileImageUrl,
  });

  final String email;
  final String displayName;
  final String? profileImageUrl;

  @override
  List<Object?> get props => [email, displayName, profileImageUrl];
}

class PostLoginSessionUseCase {
  PostLoginSessionUseCase({
    required AuthSessionService authSessionService,
    required UserRepo userRepo,
  })  : _authSessionService = authSessionService,
        _userRepo = userRepo;

  final AuthSessionService _authSessionService;
  final UserRepo _userRepo;

  Future<PostLoginSessionResult> call({
    required Login login,
    required String email,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    await _saveTokens(
      login: login,
      email: normalizedEmail,
    );
    await _fetchProfile(
      fallbackEmail: normalizedEmail,
    );
    await _patchMissingDisplayData(normalizedEmail);

    return PostLoginSessionResult(
      email: _authSessionService.email ?? normalizedEmail,
      displayName:
          _authSessionService.fullName ?? _authSessionService.displayName,
      profileImageUrl: _authSessionService.profileImageUrl,
    );
  }

  Future<void> _saveTokens({
    required Login login,
    required String email,
  }) {
    return _authSessionService.saveSession(
      token: login.token,
      email: email,
      fullName: login.username,
    );
  }

  Future<void> _fetchProfile({
    required String fallbackEmail,
  }) async {
    try {
      final detailsEither = await _userRepo.getDetails();
      await detailsEither.fold(
        (failure) async {
          AppLogger.instance.w(
            'PostLoginSessionUseCase: profile fetch failed',
            error: failure.message,
          );
          await _authSessionService.saveSession(
            email: fallbackEmail,
            fullName: _authSessionService.fullName,
          );
        },
        (details) async {
          await _authSessionService.saveSession(
            email: details.email.isNotEmpty
                ? details.email.trim().toLowerCase()
                : fallbackEmail,
            fullName: details.fullName.trim().isNotEmpty
                ? details.fullName.trim()
                : _authSessionService.fullName,
            profileImageUrl: details.profileImageUrl,
          );
        },
      );
    } catch (e, stackTrace) {
      AppLogger.instance.w(
        'PostLoginSessionUseCase: profile fetch threw after login',
        error: e,
        stackTrace: stackTrace,
      );
      await _authSessionService.saveSession(
        email: fallbackEmail,
        fullName: _authSessionService.fullName,
      );
    }
  }

  Future<void> _patchMissingDisplayData(String email) async {
    final storedName = _authSessionService.fullName;
    if (storedName != null && storedName.trim().isNotEmpty) return;

    final localPart = email.split('@').first;
    final displayName = localPart.isNotEmpty
        ? localPart[0].toUpperCase() + localPart.substring(1)
        : 'User';
    await _authSessionService.saveSession(
      email: email,
      fullName: displayName,
    );
  }
}
