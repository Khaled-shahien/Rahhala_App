import 'package:rahhala_app/core/network/end_points.dart';

class SuccessMessageModel {
  final String message;
  SuccessMessageModel({required this.message});

  factory SuccessMessageModel.fromJson(Map<String, dynamic> json) {
    String? m = json[ApiKey.message] ??
        json[ApiKey.Message] ??
        json[ApiKey.msg] ??
        json[ApiKey.detail] ??
        (json[ApiKey.data] is Map<String, dynamic>
            ? (json[ApiKey.data][ApiKey.message] ??
                json[ApiKey.data][ApiKey.detail])
            : null) ??
        json[ApiKey.status];

    return SuccessMessageModel(
      message: (m == null || m.toString().isEmpty)
          ? 'Operation completed successfully.'
          : m.toString(),
    );
  }
}
