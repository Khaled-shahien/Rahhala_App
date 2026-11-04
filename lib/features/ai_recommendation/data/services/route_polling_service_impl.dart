import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/navigation/route_polling_service.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/navigation/route_update.dart';

class RoutePollingServiceImpl implements RoutePollingService {
  final _controller = StreamController<RouteUpdate>.broadcast();
  StreamSubscription<Position>? _subscription;

  @override
  Stream<RouteUpdate> get updates => _controller.stream;

  @override
  void startPolling() {
    if (_subscription != null) return;

    _subscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    ).listen((position) {
      _controller.add(
        RouteUpdate(
          location: LatLng(position.latitude, position.longitude),
          speedMetersPerSecond: position.speed,
        ),
      );
    }, onError: _controller.addError);
  }

  @override
  void stopPolling() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> dispose() async {
    stopPolling();
    await _controller.close();
  }
}
