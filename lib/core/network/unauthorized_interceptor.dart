import 'package:dio/dio.dart';

/// Ends the session when an authenticated request is rejected with 401.
///
/// Requests to the auth endpoints (`/api/Auth/...`) are ignored: a 401 there
/// means wrong credentials, not an expired session. Requests sent without a
/// bearer token (guests) are ignored too.
class UnauthorizedInterceptor extends Interceptor {
  UnauthorizedInterceptor({required void Function() onSessionExpired})
      : _onSessionExpired = onSessionExpired;

  final void Function() _onSessionExpired;

  static const String _authPathPrefix = '/api/auth/';

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (isSessionExpiry(err)) {
      _onSessionExpired();
    }
    handler.next(err);
  }

  /// Whether [err] means the stored token is no longer valid.
  static bool isSessionExpiry(DioException err) {
    if (err.response?.statusCode != 401) return false;

    final options = err.requestOptions;
    final hadToken = options.headers['Authorization'] is String;
    final isAuthEndpoint =
        options.path.toLowerCase().startsWith(_authPathPrefix);
    return hadToken && !isAuthEndpoint;
  }
}
