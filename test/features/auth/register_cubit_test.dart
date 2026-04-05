import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/features/auth/data/models/success_message_model.dart';
import 'package:rahhala_app/features/auth/data/repositories/auth_repository.dart';
import 'package:rahhala_app/features/auth/domain/register/register_cubit.dart';
import 'package:rahhala_app/features/auth/domain/register/register_state.dart';

class _MockAuthRepo extends Mock implements AuthRepo {}

void main() {
  late _MockAuthRepo authRepo;
  late RegisterCubit cubit;

  setUp(() {
    authRepo = _MockAuthRepo();
    cubit = RegisterCubit(authRepo: authRepo);
  });

  tearDown(() async {
    await cubit.close();
  });

  blocTest<RegisterCubit, RegisterState>(
    'emits [RegisterLoading, RegisterSuccess] when registration succeeds',
    build: () {
      when(
        () => authRepo.registerUser(
          fullName: any(named: 'fullName'),
          username: any(named: 'username'),
          email: any(named: 'email'),
          password: any(named: 'password'),
          confirmPassword: any(named: 'confirmPassword'),
          phoneNumber: any(named: 'phoneNumber'),
          country: any(named: 'country'),
        ),
      ).thenAnswer(
        (_) async => Right(
          SuccessMessageModel(message: 'Registration completed successfully.'),
        ),
      );
      return cubit;
    },
    act: (cubit) => cubit.registerUser(
      fullName: 'Test User',
      username: 'test_user',
      email: 'test@rahhala.com',
      password: 'Secret123!',
      confirmPassword: 'Secret123!',
      phoneNumber: '01000000000',
      country: 'Egypt',
    ),
    expect: () => <dynamic>[
      isA<RegisterLoading>(),
      isA<RegisterSuccess>().having(
        (state) => state.model.message,
        'message',
        'Registration completed successfully.',
      ),
    ],
  );

  blocTest<RegisterCubit, RegisterState>(
    'emits [RegisterLoading, RegisterFailure] when registration fails',
    build: () {
      when(
        () => authRepo.registerUser(
          fullName: any(named: 'fullName'),
          username: any(named: 'username'),
          email: any(named: 'email'),
          password: any(named: 'password'),
          confirmPassword: any(named: 'confirmPassword'),
          phoneNumber: any(named: 'phoneNumber'),
          country: any(named: 'country'),
        ),
      ).thenAnswer(
        (_) async => Left(ServerFailure(message: 'Email already exists')),
      );
      return cubit;
    },
    act: (cubit) => cubit.registerUser(
      fullName: 'Test User',
      username: 'test_user',
      email: 'test@rahhala.com',
      password: 'Secret123!',
      confirmPassword: 'Secret123!',
      phoneNumber: '01000000000',
      country: 'Egypt',
    ),
    expect: () => <dynamic>[
      isA<RegisterLoading>(),
      isA<RegisterFailure>().having(
        (state) => state.errorMessage,
        'errorMessage',
        'Email already exists',
      ),
    ],
  );
}
