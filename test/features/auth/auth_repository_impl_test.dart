import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rahhala_app/core/errors/error_model.dart';
import 'package:rahhala_app/core/errors/exceptions.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/core/localization/app_messages.dart';
import 'package:rahhala_app/core/network/api_consumer.dart';
import 'package:rahhala_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:rahhala_app/features/auth/domain/entities/login.dart';
import 'package:rahhala_app/l10n/generated/app_localizations.dart';

class _MockApiConsumer extends Mock implements ApiConsumer {}

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  late _MockApiConsumer api;
  late AuthRepoImpl repo;

  setUp(() {
    AppMessages.localeResolver = () => const Locale('en');
    api = _MockApiConsumer();
    repo = AuthRepoImpl(apiConsumer: api);
  });

  void stubLogin(Object? Function() response) {
    when(() => api.post(any(), data: any(named: 'data'))).thenAnswer(
      (_) async => response(),
    );
  }

  test('login returns the token from a nested data object', () async {
    stubLogin(() => {
          'data': {'token': 'jwt-1', 'fullName': 'Mona'},
        });

    final result = await repo.loginUser(email: 'a@b.com', password: 'x');

    expect(result.getOrElse(() => const Login()),
        const Login(token: 'jwt-1', username: 'Mona'));
  });

  test('login without a token is a failure, not a silent success', () async {
    stubLogin(() => {'message': 'ok'});

    final result = await repo.loginUser(email: 'a@b.com', password: 'x');

    final failure = result.fold((f) => f, (_) => null);
    expect(failure?.message, en.errorLoginMissingToken);
  });

  test('a token of the wrong type is ignored instead of throwing', () async {
    stubLogin(() => {'token': 12345});

    final result = await repo.loginUser(email: 'a@b.com', password: 'x');

    expect(result.isLeft(), isTrue);
  });

  test('server errors keep their type and backend message', () async {
    when(() => api.post(any(), data: any(named: 'data'))).thenThrow(
      const ServerException(
        errorModel: ErrorModel(
          message: 'Invalid email or password',
          statusCode: 401,
          type: FailureType.unauthorized,
        ),
      ),
    );

    final result = await repo.loginUser(email: 'a@b.com', password: 'x');

    final failure = result.fold((f) => f, (_) => null);
    expect(failure?.type, FailureType.unauthorized);
    expect(failure?.message, 'Invalid email or password');
  });

  test('unexpected exceptions become failures', () async {
    when(() => api.post(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
        )).thenThrow(StateError('boom'));

    final result = await repo.forgotPassword(email: 'a@b.com');

    expect(result.fold((f) => f.type, (_) => null), FailureType.unknown);
  });
}
