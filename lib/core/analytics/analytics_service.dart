abstract class AnalyticsService {
  Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  });

  Future<void> setUser(
    String? userId, {
    Map<String, String>? properties,
  });

  Future<void> logScreen(
    String screenName, {
    String? screenClass,
  });
}

class NoopAnalyticsService implements AnalyticsService {
  const NoopAnalyticsService();

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {}

  @override
  Future<void> setUser(
    String? userId, {
    Map<String, String>? properties,
  }) async {}

  @override
  Future<void> logScreen(
    String screenName, {
    String? screenClass,
  }) async {}
}
