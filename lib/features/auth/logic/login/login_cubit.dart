import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/features/auth/data/repositories/auth_repository.dart';
import 'package:rahhala_app/features/auth/logic/login/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepo authRepo;

  LoginCubit({required this.authRepo}) : super(LoginInitial());

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    emit(LoginLoading());
    final result = await authRepo.loginUser(
      email: email,
      password: password,
    );
    result.fold(
      (failure) {
        emit(LoginFailure(errorMessage: failure.message));
      },
      (loginModel) {
        emit(LoginSuccess(loginModel: loginModel));
      },
    );
  }
}
