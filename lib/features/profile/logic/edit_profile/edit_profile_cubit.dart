import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/features/profile/data/repositories/user_repository.dart';
import 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  final UserRepo repo;
  EditProfileCubit({required this.repo}) : super(EditProfileInitial());

  Future<void> save({
    required String fullName,
    String? phoneNumber,
    String? country,
    required String dob,
    required String gender,
  }) async {
    emit(EditProfileLoading());
    final res = await repo.editProfile(
      fullName: fullName,
      phoneNumber: phoneNumber,
      country: country,
      dateOfBirth: dob, // Added dateOfBirth parameter
      gender: gender, // Added gender parameter
    );
    res.fold(
      (f) => emit(EditProfileFailure(f.message)),
      (ok) => emit(EditProfileSuccess(ok)),
    );
  }
}
