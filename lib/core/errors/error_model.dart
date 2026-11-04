import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/core/network/end_points.dart';

/// Error details extracted from a failed API call.
class ErrorModel {
  const ErrorModel({
    required this.message,
    this.statusCode,
    this.type = FailureType.server,
  });

  /// Safe, user-facing message.
  final String message;
  final int? statusCode;
  final FailureType type;

  /// Extracts the most specific human-readable message from an API error
  /// body. Handles ASP.NET Core `ProblemDetails` / validation responses and
  /// the backend's `{ message | Message | error | detail | title }` shapes.
  /// Returns `null` when the body contains no usable message.
  static String? extractServerMessage(Map<String, dynamic> json) {
    final errors = json['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final firstValue = errors.values.first;
      if (firstValue is List && firstValue.isNotEmpty) {
        return _nonEmpty(firstValue.first);
      }
      final fromValue = _nonEmpty(firstValue);
      if (fromValue != null) return fromValue;
    } else if (errors is List && errors.isNotEmpty) {
      final first = errors.first;
      if (first is Map) {
        return _nonEmpty(first['description'] ?? first['message']);
      }
      return _nonEmpty(first);
    }

    final data = json[ApiKey.data];
    return _nonEmpty(json[ApiKey.message]) ??
        _nonEmpty(json[ApiKey.Message]) ??
        _nonEmpty(json[ApiKey.error]) ??
        _nonEmpty(json['error_description']) ??
        _nonEmpty(json[ApiKey.detail]) ??
        _nonEmpty(json['title']) ??
        (data is Map
            ? _nonEmpty(data[ApiKey.message]) ?? _nonEmpty(data[ApiKey.detail])
            : null);
  }

  static String? _nonEmpty(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
