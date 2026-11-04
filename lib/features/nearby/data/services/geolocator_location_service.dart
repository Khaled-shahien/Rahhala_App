import 'package:geolocator/geolocator.dart';
import 'package:rahhala_app/core/localization/app_messages.dart';
import 'package:rahhala_app/features/nearby/domain/services/location_service.dart';

class GeolocatorLocationService implements LocationService {
  @override
  Future<LocationPoint> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceException(
        reason: LocationFailureReason.serviceDisabled,
        message: AppMessages.current.errorLocationServiceDisabled,
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
      throw LocationServiceException(
        reason: LocationFailureReason.unavailable,
        message: AppMessages.current.errorLocationUnavailable,
      );
    }
  }
}
