import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/features/auth/data/repositories/auth_repository.dart';
import 'package:rahhala_app/features/auth/domain/forgot_password/forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final AuthRepo authRepo;

  ForgotPasswordCubit({required this.authRepo})
      : super(ForgotPasswordInitial());

  Future<void> forgotPassword({required String email}) async {
    emit(ForgotPasswordLoading());
    final result = await authRepo.forgotPassword(email: email);
    result.fold(
      (failure) => emit(ForgotPasswordFailure(errorMessage: failure.message)),
      (model) => emit(ForgotPasswordSuccess(model: model)),
    );
  }
}
