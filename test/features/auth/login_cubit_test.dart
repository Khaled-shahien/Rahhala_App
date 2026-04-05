import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/features/auth/data/models/login_model.dart';
import 'package:rahhala_app/features/auth/data/repositories/auth_repository.dart';
import 'package:rahhala_app/features/auth/domain/login/login_cubit.dart';
import 'package:rahhala_app/features/auth/domain/login/login_state.dart';

class _MockAuthRepo extends Mock implements AuthRepo {}

void main() {
  late _MockAuthRepo authRepo;
  late LoginCubit cubit;

  setUp(() {
    authRepo = _MockAuthRepo();
    cubit = LoginCubit(authRepo: authRepo);
  });

  tearDown(() async {
    await cubit.close();
  });

  blocTest<LoginCubit, LoginState>(
    'emits [LoginLoading, LoginSuccess] when login succeeds',
    build: () {
      when(
        () => authRepo.loginUser(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Right(Login(token: 'token-123')));
      return cubit;
    },
    act: (cubit) => cubit.loginUser(
      email: 'user@rahhala.com',
      password: 'Secret123!',
    ),
    expect: () => <LoginState>[
      LoginLoading(),
      const LoginSuccess(loginModel: Login(token: 'token-123')),
    ],
  );

  blocTest<LoginCubit, LoginState>(
    'emits [LoginLoading, LoginFailure] when login fails',
    build: () {
      when(
        () => authRepo.loginUser(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => Left(ServerFailure(message: 'Invalid credentials')),
      );
      return cubit;
    },
    act: (cubit) => cubit.loginUser(
      email: 'user@rahhala.com',
      password: 'wrong',
    ),
    expect: () => <LoginState>[
      LoginLoading(),
      const LoginFailure(errorMessage: 'Invalid credentials'),
    ],
  );
}
