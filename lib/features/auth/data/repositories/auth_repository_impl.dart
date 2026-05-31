import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:rahhala_app/core/network/api_consumer.dart';
import 'package:rahhala_app/core/network/end_points.dart';
import 'package:rahhala_app/core/errors/exceptions.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/core/logging/app_logger.dart';
import 'package:rahhala_app/features/auth/data/models/login_model.dart';
import 'package:rahhala_app/features/auth/data/models/success_message_model.dart';
import 'package:rahhala_app/features/auth/data/repositories/auth_repository.dart';

class AuthRepoImpl extends AuthRepo {
  final ApiConsumer apiConsumer;
  AuthRepoImpl({required this.apiConsumer});

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  String _normalizeOtp(String otp) {
    final Map<String, String> map = {
      '٠': '0',
      '١': '1',
      '٢': '2',
      '٣': '3',
      '٤': '4',
      '٥': '5',
      '٦': '6',
      '٧': '7',
      '٨': '8',
      '٩': '9',
      '۰': '0',
      '۱': '1',
      '۲': '2',
      '۳': '3',
      '۴': '4',
      '۵': '5',
      '۶': '6',
      '۷': '7',
      '۸': '8',
      '۹': '9',
    };
    final b = StringBuffer();
    for (final ch in otp.trim().split('')) {
      b.write(map[ch] ?? ch);
    }
    return b.toString().replaceAll(RegExp(r'[^0-9]'), '');
  }

  Map<String, dynamic> _ensureJsonMap(dynamic response) {
    if (response is Map<String, dynamic>) return response;
    if (response is String && response.trim().isNotEmpty) {
      try {
        final d = jsonDecode(response);
        if (d is Map<String, dynamic>) return d;
      } catch (e) {
        AppLogger.instance.w(
          'AuthRepo: Failed to decode response string as JSON',
          error: e,
        );
      }
    }
    return <String, dynamic>{};
  }

  bool? _readSuccess(Map<String, dynamic> map) {
    final v = map['success'];
    if (v == null) return null;
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.toLowerCase().trim();
      return s == 'true' || s == '1' || s == 'ok' || s == 'success';
    }
    return null;
  }

  String _readMessage(Map<String, dynamic> map) {
    final m = map['message'] ??
        map['Message'] ??
        map['msg'] ??
        map['detail'] ??
        map['error'] ??
        map['errors'] ??
        (map['data'] is Map<String, dynamic>
            ? (map['data']['message'] ?? map['data']['detail'])
            : null) ??
        map['status'];
    return (m?.toString().isNotEmpty ?? false)
        ? m.toString()
        : 'Operation completed successfully.';
  }

  bool _looksLikeFailure(Map<String, dynamic> map) {
    final status = map['status']?.toString().toLowerCase().trim();
    if (status == 'error' ||
        status == 'failed' ||
        status == 'failure' ||
        status == 'invalid' ||
        status == 'badrequest' ||
        status == 'bad_request') {
      return true;
    }

    final type = map['type']?.toString().toLowerCase().trim();
    return map['error'] != null ||
        map['errors'] != null ||
        (type?.contains('error') ?? false);
  }

  @override
  Future<Either<Failure, Login>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final res = await apiConsumer.post(
        EndPoints.login,
        data: {ApiKey.email: email, ApiKey.password: password},
      );
      final map = _ensureJsonMap(res);
      final s = _readSuccess(map);
      if (s == false || (s == null && _looksLikeFailure(map))) {
        return Left(ServerFailure(message: _readMessage(map)));
      }
      final loginModel = Login.fromJson(map);
      return Right(loginModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.errorModel.message));
    }
  }

  @override
  Future<Either<Failure, SuccessMessageModel>> registerUser({
    required String fullName,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    required String phoneNumber,
    required String country,
  }) async {
    try {
      final res = await apiConsumer.post(
        EndPoints.register,
        data: {
          'fullName': fullName,
          'username': username,
          'email': email,
          'phoneNumber': phoneNumber,
          'country': country,
          'password': password,
          'confirmPassword': confirmPassword,
        },
      );
      final map = _ensureJsonMap(res);
      final s = _readSuccess(map);
      final msg = _readMessage(map);
      if (s == false || (s == null && _looksLikeFailure(map))) {
        return Left(ServerFailure(message: msg));
      }
      return Right(SuccessMessageModel.fromJson(map));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.errorModel.message));
    }
  }

  @override
  Future<Either<Failure, SuccessMessageModel>> forgotPassword({
    required String email,
  }) async {
    try {
      final res = await apiConsumer.post(
        EndPoints.forgotPassword,
        // TODO: Move email to the request body when the backend accepts it.
        // Query-string reset identifiers can be captured by logs and proxies.
        queryParameters: {ApiKey.email: email},
      );
      final map = _ensureJsonMap(res);
      final s = _readSuccess(map);
      final msg = _readMessage(map);
      if (s == false || (s == null && _looksLikeFailure(map))) {
        return Left(ServerFailure(message: msg));
      }
      return Right(SuccessMessageModel.fromJson(map));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.errorModel.message));
    }
  }

  @override
  Future<Either<Failure, SuccessMessageModel>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final res = await apiConsumer.post(
        EndPoints.verifyOtp,
        // TODO: Move email and OTP to the request body when the backend
        // accepts it. Keeping query parameters preserves current API behavior.
        queryParameters: {
          ApiKey.email: _normalizeEmail(email),
          'otp': _normalizeOtp(otp),
        },
      );
      final map = _ensureJsonMap(res);
      final s = _readSuccess(map);
      final msg = _readMessage(map);
      if (s == false || (s == null && _looksLikeFailure(map))) {
        return Left(ServerFailure(message: msg));
      }
      return Right(SuccessMessageModel.fromJson(map));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.errorModel.message));
    }
  }

  @override
  Future<Either<Failure, SuccessMessageModel>> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final res = await apiConsumer.post(
        EndPoints.resetPassword,
        data: {
          'email': _normalizeEmail(email),
          'otp': _normalizeOtp(otp),
          'newPassword': password,
          'confirmPassword': confirmPassword,
        },
      );
      final map = _ensureJsonMap(res);
      final s = _readSuccess(map);
      final msg = _readMessage(map);
      if (s == false || (s == null && _looksLikeFailure(map))) {
        return Left(ServerFailure(message: msg));
      }
      return Right(SuccessMessageModel.fromJson(map));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.errorModel.message));
    }
  }
}
