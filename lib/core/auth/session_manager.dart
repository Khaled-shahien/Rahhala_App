import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rahhala_app/core/auth/auth_session_service.dart';
import 'package:rahhala_app/core/crash/app_error_reporter.dart';

/// Why a session ended.
enum SessionEndReason { logout, accountDeleted, expired }

/// Ends sessions and resets every user-scoped piece of state.
///
/// Logout, account deletion and token expiry (401) all go through
/// [endSession], so cached data from one user (the chatbot conversation,
/// the in-memory image cache, analytics identity) never leaks to the next.
///
/// It's also the router's `refreshListenable`: listeners are notified after
/// the session is cleared, so route guards re-run and protected screens
/// redirect to `/welcome`.
class SessionManager extends ChangeNotifier {
  SessionManager({required AuthSessionService authSessionService})
      : _authSessionService = authSessionService;

  final AuthSessionService _authSessionService;
  final List<FutureOr<void> Function()> _resetCallbacks = [];

  SessionEndReason? _pendingReason;
  Future<void>? _ending;

  /// Registers a callback that clears user-scoped state. Callbacks run on
  /// every session end, in registration order. A failure in one callback
  /// doesn't stop the others.
  void registerResetCallback(FutureOr<void> Function() callback) {
    _resetCallbacks.add(callback);
  }

  bool get hasSession => _authSessionService.hasToken;

  /// Returns the reason of the last session end and clears it, so a
  /// message (for example, "session expired") is shown only once.
  SessionEndReason? consumeEndReason() {
    final reason = _pendingReason;
    _pendingReason = null;
    return reason;
  }

  /// Called when the API rejects the stored token. Concurrent 401s collapse
  /// into a single session end.
  void expireSession() {
    if (!_authSessionService.hasToken) return;
    unawaited(endSession(SessionEndReason.expired));
  }

  /// Clears the stored session, runs every reset callback and notifies
  /// listeners. Calls made while a previous end is in progress wait for it
  /// instead of running twice.
  Future<void> endSession(SessionEndReason reason) {
    final inFlight = _ending;
    if (inFlight != null) return inFlight;

    final future = _end(reason);
    _ending = future;
    return future.whenComplete(() => _ending = null);
  }

  Future<void> _end(SessionEndReason reason) async {
    await _authSessionService.clearSession();
    for (final callback in _resetCallbacks) {
      try {
        await callback();
      } catch (e, stackTrace) {
        AppErrorReporter.record(
          'SessionManager: reset callback failed',
          error: e,
          stackTrace: stackTrace,
        );
      }
    }
    _pendingReason = reason;
    notifyListeners();
  }
}
