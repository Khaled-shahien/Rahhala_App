import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:rahhala_app/core/errors/error_model.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/core/localization/app_messages.dart';
import 'package:rahhala_app/l10n/generated/app_localizations.dart';

/// Thrown by the network layer. [errorModel] carries a typed, user-safe
/// message.
class ServerException implements Exception {
  const ServerException({required this.errorModel});

  final ErrorModel errorModel;

  @override
  String toString() =>
      'ServerException(${errorModel.type}, ${errorModel.statusCode}): '
      '${errorModel.message}';
}

/// Converts a [DioException] into a [ServerException] and throws it.
Never handleDioException(DioException e) => throw mapDioException(e);

/// Maps every [DioExceptionType] to a typed, localized [ServerException].
ServerException mapDioException(DioException e) {
  final l10n = AppMessages.current;

  ServerException build(FailureType type, String message, [int? code]) {
    return ServerException(
      errorModel: ErrorModel(message: message, statusCode: code, type: type),
    );
  }

  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return build(FailureType.timeout, l10n.errorTimeout);
    case DioExceptionType.connectionError:
    case DioExceptionType.badCertificate:
      return build(FailureType.network, l10n.errorNetwork);
    case DioExceptionType.cancel:
      return build(FailureType.cancelled, l10n.errorCancelled);
    case DioExceptionType.unknown:
      final inner = e.error;
      if (inner is SocketException || inner is HttpException) {
        return build(FailureType.network, l10n.errorNetwork);
      }
      return build(FailureType.unknown, l10n.errorUnknown);
    case DioExceptionType.badResponse:
      final statusCode = e.response?.statusCode ?? 0;
      final serverMessage = _serverMessage(e.response?.data);
      final type = failureTypeForStatus(statusCode);
      return build(
        type,
        messageForStatus(statusCode, serverMessage, l10n),
        statusCode,
      );
  }
}

/// Failure category for an HTTP status code.
FailureType failureTypeForStatus(int statusCode) {
  return switch (statusCode) {
    400 || 409 || 422 => FailureType.validation,
    401 => FailureType.unauthorized,
    403 => FailureType.forbidden,
    404 => FailureType.notFound,
    408 => FailureType.timeout,
    >= 500 => FailureType.server,
    _ => FailureType.server,
  };
}

/// User-facing message for an HTTP error.
///
/// The backend's own message is used only for client errors (400/401/409/
/// 422), where it describes the business problem, such as "Email already
/// exists" or "Invalid password". For 5xx responses the body may contain
/// stack traces or internal details, so a localized generic message is shown
/// instead.
String messageForStatus(
  int statusCode,
  String? serverMessage,
  AppLocalizations l10n,
) {
  final useServerMessage = serverMessage != null &&
      (statusCode == 400 ||
          statusCode == 401 ||
          statusCode == 409 ||
          statusCode == 422);
  if (useServerMessage) return serverMessage;

  return switch (statusCode) {
    400 || 409 || 422 => l10n.errorValidation,
    401 => l10n.errorSessionExpired,
    403 => l10n.errorForbidden,
    404 => l10n.errorNotFound,
    408 => l10n.errorTimeout,
    _ => l10n.errorServer,
  };
}

String? _serverMessage(Object? data) {
  Map<String, dynamic>? map;
  if (data is Map<String, dynamic>) {
    map = data;
  } else if (data is Map) {
    map = Map<String, dynamic>.from(data);
  } else if (data is String && data.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(data);
      if (decoded is Map) map = Map<String, dynamic>.from(decoded);
    } on FormatException {
      return null;
    }
  }
  return map == null ? null : ErrorModel.extractServerMessage(map);
}

/// Converts any error into a user-safe [Failure].
///
/// Use this in every `catch` of a repository or cubit instead of showing
/// `e.toString()` to the user.
Failure failureFromError(Object error) {
  final l10n = AppMessages.current;
  if (error is Failure) return error;
  if (error is ServerException) {
    return ServerFailure(
      message: error.errorModel.message,
      type: error.errorModel.type,
      statusCode: error.errorModel.statusCode,
    );
  }
  if (error is DioException) return failureFromError(mapDioException(error));
  if (error is SocketException || error is HttpException) {
    return ServerFailure(message: l10n.errorNetwork, type: FailureType.network);
  }
  if (error is TimeoutException) {
    return ServerFailure(message: l10n.errorTimeout, type: FailureType.timeout);
  }
  if (error is FormatException || error is TypeError) {
    return ServerFailure(message: l10n.errorParsing, type: FailureType.parsing);
  }
  return ServerFailure(message: l10n.errorUnknown, type: FailureType.unknown);
}
