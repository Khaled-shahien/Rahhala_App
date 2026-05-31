import 'package:dio/dio.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/utils/token_storage.dart';

class ApiInterceptors extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept'] = 'application/json';
    options.headers['Accept-Encoding'] = 'gzip';

    final isMultipart = options.data is FormData;
    if (isMultipart) {
      options.headers.remove('Content-Type');
    } else {
      options.headers.putIfAbsent(
        'Content-Type',
        () => 'application/json; charset=utf-8',
      );
    }

    final tokenStorage = sl<TokenStorage>();
    final token = tokenStorage.token;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    } else {
      options.headers.remove('Authorization');
    }

    handler.next(options);
  }
}
