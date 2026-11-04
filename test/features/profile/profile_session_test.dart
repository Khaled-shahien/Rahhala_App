import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rahhala_app/core/auth/auth_session_service.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/features/auth/domain/entities/success_message.dart';
import 'package:rahhala_app/features/profile/data/repositories/user_repository.dart';
import 'package:rahhala_app/features/profile/domain/profile/profile_cubit.dart';
import 'package:rahhala_app/features/profile/domain/profile/profile_state.dart';

class _MockUserRepo extends Mock implements UserRepo {}

class _MockAuthSessionService extends Mock implements AuthSessionService {}

void main() {
  late _MockUserRepo repo;
  late _MockAuthSessionService session;

  setUp(() {
    repo = _MockUserRepo();
    session = _MockAuthSessionService();
    when(() => session.hasToken).thenReturn(true);
  });

  ProfileCubit build() => ProfileCubit(repo: repo, authSessionService: session);

  blocTest<ProfileCubit, ProfileState>(
    'guests get ProfileGuest and no request is sent',
    setUp: () => when(() => session.hasToken).thenReturn(false),
    build: build,
    act: (cubit) => cubit.fetch(),
    expect: () => [const ProfileGuest()],
    verify: (_) => verifyNever(() => repo.getDetails()),
  );

  blocTest<ProfileCubit, ProfileState>(
    'a successful delete emits ProfileAccountDeleted, whatever the message',
    build: () {
      when(() => repo.deleteProfile()).thenAnswer(
        (_) async => Right(SuccessMessageModel(message: 'تمت إزالة الحساب')),
      );
      return build();
    },
    act: (cubit) => cubit.deleteAccount(),
    expect: () => [
      isA<ProfileActionLoading>(),
      isA<ProfileAccountDeleted>(),
    ],
  );

  blocTest<ProfileCubit, ProfileState>(
    'a failed delete keeps the user signed in',
    build: () {
      when(() => repo.deleteProfile()).thenAnswer(
        (_) async => const Left(ServerFailure(message: 'Try later')),
      );
      return build();
    },
    act: (cubit) => cubit.deleteAccount(),
    expect: () => [
      isA<ProfileActionLoading>(),
      const ProfileFailure('Try later'),
    ],
  );

  blocTest<ProfileCubit, ProfileState>(
    'an unexpected exception becomes a failure instead of a stuck spinner',
    build: () {
      when(() => repo.changePassword(
            oldPassword: any(named: 'oldPassword'),
            newPassword: any(named: 'newPassword'),
            confirmPassword: any(named: 'confirmPassword'),
          )).thenThrow(TypeError());
      return build();
    },
    act: (cubit) => cubit.changePassword(
      oldPassword: 'a',
      newPassword: 'b',
      confirmPassword: 'b',
    ),
    expect: () => [isA<ProfileActionLoading>(), isA<ProfileFailure>()],
  );
}
