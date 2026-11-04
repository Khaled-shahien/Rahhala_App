import 'package:dio/dio.dart';
import 'package:rahhala_app/core/errors/exceptions.dart';
import 'package:rahhala_app/core/network/api_consumer.dart';

/// [ApiConsumer] backed by a configured [Dio] instance.
///
/// The [Dio] (base URL, timeouts, interceptors) is configured once in the
/// service locator. This class must not mutate it: other repositories share
/// the same instance.
class DioConsumer extends ApiConsumer {
  DioConsumer({required this.dio});

  final Dio dio;

  @override
  Future<dynamic> get(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _send(
        () => dio.get<dynamic>(path, queryParameters: queryParameters));
  }

  @override
  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _send(
      () => dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
      ),
    );
  }

  @override
  Future<dynamic> put(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _send(
      () => dio.put<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
      ),
    );
  }

  @override
  Future<dynamic> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _send(
      () => dio.patch<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
      ),
    );
  }

  @override
  Future<dynamic> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _send(
      () => dio.delete<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
      ),
    );
  }

  Future<dynamic> _send(Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      final code = response.statusCode ?? 0;
      if (code >= 400) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
      return response.data;
    } on DioException catch (e) {
      handleDioException(e);
    }
  }
}
