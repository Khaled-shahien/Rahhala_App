import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rahhala_app/core/auth/auth_session_service.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/core/utils/token_storage.dart';
import 'package:rahhala_app/core/utils/user_session.dart';
import 'package:rahhala_app/features/profile/data/models/user_model_details.dart';
import 'package:rahhala_app/features/profile/data/repositories/user_repository.dart';
import 'package:rahhala_app/features/profile/domain/profile/profile_cubit.dart';
import 'package:rahhala_app/features/profile/domain/profile/profile_state.dart';

class _MockUserRepo extends Mock implements UserRepo {}

class _MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late _MockUserRepo userRepo;
  late _MockTokenStorage tokenStorage;

  setUp(() async {
    userRepo = _MockUserRepo();
    tokenStorage = _MockTokenStorage();

    await sl.reset();
    sl.registerSingleton<TokenStorage>(tokenStorage);
    sl.registerLazySingleton<UserSession>(() => UserSession());
    sl.registerLazySingleton<AuthSessionService>(
      () => AuthSessionService(
        tokenStorage: sl<TokenStorage>(),
        userSession: sl<UserSession>(),
      ),
    );

    when(() => tokenStorage.setFullName(any())).thenAnswer((_) async {});
    when(() => tokenStorage.setEmail(any())).thenAnswer((_) async {});
    when(() => tokenStorage.setProfileImageUrl(any())).thenAnswer((_) async {});
  });

  tearDown(() async {
    await sl.reset();
  });

  blocTest<ProfileCubit, ProfileState>(
    'emits [ProfileLoading, ProfileLoaded] and caches profile fields on success',
    build: () {
      when(() => userRepo.getDetails()).thenAnswer(
        (_) async => const Right(
          UserModelDetails(
            id: '1',
            firstName: 'Rahhala',
            lastName: 'User',
            fullName: 'Rahhala User',
            email: 'user@rahhala.com',
            profileImageUrl: 'https://example.com/avatar.jpg',
          ),
        ),
      );
      return ProfileCubit(repo: userRepo);
    },
    act: (cubit) => cubit.fetch(),
    expect: () => <ProfileState>[
      ProfileLoading(),
      const ProfileLoaded(
        UserModelDetails(
          id: '1',
          firstName: 'Rahhala',
          lastName: 'User',
          fullName: 'Rahhala User',
          email: 'user@rahhala.com',
          profileImageUrl: 'https://example.com/avatar.jpg',
        ),
      ),
    ],
    verify: (_) {
      verify(() => tokenStorage.setFullName('Rahhala User')).called(1);
      verify(() => tokenStorage.setEmail('user@rahhala.com')).called(1);
      verify(
        () => tokenStorage.setProfileImageUrl('https://example.com/avatar.jpg'),
      ).called(1);
    },
  );

  blocTest<ProfileCubit, ProfileState>(
    'emits [ProfileLoading, ProfileFailure] when repository fails',
    build: () {
      when(() => userRepo.getDetails()).thenAnswer(
        (_) async => Left(ServerFailure(message: 'Unable to load profile')),
      );
      return ProfileCubit(repo: userRepo);
    },
    act: (cubit) => cubit.fetch(),
    expect: () => <ProfileState>[
      ProfileLoading(),
      const ProfileFailure('Unable to load profile'),
    ],
  );
}
