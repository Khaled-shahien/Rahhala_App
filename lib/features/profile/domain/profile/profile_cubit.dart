import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/core/auth/auth_session_service.dart';
import 'package:rahhala_app/core/errors/exceptions.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/features/profile/domain/repositories/user_repository.dart';
import 'package:rahhala_app/features/profile/domain/profile/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required this.repo,
    required AuthSessionService authSessionService,
  })  : _authSessionService = authSessionService,
        super(ProfileInitial());

  final UserRepo repo;
  final AuthSessionService _authSessionService;

  Future<void> fetch() async {
    if (!_authSessionService.hasToken) {
      emit(const ProfileGuest());
      return;
    }
    emit(ProfileLoading());
    final res = await _guard(repo.getDetails);
    if (isClosed) return;
    await res.fold(
      (failure) async => emit(ProfileFailure(failure.message)),
      (details) async {
        await _authSessionService.saveSession(
          fullName: details.fullName.trim(),
          email: details.email.trim().toLowerCase(),
          profileImageUrl: details.profileImageUrl,
        );
        if (!isClosed) emit(ProfileLoaded(details));
      },
    );
  }

  Future<void> deleteAccount() async {
    emit(ProfileActionLoading());
    final res = await _guard(repo.deleteProfile);
    if (isClosed) return;
    res.fold(
      (failure) => emit(ProfileFailure(failure.message)),
      (success) => emit(ProfileAccountDeleted(success)),
    );
  }

  Future<void> uploadPhoto(String filePath) async {
    emit(ProfileActionLoading());
    final res = await _guard(() => repo.uploadPhoto(filePath: filePath));
    if (isClosed) return;
    await res.fold(
      (failure) async => emit(ProfileFailure(failure.message)),
      (success) async {
        final detailsRes = await _guard(repo.getDetails);
        if (isClosed) return;
        await detailsRes.fold(
          (_) async => emit(ProfileActionSuccess(success)),
          (details) async {
            final imageUrl = details.profileImageUrl;
            await _authSessionService.saveSession(
              fullName: details.fullName.trim(),
              profileImageUrl:
                  (imageUrl != null && imageUrl.isNotEmpty) ? imageUrl : null,
            );
            if (isClosed) return;
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
    final res = await _guard(
      () => repo.editProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        country: country,
        birthDate: birthDate,
        gender: gender,
      ),
    );
    if (isClosed) return;
    await res.fold(
      (failure) async => emit(ProfileFailure(failure.message)),
      (success) async {
        await _authSessionService.saveSession(fullName: fullName);
        if (isClosed) return;
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
    final res = await _guard(
      () => repo.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      ),
    );
    if (isClosed) return;
    res.fold(
      (failure) => emit(ProfileFailure(failure.message)),
      (success) => emit(ProfileActionSuccess(success)),
    );
  }

  /// Turns unexpected exceptions (parsing, platform) into failures so the UI
  /// never stays stuck in a loading state.
  Future<Either<Failure, T>> _guard<T>(
    Future<Either<Failure, T>> Function() call,
  ) async {
    try {
      return await call();
    } catch (e) {
      return Left(failureFromError(e));
    }
  }
}
