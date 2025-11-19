import 'package:rahhala_app/core/network/end_points.dart';

class ErrorModel {
  final String message;
  final int? statusCode;

  ErrorModel({required this.message, this.statusCode});

  factory ErrorModel.fromJson(
    Map<String, dynamic> json, {
    int? statusCode,
  }) {
    
    String? m = json[ApiKey.message] ??
        json[ApiKey.Message] ??
        json[ApiKey.error] ??
        json['error_description'] ??
        json[ApiKey.detail] ??
        (json[ApiKey.data] is Map<String, dynamic>
            ? (json[ApiKey.data][ApiKey.message] ??
                json[ApiKey.data][ApiKey.detail])
            : null) ??
        json[ApiKey.status];

    int? code = statusCode;
    final s = json[ApiKey.status];
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
