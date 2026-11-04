import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:rahhala_app/features/auth/domain/register/register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final AuthRepo authRepo;

  RegisterCubit({required this.authRepo}) : super(RegisterInitial());

  Future<void> registerUser({
    required String fullName,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    required String phoneNumber,
    required String country,
  }) async {
    emit(RegisterLoading());
    final result = await authRepo.registerUser(
      fullName: fullName,
      username: username,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      phoneNumber: phoneNumber,
      country: country,
    );
    result.fold(
      (failure) => emit(RegisterFailure(errorMessage: failure.message)),
      (model) => emit(RegisterSuccess(model: model)),
    );
  }
}
