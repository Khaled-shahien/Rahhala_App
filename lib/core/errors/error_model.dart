import 'package:rahhala_app/core/network/end_points.dart';

class ErrorModel {
  final String message;
  final int? statusCode;

  ErrorModel({required this.message, this.statusCode});

  factory ErrorModel.fromJson(
    Map<String, dynamic> json, {
    int? statusCode,
  }) {
    // Handle ASP.NET Core validation errors
    if (json['errors'] != null && json['errors'] is Map<String, dynamic>) {
      final errors = json['errors'] as Map<String, dynamic>;
      String msg = 'Validation error';

      // Extract the first error message from the errors map
      if (errors.isNotEmpty) {
        final firstKey = errors.keys.first;
        final firstValue = errors[firstKey];

        if (firstValue is List && firstValue.isNotEmpty) {
          msg = firstValue.first.toString();
        } else if (firstValue != null) {
          msg = firstValue.toString();
        } else {
          msg = json['title']?.toString() ?? 'Validation error';
        }
      }

      int? code = statusCode;
      final s = json['status'];
      if (code == null && s is int) {
        code = s;
      }

      return ErrorModel(
        message: msg,
        statusCode: code,
      );
    }

    // Fallback for normal error responses
    final String? m = json[ApiKey.message] ??
        json[ApiKey.Message] ??
        json[ApiKey.error] ??
        json['error_description'] ??
        json[ApiKey.detail] ??
        json['title'] ??
        (json[ApiKey.data] is Map<String, dynamic>
            ? (json[ApiKey.data][ApiKey.message] ??
                json[ApiKey.data][ApiKey.detail])
            : null) ??
        'Something went wrong';

    int? code = statusCode;
    final s = json['status'];
    if (code == null && s is int) {
      code = s;
    }

    return ErrorModel(
      message: (m?.toString().isNotEmpty ?? false)
          ? m.toString()
          : 'An unknown error occurred.',
      statusCode: code,
    );
  }
}
