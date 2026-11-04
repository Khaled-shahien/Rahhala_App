import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rahhala_app/core/errors/error_model.dart';
import 'package:rahhala_app/core/errors/exceptions.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/core/localization/app_messages.dart';
import 'package:rahhala_app/l10n/generated/app_localizations.dart';

DioException _dio(
  DioExceptionType type, {
  int? status,
  Object? data,
  Object? error,
}) {
  final options = RequestOptions(path: '/api/test');
  return DioException(
    requestOptions: options,
    type: type,
    error: error,
    response: status == null
        ? null
        : Response<dynamic>(
            requestOptions: options,
            statusCode: status,
            data: data,
          ),
  );
}

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final ar = lookupAppLocalizations(const Locale('ar'));

  setUp(() => AppMessages.localeResolver = () => const Locale('en'));

  group('mapDioException', () {
    test('maps every timeout type, including transformTimeout', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.transformTimeout,
      ]) {
        final model = mapDioException(_dio(type)).errorModel;
        expect(model.type, FailureType.timeout, reason: '$type');
        expect(model.message, en.errorTimeout);
      }
    });

    test('maps connection problems to network', () {
      for (final type in [
        DioExceptionType.connectionError,
        DioExceptionType.badCertificate,
      ]) {
        expect(mapDioException(_dio(type)).errorModel.type,
            FailureType.network);
      }
    });

    test('maps unknown with a SocketException to network', () {
      final model = mapDioException(_dio(
        DioExceptionType.unknown,
        error: const SocketException('down'),
      )).errorModel;
      expect(model.type, FailureType.network);
      expect(model.message, en.errorNetwork);
    });

    test('maps unknown without a known cause to unknown', () {
      final model = mapDioException(_dio(DioExceptionType.unknown)).errorModel;
      expect(model.type, FailureType.unknown);
      expect(model.message, en.errorUnknown);
    });

    test('maps cancel to cancelled', () {
      expect(mapDioException(_dio(DioExceptionType.cancel)).errorModel.type,
          FailureType.cancelled);
    });

    test('uses the backend message for 4xx business errors', () {
      final model = mapDioException(_dio(
        DioExceptionType.badResponse,
        status: 400,
        data: {'message': 'Email already exists'},
      )).errorModel;
      expect(model.type, FailureType.validation);
      expect(model.statusCode, 400);
      expect(model.message, 'Email already exists');
    });

    test('reads ASP.NET validation problem details', () {
      final model = mapDioException(_dio(
        DioExceptionType.badResponse,
        status: 422,
        data: {
          'title': 'One or more validation errors occurred.',
          'errors': {
            'Email': ['The Email field is required.'],
          },
        },
      )).errorModel;
      expect(model.message, 'The Email field is required.');
    });

    test('decodes a JSON string body', () {
      final model = mapDioException(_dio(
        DioExceptionType.badResponse,
        status: 401,
        data: '{"Message":"Invalid password"}',
      )).errorModel;
      expect(model.type, FailureType.unauthorized);
      expect(model.message, 'Invalid password');
    });

    test('never shows 5xx bodies, which may contain internals', () {
      final model = mapDioException(_dio(
        DioExceptionType.badResponse,
        status: 500,
        data: {'message': 'NullReferenceException at Rahhala.Api...'},
      )).errorModel;
      expect(model.type, FailureType.server);
      expect(model.message, en.errorServer);
    });

    test('falls back to localized text when the body has no message', () {
      expect(
        mapDioException(_dio(DioExceptionType.badResponse, status: 404))
            .errorModel
            .message,
        en.errorNotFound,
      );
      expect(
        mapDioException(_dio(DioExceptionType.badResponse, status: 403))
            .errorModel
            .type,
        FailureType.forbidden,
      );
    });

    test('localizes messages in the current app language', () {
      AppMessages.localeResolver = () => const Locale('ar');
      expect(
        mapDioException(_dio(DioExceptionType.connectionError))
            .errorModel
            .message,
        ar.errorNetwork,
      );
    });
  });

  group('failureFromError', () {
    test('keeps type and status from ServerException', () {
      const exception = ServerException(
        errorModel: ErrorModel(
          message: 'Nope',
          statusCode: 409,
          type: FailureType.validation,
        ),
      );
      final failure = failureFromError(exception);
      expect(failure.type, FailureType.validation);
      expect(failure.statusCode, 409);
      expect(failure.message, 'Nope');
    });

    test('maps raw DioException', () {
      expect(failureFromError(_dio(DioExceptionType.receiveTimeout)).type,
          FailureType.timeout);
    });

    test('maps parsing errors without leaking their text', () {
      final failure = failureFromError(const FormatException('bad json'));
      expect(failure.type, FailureType.parsing);
      expect(failure.message, en.errorParsing);
      expect(failure.message, isNot(contains('bad json')));
    });

    test('maps TimeoutException and SocketException', () {
      expect(failureFromError(TimeoutException('t')).type, FailureType.timeout);
      expect(failureFromError(const SocketException('s')).type,
          FailureType.network);
    });

    test('maps anything else to a generic message', () {
      final failure = failureFromError(StateError('internal detail'));
      expect(failure.type, FailureType.unknown);
      expect(failure.message, en.errorUnknown);
    });

    test('returns a Failure unchanged', () {
      const failure = ServerFailure(message: 'x', type: FailureType.notFound);
      expect(identical(failureFromError(failure), failure), isTrue);
    });
  });

  group('ErrorModel.extractServerMessage', () {
    test('prefers the first validation error', () {
      expect(
        ErrorModel.extractServerMessage({
          'errors': {
            'Password': ['Too short', 'Needs a digit'],
          },
          'title': 'Validation failed',
        }),
        'Too short',
      );
    });

    test('supports Identity-style error lists', () {
      expect(
        ErrorModel.extractServerMessage({
          'errors': [
            {'code': 'DuplicateEmail', 'description': 'Email is taken'},
          ],
        }),
        'Email is taken',
      );
    });

    test('reads nested data.message and ignores non-strings', () {
      expect(
        ErrorModel.extractServerMessage({
          'message': 42,
          'data': {'message': 'Nested'},
        }),
        'Nested',
      );
    });

    test('returns null when there is no usable message', () {
      expect(ErrorModel.extractServerMessage({'message': '   '}), isNull);
      expect(ErrorModel.extractServerMessage(const {}), isNull);
    });
  });

  group('failureTypeForStatus', () {
    test('classifies status codes', () {
      expect(failureTypeForStatus(400), FailureType.validation);
      expect(failureTypeForStatus(401), FailureType.unauthorized);
      expect(failureTypeForStatus(403), FailureType.forbidden);
      expect(failureTypeForStatus(404), FailureType.notFound);
      expect(failureTypeForStatus(408), FailureType.timeout);
      expect(failureTypeForStatus(503), FailureType.server);
    });
  });
}
