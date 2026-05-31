import 'dart:async';
import 'package:geolocator/geolocator.dart';

/// Service wrapping Geolocator for trip location tracking.
///
/// Extracted from [_FullScreenDayRouteMapState] to keep GPS concerns
/// separate from map/widget logic and to improve testability.
class TripLocationTrackingService {
  StreamSubscription<Position>? _positionSubscription;
  Position? _lastKnownPosition;

  /// The last known position, if any.
  Position? get lastKnownPosition => _lastKnownPosition;

  /// Whether the position stream is actively subscribed.
  bool get isTracking => _positionSubscription != null;

  /// Request the current device position.
  ///
  /// Returns `null` if:
  ///  - Location services are disabled
  ///  - Permission is denied or permanently denied
  ///
  /// The [onServiceDisabled], [onPermissionDenied], and
  /// [onPermissionDeniedForever] callbacks are invoked to let the
  /// caller show appropriate UI messages.
  Future<Position?> getCurrentLocation({
    void Function()? onServiceDisabled,
    void Function()? onPermissionDenied,
    void Function()? onPermissionDeniedForever,
  }) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      onServiceDisabled?.call();
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      onPermissionDenied?.call();
      return null;
    }

    if (permission == LocationPermission.deniedForever) {
      onPermissionDeniedForever?.call();
      return null;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings:
          const LocationSettings(accuracy: LocationAccuracy.best),
    );
    _lastKnownPosition = position;
    return position;
  }

  /// Start listening to position updates.
  ///
  /// [onUpdate] is called for each new position.
  /// [onError] is called if the location stream encounters an error.
  ///
  /// Does nothing if already tracking.
  void startTracking({
    required void Function(Position position) onUpdate,
    void Function(dynamic error)? onError,
  }) {
    if (_positionSubscription != null) return;

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    ).listen(
      (position) {
        _lastKnownPosition = position;
        onUpdate(position);
      },
      onError: (error) {
        onError?.call(error);
      },
    );
  }

  /// Stop listening to position updates.
  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  /// Release resources.
  void dispose() {
    stopTracking();
    _lastKnownPosition = null;
  }
}
