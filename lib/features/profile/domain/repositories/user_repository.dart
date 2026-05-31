import 'package:dartz/dartz.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/features/auth/domain/entities/success_message.dart';
import 'package:rahhala_app/features/profile/domain/entities/user_details.dart';

abstract class UserRepo {
  Future<Either<Failure, UserModelDetails>> getDetails();

  Future<Either<Failure, SuccessMessageModel>> editProfile({
    required String fullName,
    String? phoneNumber,
    String? country,
    String? birthDate,
    String? gender,
  });

  Future<Either<Failure, SuccessMessageModel>> deleteProfile();

  Future<Either<Failure, SuccessMessageModel>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  });

  Future<Either<Failure, SuccessMessageModel>> uploadPhoto({
    required String filePath,
  });
}
