import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:rahhala_app/core/analytics/analytics_service.dart';

class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) {
    return _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  @override
  Future<void> setUser(
    String? userId, {
    Map<String, String>? properties,
  }) async {
    await _analytics.setUserId(id: userId);
    final safeProperties = properties ?? const <String, String>{};
    for (final entry in safeProperties.entries) {
      await _analytics.setUserProperty(
        name: entry.key,
        value: entry.value,
      );
    }
  }

  @override
  Future<void> logScreen(
    String screenName, {
    String? screenClass,
  }) {
    return _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }
}
