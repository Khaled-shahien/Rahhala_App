import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/core/auth/auth_session_service.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/features/profile/domain/repositories/user_repository.dart';
import 'package:rahhala_app/features/profile/domain/profile/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final UserRepo repo;
  ProfileCubit({required this.repo}) : super(ProfileInitial());

  Future<void> fetch() async {
    emit(ProfileLoading());
    final res = await repo.getDetails();
    await res.fold(
      (failure) async => emit(ProfileFailure(failure.message)),
      (details) async {
        await sl<AuthSessionService>().saveSession(
          fullName: details.fullName.trim(),
          email: details.email.trim().toLowerCase(),
          profileImageUrl: details.profileImageUrl,
        );
        emit(ProfileLoaded(details));
      },
    );
  }

  Future<void> deleteAccount() async {
    emit(ProfileActionLoading());
    final res = await repo.deleteProfile();
    res.fold(
      (failure) => emit(ProfileFailure(failure.message)),
      (success) => emit(ProfileActionSuccess(success)),
    );
  }

  Future<void> uploadPhoto(String filePath) async {
    emit(ProfileActionLoading());
    final res = await repo.uploadPhoto(filePath: filePath);
    await res.fold(
      (failure) async {
        emit(ProfileFailure(failure.message));
      },
      (success) async {
        final detailsRes = await repo.getDetails();
        await detailsRes.fold(
          (failure) async {
            emit(ProfileActionSuccess(success));
          },
          (details) async {
            if (details.profileImageUrl != null &&
                details.profileImageUrl!.isNotEmpty) {
              await sl<AuthSessionService>().saveSession(
                profileImageUrl: details.profileImageUrl!,
              );
            }
            await sl<AuthSessionService>().saveSession(
              fullName: details.fullName.trim(),
            );

            emit(ProfileActionSuccess(success));
            emit(ProfileLoaded(details));
          },
        );
      },
    );
  }

  Future<void> editProfile({
    required String fullName,
    String? phoneNumber,
    String? country,
    String? birthDate,
    String? gender,
  }) async {
    emit(ProfileActionLoading());
    final res = await repo.editProfile(
      fullName: fullName,
      phoneNumber: phoneNumber,
      country: country,
      birthDate: birthDate,
      gender: gender,
    );
    await res.fold(
      (failure) async => emit(ProfileFailure(failure.message)),
      (success) async {
        await sl<AuthSessionService>().saveSession(fullName: fullName);
        emit(ProfileActionSuccess(success));
        await fetch();
      },
    );
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    emit(ProfileActionLoading());
    final res = await repo.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    res.fold(
      (failure) => emit(ProfileFailure(failure.message)),
      (success) => emit(ProfileActionSuccess(success)),
    );
  }
}
