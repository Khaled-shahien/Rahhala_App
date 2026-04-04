import 'dart:async';

import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor({required Dio dio, this.maxRetries = 2}) : _dio = dio;

  final Dio _dio;
  final int maxRetries;

  static const Set<String> _retryableMethods = <String>{
    'GET',
    'HEAD',
    'OPTIONS',
  };

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final method = err.requestOptions.method.toUpperCase();
    if (!_retryableMethods.contains(method)) {
      handler.next(err);
      return;
    }

    final attempt = (err.requestOptions.extra['retry_attempt'] as int?) ?? 0;
    if (attempt >= maxRetries || !_isRetryableError(err)) {
      handler.next(err);
      return;
    }

    final nextAttempt = attempt + 1;
    final delay = Duration(milliseconds: 300 * nextAttempt);
    await Future<void>.delayed(delay);

    final options = Options(
      method: err.requestOptions.method,
      headers: err.requestOptions.headers,
      responseType: err.requestOptions.responseType,
      contentType: err.requestOptions.contentType,
      sendTimeout: err.requestOptions.sendTimeout,
      receiveTimeout: err.requestOptions.receiveTimeout,
      extra: Map<String, dynamic>.from(err.requestOptions.extra)
        ..['retry_attempt'] = nextAttempt,
    );

    try {
      final response = await _dio.request<dynamic>(
        err.requestOptions.path,
        data: err.requestOptions.data,
        queryParameters: err.requestOptions.queryParameters,
        options: options,
        cancelToken: err.requestOptions.cancelToken,
        onReceiveProgress: err.requestOptions.onReceiveProgress,
        onSendProgress: err.requestOptions.onSendProgress,
      );
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  bool _isRetryableError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return true;
    }

    if (error.type == DioExceptionType.badResponse) {
      final code = error.response?.statusCode ?? 0;
      return code == 429 || code == 502 || code == 503 || code == 504;
    }

    return false;
  }
}
