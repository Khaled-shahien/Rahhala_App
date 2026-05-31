import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:rahhala_app/features/auth/domain/reset_password/reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final AuthRepo authRepo;

  ResetPasswordCubit({required this.authRepo}) : super(ResetPasswordInitial());

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String confirmPassword,
  }) async {
    emit(ResetPasswordLoading());
    final result = await authRepo.resetPassword(
      email: email,
      otp: otp,
      password: password,
      confirmPassword: confirmPassword,
    );
    result.fold(
      (failure) => emit(ResetPasswordFailure(errorMessage: failure.message)),
      (model) => emit(ResetPasswordSuccess(model: model)),
    );
  }
}
