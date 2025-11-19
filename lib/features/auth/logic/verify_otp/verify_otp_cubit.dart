import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/features/auth/data/repositories/auth_repository.dart';
import 'package:rahhala_app/features/auth/logic/verify_otp/verify_otp_state.dart';

class VerifyOtpCubit extends Cubit<VerifyOtpState> {
  final AuthRepo authRepo;

  VerifyOtpCubit({required this.authRepo}) : super(VerifyOtpInitial());

  Future<void> verifyOtp({
    required String email,
    required String otp,
  }) async {
    emit(VerifyOtpLoading());
    final result = await authRepo.verifyOtp(email: email, otp: otp);
    result.fold(
      (failure) => emit(VerifyOtpFailure(errorMessage: failure.message)),
      (model) => emit(VerifyOtpSuccess(model: model)),
    );
  }
}
