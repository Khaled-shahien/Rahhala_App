import 'package:rahhala_app/features/ai_recommendation/domain/navigation/route_update.dart';

abstract class RoutePollingService {
  Stream<RouteUpdate> get updates;

  void startPolling();

  void stopPolling();
}
