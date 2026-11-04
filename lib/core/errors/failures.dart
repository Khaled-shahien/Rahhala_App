import 'package:equatable/equatable.dart';

/// Category of a failure, so the UI can localize and branch without parsing
/// message text.
enum FailureType {
  network,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  validation,
  server,
  parsing,
  cancelled,
  unknown,
}

/// A failure that can be shown to the user.
///
/// [message] is always safe to display: it's either a localized message
/// for [type] or a business message returned by the backend (for example,
/// "Email already exists"). It never contains exception internals.
abstract class Failure extends Equatable {
  const Failure({
    required this.message,
    this.type = FailureType.unknown,
    this.statusCode,
  });

  final String message;
  final FailureType type;
  final int? statusCode;

  bool get isUnauthorized => type == FailureType.unauthorized;

  bool get isConnectivity =>
      type == FailureType.network || type == FailureType.timeout;

  @override
  List<Object?> get props => [message, type, statusCode];

  @override
  String toString() => '$runtimeType($type, $statusCode): $message';
}

class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.type = FailureType.server,
    super.statusCode,
  });
}
