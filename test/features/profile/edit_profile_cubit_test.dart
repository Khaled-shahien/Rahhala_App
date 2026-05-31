import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rahhala_app/core/auth/auth_session_service.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/core/services/image_picker_service.dart';
import 'package:rahhala_app/features/auth/domain/entities/success_message.dart';
import 'package:rahhala_app/features/profile/domain/edit_profile/edit_profile_cubit.dart';
import 'package:rahhala_app/features/profile/domain/edit_profile/edit_profile_state.dart';
import 'package:rahhala_app/features/profile/domain/entities/user_details.dart';
import 'package:rahhala_app/features/profile/domain/repositories/user_repository.dart';
import 'package:rahhala_app/features/profile/domain/usecases/profile_photo_upload_use_case.dart';

class _MockUserRepo extends Mock implements UserRepo {}

class _MockImagePickerService extends Mock implements ImagePickerService {}

class _MockProfilePhotoUploadUseCase extends Mock
    implements ProfilePhotoUploadUseCase {}

class _FakeAuthSessionService implements AuthSessionService {
  @override
  String? token;
  @override
  String? username;
  @override
  String? email = 'user@rahhala.com';
  @override
  String? fullName = 'Session User';
  @override
  String? profileImageUrl;

  @override
  bool get hasToken => token != null;

  @override
  String get displayName => fullName ?? 'User';

  @override
  CurrentUserBasicInfo get currentUser => CurrentUserBasicInfo(
        username: username,
        email: email,
        fullName: fullName,
        profileImageUrl: profileImageUrl,
      );

  @override
  Future<void> saveSession({
    String? token,
    String? username,
    String? email,
    String? fullName,
    String? profileImageUrl,
  }) async {
    this.token = token ?? this.token;
    this.username = username ?? this.username;
    this.email = email ?? this.email;
    this.fullName = fullName ?? this.fullName;
    this.profileImageUrl = profileImageUrl ?? this.profileImageUrl;
  }

  @override
  Future<void> clearSession() async {}

  @override
  Future<void> logout() async {}
}

void main() {
  late _MockUserRepo repo;
  late _MockImagePickerService imagePickerService;
  late _MockProfilePhotoUploadUseCase uploadUseCase;
  late _FakeAuthSessionService authSessionService;

  setUpAll(() {
    registerFallbackValue(File('fallback.jpg'));
  });

  setUp(() {
    repo = _MockUserRepo();
    imagePickerService = _MockImagePickerService();
    uploadUseCase = _MockProfilePhotoUploadUseCase();
    authSessionService = _FakeAuthSessionService();
  });

  EditProfileCubit buildCubit() => EditProfileCubit(
        repo: repo,
        profilePhotoUploadUseCase: uploadUseCase,
        imagePickerService: imagePickerService,
        authSessionService: authSessionService,
      );

  blocTest<EditProfileCubit, EditProfileState>(
    'loads details into form data',
    build: () {
      when(() => repo.getDetails()).thenAnswer(
        (_) async => const Right(
          UserModelDetails(
            id: '1',
            firstName: 'Rah',
            lastName: 'Hala',
            fullName: 'Rah Hala',
            email: 'profile@rahhala.com',
            gender: 'female',
          ),
        ),
      );
      return buildCubit();
    },
    act: (cubit) => cubit.loadInitialProfile(),
    expect: () => [
      isA<EditProfileLoading>(),
      isA<EditProfileInitial>().having(
        (state) => state.formData?.fullName,
        'fullName',
        'Rah Hala',
      ),
    ],
  );

  blocTest<EditProfileCubit, EditProfileState>(
    'emits photo selected, uploading, then success',
    build: () {
      when(
        () => imagePickerService.pickImage(
          source: AppImageSource.gallery,
          imageQuality: any(named: 'imageQuality'),
          maxWidth: any(named: 'maxWidth'),
          maxHeight: any(named: 'maxHeight'),
        ),
      ).thenAnswer((_) async => File('avatar.jpg'));
      when(() => uploadUseCase(any())).thenAnswer(
        (_) async => Right(
          ProfilePhotoUploadResult(
            message: SuccessMessageModel(message: 'Uploaded'),
            profileImageUrl: 'https://example.com/avatar.jpg',
          ),
        ),
      );
      return buildCubit();
    },
    act: (cubit) => cubit.pickAndUploadPhoto(AppImageSource.gallery),
    expect: () => [
      isA<EditProfilePhotoSelected>(),
      isA<EditProfileUploading>(),
      isA<EditProfileSuccess>().having(
        (state) => state.formData?.profileImageUrl,
        'profileImageUrl',
        'https://example.com/avatar.jpg',
      ),
    ],
  );

  blocTest<EditProfileCubit, EditProfileState>(
    'emits error when upload use case fails',
    build: () {
      when(
        () => imagePickerService.pickImage(
          source: AppImageSource.camera,
          imageQuality: any(named: 'imageQuality'),
          maxWidth: any(named: 'maxWidth'),
          maxHeight: any(named: 'maxHeight'),
        ),
      ).thenAnswer((_) async => File('avatar.jpg'));
      when(() => uploadUseCase(any())).thenAnswer(
        (_) async => Left(ServerFailure(message: 'Upload failed')),
      );
      return buildCubit();
    },
    act: (cubit) => cubit.pickAndUploadPhoto(AppImageSource.camera),
    expect: () => [
      isA<EditProfilePhotoSelected>(),
      isA<EditProfileUploading>(),
      isA<EditProfileError>().having(
        (state) => state.message,
        'message',
        'Upload failed',
      ),
    ],
  );
}
