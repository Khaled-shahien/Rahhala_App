import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:rahhala_app/core/network/api_consumer.dart';
import 'package:rahhala_app/core/network/end_points.dart';
import 'package:rahhala_app/core/errors/exceptions.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/core/logging/app_logger.dart';
import 'package:rahhala_app/features/profile/data/models/user_model_details.dart';
import 'package:rahhala_app/features/auth/data/models/success_message_model.dart';
import 'package:rahhala_app/features/profile/data/repositories/user_repository.dart';

class UserRepoImpl implements UserRepo {
  final ApiConsumer api;
  UserRepoImpl({required this.api});

  Map<String, dynamic> _ensureMap(dynamic res) {
    if (res is Map<String, dynamic>) return res;
    if (res is String && res.isNotEmpty) {
      try {
        final d = jsonDecode(res);
        if (d is Map<String, dynamic>) return d;
      } catch (e) {
        AppLogger.instance.w(
          'UserRepo: Failed to decode response string as JSON',
          error: e,
        );
      }
    }
    return {};
  }

  Map<String, dynamic> _payload(Map<String, dynamic> m) {
    dynamic cur = m;

    for (int i = 0; i < 3; i++) {
      if (cur is! Map<String, dynamic>) break;

      if (cur['data'] is Map<String, dynamic>) {
        cur = cur['data'];
        continue;
      }
      if (cur['result'] is Map<String, dynamic>) {
        cur = cur['result'];
        continue;
      }
      if (cur['value'] is Map<String, dynamic>) {
        cur = cur['value'];
        continue;
      }
      if (cur['payload'] is Map<String, dynamic>) {
        cur = cur['payload'];
        continue;
      }
      break;
    }

    if (cur is Map<String, dynamic>) {
      if (cur['user'] is Map<String, dynamic>) {
        cur = cur['user'];
      } else if (cur['User'] is Map<String, dynamic>) {
        cur = cur['User'];
      }
    }

    return (cur is Map<String, dynamic>) ? cur : m;
  }

  @override
  Future<Either<Failure, UserModelDetails>> getDetails() async {
    try {
      final res = await api.get(EndPoints.userDetails);
      final map = _ensureMap(res);
      final pl = _payload(map);
      return Right(UserModelDetails.fromJson(pl));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.errorModel.message));
    }
  }

  @override
  Future<Either<Failure, SuccessMessageModel>> editProfile({
    required String fullName,
    String? phoneNumber,
    String? country,
    String? birthDate, // Changed to match backend
    String? gender, // Will be converted to 'Gender'
  }) async {
    try {
      // Ensure date is in proper ISO format
      String? formattedDate;
      if (birthDate != null && birthDate.isNotEmpty) {
        try {
          // Parse and reformat date to ensure ISO format
          final date = DateTime.parse(birthDate);
          formattedDate = date.toIso8601String().split('T')[0];
        } catch (e) {
          // If parsing fails, send as is
          formattedDate = birthDate;
        }
      }

      final res = await api.put(
        EndPoints.editProfile,
        data: {
          'fullName': fullName,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
          if (country != null) 'country': country,
          if (formattedDate != null)
            'Birthofdate': formattedDate, // Fixed typo to match backend
          if (gender != null) 'Gender': gender, // Capital G to match backend
        },
      );
      return Right(SuccessMessageModel.fromJson(_ensureMap(res)));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.errorModel.message));
    }
  }

  @override
  Future<Either<Failure, SuccessMessageModel>> deleteProfile() async {
    try {
      final res = await api.delete(EndPoints.deleteProfile);
      return Right(SuccessMessageModel.fromJson(_ensureMap(res)));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.errorModel.message));
    }
  }

  @override
  Future<Either<Failure, SuccessMessageModel>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final res = await api.put(
        EndPoints.changePassword,
        data: {
          'OldPassword': oldPassword,
          'NewPassword': newPassword,
          'ConfirmPassword': confirmPassword,
        },
      );
      return Right(SuccessMessageModel.fromJson(_ensureMap(res)));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.errorModel.message));
    }
  }

  @override
  Future<Either<Failure, SuccessMessageModel>> uploadPhoto({
    required String filePath,
  }) async {
    try {
      final fileName = filePath.split('/').last;
      final form = FormData.fromMap({
        'ProfileImage':
            await MultipartFile.fromFile(filePath, filename: fileName),
      });
      final res = await api.put(EndPoints.editPhoto, data: form);
      return Right(SuccessMessageModel.fromJson(_ensureMap(res)));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.errorModel.message));
    }
  }
}
