import 'package:dartz/dartz.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/features/auth/data/models/login_model.dart';
import 'package:rahhala_app/features/auth/data/models/success_message_model.dart';

abstract class AuthRepo {
  Future<Either<Failure, Login>> loginUser({
    required String email,
    required String password,
  });

  Future<Either<Failure, SuccessMessageModel>> registerUser({
    required String fullName,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    required String phoneNumber,
    required String country,
  });

  Future<Either<Failure, SuccessMessageModel>> forgotPassword({
    required String email,
  });

  Future<Either<Failure, SuccessMessageModel>> verifyOtp({
    required String email,
    required String otp,
  });

  Future<Either<Failure, SuccessMessageModel>> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String confirmPassword,
  });
}
