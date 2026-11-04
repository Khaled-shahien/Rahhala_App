import 'package:dio/dio.dart';

/// Adds JSON headers and the bearer token to every request.
class ApiInterceptors extends Interceptor {
  ApiInterceptors({required String? Function() tokenProvider})
      : _tokenProvider = tokenProvider;

  final String? Function() _tokenProvider;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept'] = 'application/json';

    if (options.data is FormData) {
      // Let Dio set the multipart boundary.
      options.headers.remove('Content-Type');
    } else {
      options.headers.putIfAbsent(
        'Content-Type',
        () => 'application/json; charset=utf-8',
      );
    }

    final token = _tokenProvider();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    } else {
      options.headers.remove('Authorization');
    }

    handler.next(options);
  }
}
