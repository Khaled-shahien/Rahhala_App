import 'package:dartz/dartz.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/features/profile/data/models/user_model_details.dart';
import 'package:rahhala_app/features/auth/data/models/success_message_model.dart';

abstract class UserRepo {
  Future<Either<Failure, UserModelDetails>> getDetails();

  Future<Either<Failure, SuccessMessageModel>> editProfile({
    required String fullName,
    String? phoneNumber,
    String? country,
    String? dateOfBirth, // Added dateOfBirth parameter
    String? gender, // Added gender parameter
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
