import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/features/auth/data/models/login_model.dart';
import 'package:rahhala_app/features/auth/data/repositories/auth_repository.dart';
import 'package:rahhala_app/features/auth/domain/login/login_cubit.dart';
import 'package:rahhala_app/features/auth/domain/login/login_state.dart';
import 'package:rahhala_app/features/auth/domain/usecases/post_login_session_use_case.dart';

class _MockAuthRepo extends Mock implements AuthRepo {}

class _MockPostLoginSessionUseCase extends Mock
    implements PostLoginSessionUseCase {}

void main() {
  late _MockAuthRepo authRepo;
  late _MockPostLoginSessionUseCase postLoginSessionUseCase;
  late LoginCubit cubit;

  setUpAll(() {
    registerFallbackValue(const Login());
  });

  setUp(() {
    authRepo = _MockAuthRepo();
    postLoginSessionUseCase = _MockPostLoginSessionUseCase();
    cubit = LoginCubit(
      authRepo: authRepo,
      postLoginSessionUseCase: postLoginSessionUseCase,
    );
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
      when(
        () => postLoginSessionUseCase(
          login: any(named: 'login'),
          email: any(named: 'email'),
        ),
      ).thenAnswer(
        (_) async => const PostLoginSessionResult(
          email: 'user@rahhala.com',
          displayName: 'User',
        ),
      );
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
