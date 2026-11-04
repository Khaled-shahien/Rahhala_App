import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/network/unauthorized_interceptor.dart';

/// Answers every request with a fixed status code, without a network.
class _StatusAdapter implements HttpClientAdapter {
  _StatusAdapter(this.statusCode);

  final int statusCode;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      '{"message":"status $statusCode"}',
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

DioException _error({
  required int status,
  required String path,
  bool withToken = true,
}) {
  final options = RequestOptions(
    path: path,
    headers: {if (withToken) 'Authorization': 'Bearer abc'},
  );
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(requestOptions: options, statusCode: status),
  );
}

void main() {
  group('UnauthorizedInterceptor.isSessionExpiry', () {
    test('true for 401 on an authenticated, non-auth endpoint', () {
      expect(
        UnauthorizedInterceptor.isSessionExpiry(
          _error(status: 401, path: '/api/User/GetDetails'),
        ),
        isTrue,
      );
    });

    test('false for wrong credentials on the login endpoint', () {
      expect(
        UnauthorizedInterceptor.isSessionExpiry(
          _error(status: 401, path: '/api/Auth/Login'),
        ),
        isFalse,
      );
    });

    test('false for guest requests without a token', () {
      expect(
        UnauthorizedInterceptor.isSessionExpiry(
          _error(status: 401, path: '/api/Home/Favourites', withToken: false),
        ),
        isFalse,
      );
    });

    test('false for other status codes', () {
      expect(
        UnauthorizedInterceptor.isSessionExpiry(
          _error(status: 403, path: '/api/User/GetDetails'),
        ),
        isFalse,
      );
    });
  });

  group('createApiDio', () {
    test('sets base URL, auth header and reports expired sessions', () async {
      var expired = 0;
      final adapter = _StatusAdapter(401);
      final dio = createApiDio(
        baseUrl: 'https://api.example.com',
        tokenProvider: () => 'token-123',
        onSessionExpired: () => expired++,
      )..httpClientAdapter = adapter;

      await expectLater(
        dio.get<dynamic>('/api/User/GetDetails'),
        throwsA(isA<DioException>()),
      );

      final request = adapter.requests.single;
      expect(request.uri.toString(),
          'https://api.example.com/api/User/GetDetails');
      expect(request.headers['Authorization'], 'Bearer token-123');
      expect(expired, 1);
    });

    test('omits the auth header for guests', () async {
      final adapter = _StatusAdapter(200);
      final dio = createApiDio(
        baseUrl: 'https://api.example.com',
        tokenProvider: () => null,
        onSessionExpired: () {},
      )..httpClientAdapter = adapter;

      await dio.get<dynamic>('/api/Home/GetHome');

      expect(adapter.requests.single.headers.containsKey('Authorization'),
          isFalse);
    });

    test('does not report expiry for a failed login', () async {
      var expired = 0;
      final dio = createApiDio(
        baseUrl: 'https://api.example.com',
        tokenProvider: () => 'stale',
        onSessionExpired: () => expired++,
      )..httpClientAdapter = _StatusAdapter(401);

      await expectLater(
        dio.post<dynamic>('/api/Auth/Login'),
        throwsA(isA<DioException>()),
      );
      expect(expired, 0);
    });
  });
}
