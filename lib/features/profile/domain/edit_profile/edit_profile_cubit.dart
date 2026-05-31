import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/core/auth/auth_session_service.dart';
import 'package:rahhala_app/core/crash/app_error_reporter.dart';
import 'package:rahhala_app/core/services/image_picker_service.dart';
import 'package:rahhala_app/features/profile/domain/entities/user_details.dart';
import 'package:rahhala_app/features/profile/domain/repositories/user_repository.dart';
import 'package:rahhala_app/features/profile/domain/usecases/profile_photo_upload_use_case.dart';

import 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit({
    required UserRepo repo,
    required ProfilePhotoUploadUseCase profilePhotoUploadUseCase,
    required ImagePickerService imagePickerService,
    required AuthSessionService authSessionService,
  })  : _repo = repo,
        _profilePhotoUploadUseCase = profilePhotoUploadUseCase,
        _imagePickerService = imagePickerService,
        _authSessionService = authSessionService,
        super(const EditProfileInitial());

  final UserRepo _repo;
  final ProfilePhotoUploadUseCase _profilePhotoUploadUseCase;
  final ImagePickerService _imagePickerService;
  final AuthSessionService _authSessionService;

  EditProfileFormData? _formData;

  Future<void> loadInitialProfile() async {
    _formData = _sessionFormData();
    emit(EditProfileLoading(formData: _formData));

    try {
      final res = await _repo.getDetails();
      res.fold(
        (_) => emit(EditProfileInitial(formData: _formData)),
        (details) {
          _formData = _detailsFormData(details);
          emit(EditProfileInitial(formData: _formData));
        },
      );
    } catch (e, stackTrace) {
      AppErrorReporter.record(
        'EditProfileCubit: failed to load profile details',
        error: e,
        stackTrace: stackTrace,
      );
      emit(EditProfileError(
        'Could not load profile details. Please try again.',
        formData: _formData,
      ));
    }
  }

  Future<void> pickAndUploadPhoto(AppImageSource source) async {
    try {
      final photo = await _imagePickerService.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (photo == null) return;

      emit(EditProfilePhotoSelected(photo: photo, formData: _formData));
      emit(EditProfileUploading(photo: photo, formData: _formData));

      final res = await _profilePhotoUploadUseCase(photo);
      res.fold(
        (failure) => emit(EditProfileError(
          failure.message,
          formData: _formData,
        )),
        (result) {
          if (result.profileImageUrl != null) {
            _formData = (_formData ?? const EditProfileFormData()).copyWith(
              profileImageUrl: result.profileImageUrl,
            );
          }
          emit(EditProfileSuccess(
            result.message,
            formData: _formData,
          ));
        },
      );
    } catch (e, stackTrace) {
      AppErrorReporter.record(
        'EditProfileCubit: failed to pick or upload profile photo',
        error: e,
        stackTrace: stackTrace,
      );
      emit(EditProfileError(
        'Failed to upload photo. Please try again.',
        formData: _formData,
      ));
    }
  }

  Future<void> save({
    required String fullName,
    String? phoneNumber,
    String? country,
    required String dob,
    required String gender,
  }) async {
    _formData = (_formData ?? const EditProfileFormData()).copyWith(
      fullName: fullName,
      phoneNumber: phoneNumber ?? '',
      country: country ?? '',
      birthDate: dob,
      gender: gender,
    );
    emit(EditProfileLoading(formData: _formData));

    try {
      final res = await _repo.editProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        country: country,
        birthDate: dob,
        gender: gender,
      );

      await res.fold(
        (failure) async => emit(EditProfileError(
          failure.message,
          formData: _formData,
        )),
        (ok) async {
          await _authSessionService.saveSession(fullName: fullName);
          emit(EditProfileSuccess(
            ok,
            formData: _formData,
            shouldClose: true,
          ));
        },
      );
    } catch (e, stackTrace) {
      AppErrorReporter.record(
        'EditProfileCubit: failed to save profile',
        error: e,
        stackTrace: stackTrace,
      );
      emit(EditProfileError(
        'Could not save profile. Please try again.',
        formData: _formData,
      ));
    }
  }

  EditProfileFormData _sessionFormData() {
    return EditProfileFormData(
      fullName: _authSessionService.fullName?.trim() ?? '',
      email: _authSessionService.email?.trim() ?? '',
      profileImageUrl: _authSessionService.profileImageUrl?.trim(),
      birthDate: _defaultBirthDate(),
    );
  }

  EditProfileFormData _detailsFormData(UserModelDetails details) {
    return EditProfileFormData(
      fullName: _firstNonEmpty(details.fullName, _formData?.fullName),
      email: _firstNonEmpty(details.email, _formData?.email),
      phoneNumber: details.phoneNumber?.trim() ?? '',
      country: details.countryName?.trim() ?? '',
      birthDate: _formatDate(details.birthDate) ?? _defaultBirthDate(),
      gender: details.gender?.trim() ?? '',
      profileImageUrl:
          _firstNonEmpty(details.profileImageUrl, _formData?.profileImageUrl),
    );
  }

  String _firstNonEmpty(String? primary, String? fallback) {
    final trimmedPrimary = primary?.trim();
    if (trimmedPrimary != null && trimmedPrimary.isNotEmpty) {
      return trimmedPrimary;
    }
    return fallback?.trim() ?? '';
  }

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _defaultBirthDate() {
    final date = DateTime.now().subtract(const Duration(days: 6570));
    return _formatDate(date)!;
  }
}
