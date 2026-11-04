import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rahhala_app/core/auth/auth_session_service.dart';
import 'package:rahhala_app/core/auth/session_manager.dart';

class _MockAuthSessionService extends Mock implements AuthSessionService {}

void main() {
  late _MockAuthSessionService authSession;
  late SessionManager manager;

  setUp(() {
    authSession = _MockAuthSessionService();
    when(() => authSession.clearSession()).thenAnswer((_) async {});
    when(() => authSession.hasToken).thenReturn(true);
    manager = SessionManager(authSessionService: authSession);
  });

  test('endSession clears storage, runs callbacks and notifies listeners',
      () async {
    final calls = <String>[];
    manager
      ..registerResetCallback(() => calls.add('chat'))
      ..registerResetCallback(() async => calls.add('cache'));
    var notified = 0;
    manager.addListener(() => notified++);

    await manager.endSession(SessionEndReason.logout);

    verify(() => authSession.clearSession()).called(1);
    expect(calls, ['chat', 'cache']);
    expect(notified, 1);
  });

  test('a failing reset callback does not stop the others', () async {
    final calls = <String>[];
    manager
      ..registerResetCallback(() => throw StateError('boom'))
      ..registerResetCallback(() => calls.add('second'));

    await manager.endSession(SessionEndReason.logout);

    expect(calls, ['second']);
  });

  test('consumeEndReason returns the reason once', () async {
    await manager.endSession(SessionEndReason.expired);

    expect(manager.consumeEndReason(), SessionEndReason.expired);
    expect(manager.consumeEndReason(), isNull);
  });

  test('concurrent session ends collapse into one', () async {
    var resets = 0;
    manager.registerResetCallback(() => resets++);

    await Future.wait([
      manager.endSession(SessionEndReason.expired),
      manager.endSession(SessionEndReason.expired),
      manager.endSession(SessionEndReason.expired),
    ]);

    verify(() => authSession.clearSession()).called(1);
    expect(resets, 1);
  });

  test('expireSession does nothing when there is no token (guest)', () async {
    when(() => authSession.hasToken).thenReturn(false);

    manager.expireSession();
    await Future<void>.delayed(Duration.zero);

    verifyNever(() => authSession.clearSession());
  });

  test('expireSession ends the session with the expired reason', () async {
    manager.expireSession();
    await Future<void>.delayed(Duration.zero);

    verify(() => authSession.clearSession()).called(1);
    expect(manager.consumeEndReason(), SessionEndReason.expired);
  });
}
