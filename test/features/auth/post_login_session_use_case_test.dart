import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rahhala_app/core/auth/auth_session_service.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/features/auth/domain/entities/login.dart';
import 'package:rahhala_app/features/auth/domain/entities/success_message.dart';
import 'package:rahhala_app/features/auth/domain/usecases/post_login_session_use_case.dart';
import 'package:rahhala_app/features/profile/domain/entities/user_details.dart';
import 'package:rahhala_app/features/profile/domain/repositories/user_repository.dart';

class _RecordingAuthSessionService implements AuthSessionService {
  @override
  String? token;
  @override
  String? username;
  @override
  String? email;
  @override
  String? fullName;
  @override
  String? profileImageUrl;

  int saveCount = 0;

  @override
  bool get hasToken => token != null;

  @override
  String get displayName => fullName ?? username ?? 'User';

  @override
  CurrentUserBasicInfo get currentUser => CurrentUserBasicInfo(
        username: username,
        email: email,
        fullName: fullName,
        profileImageUrl: profileImageUrl,
      );

  @override
  Future<void> saveSession({
    String? token,
    String? username,
    String? email,
    String? fullName,
    String? profileImageUrl,
  }) async {
    saveCount++;
    this.token = token ?? this.token;
    this.username = username ?? this.username;
    this.email = email ?? this.email;
    this.fullName = fullName ?? this.fullName;
    this.profileImageUrl = profileImageUrl ?? this.profileImageUrl;
  }

  @override
  Future<void> clearSession() async {
    token = null;
    username = null;
    email = null;
    fullName = null;
    profileImageUrl = null;
  }

  @override
  Future<void> logout() => clearSession();
}

class _FakeUserRepo implements UserRepo {
  _FakeUserRepo(this.detailsResult);

  final Either<Failure, UserModelDetails> detailsResult;

  @override
  Future<Either<Failure, UserModelDetails>> getDetails() async =>
      detailsResult;

  @override
  Future<Either<Failure, SuccessMessageModel>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, SuccessMessageModel>> deleteProfile() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, SuccessMessageModel>> editProfile({
    required String fullName,
    String? phoneNumber,
    String? country,
    String? birthDate,
    String? gender,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, SuccessMessageModel>> uploadPhoto({
    required String filePath,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  test('saves tokens, fetches profile, and returns hydrated display data',
      () async {
    final session = _RecordingAuthSessionService();
    final repo = _FakeUserRepo(
      const Right(
        UserModelDetails(
          id: '1',
          firstName: 'Rah',
          lastName: 'Hala',
          fullName: 'Rah Hala',
          email: 'profile@rahhala.com',
          profileImageUrl: 'https://example.com/avatar.jpg',
        ),
      ),
    );
    final useCase = PostLoginSessionUseCase(
      authSessionService: session,
      userRepo: repo,
    );

    final result = await useCase(
      login: const Login(token: 'token-123', username: 'Fallback'),
      email: ' USER@RAHHALA.COM ',
    );

    expect(session.token, 'token-123');
    expect(session.email, 'profile@rahhala.com');
    expect(session.fullName, 'Rah Hala');
    expect(session.profileImageUrl, 'https://example.com/avatar.jpg');
    expect(result.displayName, 'Rah Hala');
  });

  test('patches display name from email when profile has no name', () async {
    final session = _RecordingAuthSessionService();
    final repo = _FakeUserRepo(
      Left(ServerFailure(message: 'profile unavailable')),
    );
    final useCase = PostLoginSessionUseCase(
      authSessionService: session,
      userRepo: repo,
    );

    final result = await useCase(
      login: const Login(token: 'token-123'),
      email: 'traveler@rahhala.com',
    );

    expect(session.email, 'traveler@rahhala.com');
    expect(session.fullName, 'Traveler');
    expect(result.displayName, 'Traveler');
  });
}
