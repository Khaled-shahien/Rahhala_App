import 'package:geolocator/geolocator.dart';
import 'package:rahhala_app/features/nearby/domain/services/location_service.dart';

class GeolocatorLocationService implements LocationService {
  @override
  Future<LocationPoint> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceException(
        reason: LocationFailureReason.serviceDisabled,
        message: 'Location services are disabled.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationServiceException(
          reason: LocationFailureReason.permissionDenied,
          message: 'Location permission was denied.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationServiceException(
        reason: LocationFailureReason.permissionDeniedForever,
        message: 'Location permission is permanently denied.',
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return LocationPoint(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (error) {
      throw const LocationServiceException(
        reason: LocationFailureReason.unavailable,
        message: 'Unable to get your location. Please try again.',
      );
    }
  }
}
