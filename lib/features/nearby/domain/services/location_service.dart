enum LocationFailureReason {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  unavailable,
}

class LocationPoint {
  const LocationPoint({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;
}

class LocationServiceException implements Exception {
  const LocationServiceException({
    required this.reason,
    required this.message,
  });

  final LocationFailureReason reason;
  final String message;

  @override
  String toString() => message;
}

abstract class LocationService {
  Future<LocationPoint> getCurrentLocation();
}
