import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:rahhala_app/core/errors/error_model.dart';

class ServerException implements Exception {
  final ErrorModel errorModel;
  ServerException({required this.errorModel});
}

Never handleDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.badCertificate:
    case DioExceptionType.cancel:
    case DioExceptionType.connectionError:
    case DioExceptionType.unknown:
      throw ServerException(
        errorModel: ErrorModel(
          message: "Connection error. Please check your internet connection.",
        ),
      );

    case DioExceptionType.badResponse:
      final statusCode = e.response?.statusCode ?? 0;
      final data = e.response?.data;

      Map<String, dynamic> map = {};
      if (data is Map<String, dynamic>) {
        map = data;
      } else if (data is String && data.trim().isNotEmpty) {
        try {
          final d = jsonDecode(data);
          if (d is Map<String, dynamic>) map = d;
        } catch (_) {}
      }

      if (map.isEmpty) {
        throw ServerException(
          errorModel: ErrorModel(
            message: _mapStatusCodeToMessage(statusCode),
            statusCode: statusCode,
          ),
        );
      }

      throw ServerException(
        errorModel: ErrorModel.fromJson(map, statusCode: statusCode),
      );
  }
}

String _mapStatusCodeToMessage(int statusCode) {
  switch (statusCode) {
    case 401:
      return "Unauthorized. Please log in again.";
    case 403:
      return "Access forbidden.";
    case 404:
      return "Resource not found.";
    case 422:
      return "Validation failed. Please check your data.";
    case 500:
      return "Internal server error. Please try again later.";
    default:
      return "Unexpected error (code: $statusCode)";
  }
}
