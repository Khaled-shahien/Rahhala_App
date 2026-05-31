import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:rahhala_app/features/auth/domain/entities/success_message.dart';

class EditProfileFormData extends Equatable {
  const EditProfileFormData({
    this.fullName = '',
    this.email = '',
    this.phoneNumber = '',
    this.country = '',
    this.birthDate = '',
    this.gender = '',
    this.profileImageUrl,
  });

  final String fullName;
  final String email;
  final String phoneNumber;
  final String country;
  final String birthDate;
  final String gender;
  final String? profileImageUrl;

  EditProfileFormData copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? country,
    String? birthDate,
    String? gender,
    String? profileImageUrl,
  }) {
    return EditProfileFormData(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      country: country ?? this.country,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  @override
  List<Object?> get props => [
        fullName,
        email,
        phoneNumber,
        country,
        birthDate,
        gender,
        profileImageUrl,
      ];
}

abstract class EditProfileState extends Equatable {
  const EditProfileState();

  EditProfileFormData? get formData => null;

  @override
  List<Object?> get props => [];
}

class EditProfileInitial extends EditProfileState {
  const EditProfileInitial({this.formData});

  @override
  final EditProfileFormData? formData;

  @override
  List<Object?> get props => [formData];
}

class EditProfileLoading extends EditProfileState {
  const EditProfileLoading({this.formData});

  @override
  final EditProfileFormData? formData;

  @override
  List<Object?> get props => [formData];
}

class EditProfilePhotoSelected extends EditProfileState {
  const EditProfilePhotoSelected({
    required this.photo,
    this.formData,
  });

  final File photo;

  @override
  final EditProfileFormData? formData;

  @override
  List<Object?> get props => [photo.path, formData];
}

class EditProfileUploading extends EditProfileState {
  const EditProfileUploading({
    required this.photo,
    this.formData,
  });

  final File photo;

  @override
  final EditProfileFormData? formData;

  @override
  List<Object?> get props => [photo.path, formData];
}

class EditProfileSuccess extends EditProfileState {
  const EditProfileSuccess(
    this.model, {
    this.formData,
    this.shouldClose = false,
  });

  final SuccessMessageModel model;
  final bool shouldClose;

  @override
  final EditProfileFormData? formData;

  @override
  List<Object?> get props => [model, formData, shouldClose];
}

class EditProfileError extends EditProfileState {
  const EditProfileError(
    this.message, {
    this.formData,
  });

  final String message;

  @override
  final EditProfileFormData? formData;

  @override
  List<Object?> get props => [message, formData];
}

class EditProfileFailure extends EditProfileError {
  const EditProfileFailure(
    super.message, {
    super.formData,
  });
}
