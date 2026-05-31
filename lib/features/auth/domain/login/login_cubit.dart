import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/core/crash/app_error_reporter.dart';
import 'package:rahhala_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:rahhala_app/features/auth/domain/login/login_state.dart';
import 'package:rahhala_app/features/auth/domain/usecases/post_login_session_use_case.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepo authRepo;
  final PostLoginSessionUseCase postLoginSessionUseCase;

  LoginCubit({
    required this.authRepo,
    required this.postLoginSessionUseCase,
  }) : super(LoginInitial());

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    emit(LoginLoading());
    final result = await authRepo.loginUser(
      email: email,
      password: password,
    );
    await result.fold(
      (failure) async {
        emit(LoginFailure(errorMessage: failure.message));
      },
      (loginModel) async {
        try {
          final session = await postLoginSessionUseCase(
            login: loginModel,
            email: email,
          );
          emit(LoginSuccess(loginModel: loginModel, session: session));
        } catch (e, stackTrace) {
          AppErrorReporter.record(
            'LoginCubit: failed to persist post-login session',
            error: e,
            stackTrace: stackTrace,
          );
          emit(const LoginFailure(
            errorMessage:
                'Login succeeded, but the session could not be saved.',
          ));
        }
      },
    );
  }
}
