import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/utils/token_storage.dart';
import 'package:rahhala_app/features/profile/data/repositories/user_repository.dart';
import 'package:rahhala_app/features/profile/logic/profile/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final UserRepo repo;
  ProfileCubit({required this.repo}) : super(ProfileInitial());

  Future<void> fetch() async {
    emit(ProfileLoading());
    final res = await repo.getDetails();
    res.fold(
      (failure) => emit(ProfileFailure(failure.message)),
      (details) {
        
        if (details.fullName.trim().isNotEmpty) {
          sl<TokenStorage>().setFullName(details.fullName.trim());
        }
        if (details.email.trim().isNotEmpty) {
          sl<TokenStorage>().setEmail(details.email.trim().toLowerCase());
        }
        if (details.profileImageUrl != null &&
            details.profileImageUrl!.isNotEmpty) {
          sl<TokenStorage>().setProfileImageUrl(details.profileImageUrl!);
          print('✅ Profile image saved: ${details.profileImageUrl}');
        }
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
    res.fold(
      (failure) {
        emit(ProfileFailure(failure.message));
      },
      (success) async {
        print('📸 Upload success! Fetching new details...');

        final detailsRes = await repo.getDetails();
        detailsRes.fold(
          (failure) {
            
            emit(ProfileActionSuccess(success));
          },
          (details) {
            
            if (details.profileImageUrl != null &&
                details.profileImageUrl!.isNotEmpty) {
              sl<TokenStorage>().setProfileImageUrl(details.profileImageUrl!);
              print('✅ New image URL saved: ${details.profileImageUrl}');
            }

            if (details.fullName.trim().isNotEmpty) {
              sl<TokenStorage>().setFullName(details.fullName.trim());
            }

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
  }) async {
    emit(ProfileActionLoading());
    final res = await repo.editProfile(
      fullName: fullName,
      phoneNumber: phoneNumber,
      country: country,
    );
    res.fold(
      (failure) => emit(ProfileFailure(failure.message)),
      (success) async {
        
        await sl<TokenStorage>().setFullName(fullName);
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
