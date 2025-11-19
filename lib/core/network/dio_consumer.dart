import 'package:dio/dio.dart';
import 'package:rahhala_app/core/network/api_consumer.dart';
import 'package:rahhala_app/core/network/end_points.dart';
import 'package:rahhala_app/core/errors/exceptions.dart';
import 'package:rahhala_app/core/network/api_interceptors.dart';

class DioConsumer extends ApiConsumer {
  final Dio dio;

  DioConsumer({required this.dio}) {
    dio.options = BaseOptions(
      baseUrl: EndPoints.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      responseType: ResponseType.json,
      validateStatus: (code) => true,
      headers: {
        'Accept': 'application/json',
        'Accept-Encoding': 'gzip',
      },
    );

    dio.interceptors.clear();
    dio.interceptors.add(ApiInterceptors());
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      requestHeader: true,
      error: true,
      responseBody: true,
      responseHeader: false,
    ));
  }

  @override
  Future get(String path,
      {Object? data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      _throwOnBadStatus(response);
      return response.data;
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future post(String path,
      {Object? data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response =
          await dio.post(path, data: data, queryParameters: queryParameters);
      _throwOnBadStatus(response);
      return response.data;
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future put(String path,
      {Object? data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response =
          await dio.put(path, data: data, queryParameters: queryParameters);
      _throwOnBadStatus(response);
      return response.data;
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future patch(String path,
      {Object? data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response =
          await dio.patch(path, data: data, queryParameters: queryParameters);
      _throwOnBadStatus(response);
      return response.data;
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future delete(String path,
      {Object? data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response =
          await dio.delete(path, data: data, queryParameters: queryParameters);
      _throwOnBadStatus(response);
      return response.data;
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  void _throwOnBadStatus(Response response) {
    final code = response.statusCode ?? 0;
    if (code >= 400) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }
}
