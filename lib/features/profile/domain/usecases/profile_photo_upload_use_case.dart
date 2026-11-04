import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:rahhala_app/core/auth/auth_session_service.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/features/auth/domain/entities/success_message.dart';
import 'package:rahhala_app/features/profile/domain/repositories/user_repository.dart';

class ProfilePhotoUploadResult extends Equatable {
  const ProfilePhotoUploadResult({
    required this.message,
    this.profileImageUrl,
  });

  final SuccessMessageModel message;
  final String? profileImageUrl;

  @override
  List<Object?> get props => [message, profileImageUrl];
}

class ProfilePhotoUploadUseCase {
  ProfilePhotoUploadUseCase({
    required UserRepo repo,
    required AuthSessionService authSessionService,
  })  : _repo = repo,
        _authSessionService = authSessionService;

  final UserRepo _repo;
  final AuthSessionService _authSessionService;

  Future<Either<Failure, ProfilePhotoUploadResult>> call(File photo) async {
    final uploadResult = await _repo.uploadPhoto(filePath: photo.path);

    return uploadResult.fold(
      Left.new,
      (message) async {
        String? profileImageUrl;
        final detailsResult = await _repo.getDetails();

        detailsResult.fold(
          (_) {},
          (details) {
            final trimmedUrl = details.profileImageUrl?.trim();
            if (trimmedUrl != null && trimmedUrl.isNotEmpty) {
              profileImageUrl = trimmedUrl;
            }
          },
        );

        if (profileImageUrl != null) {
          await _authSessionService.saveSession(
            profileImageUrl: profileImageUrl,
          );
        }

        return Right(
          ProfilePhotoUploadResult(
            message: message,
            profileImageUrl: profileImageUrl,
          ),
        );
      },
    );
  }
}
