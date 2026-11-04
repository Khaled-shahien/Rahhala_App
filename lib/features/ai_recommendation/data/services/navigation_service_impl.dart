import 'package:latlong2/latlong.dart';
import 'package:rahhala_app/core/logging/app_logger.dart';
import 'package:rahhala_app/core/network/api_consumer.dart';
import 'package:rahhala_app/core/network/end_points.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/navigation/navigation_service.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/trip_details/trip_location_tracking_service.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/trip_details/trip_navigation_voice_service.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/trip_details/trip_route_helpers.dart';

class NavigationServiceImpl implements NavigationService {
  NavigationServiceImpl({
    required ApiConsumer api,
    required TripLocationTrackingService locationService,
    required TripNavigationVoiceService voiceService,
  })  : _api = api,
        _locationService = locationService,
        _voiceService = voiceService;

  final ApiConsumer _api;
  final TripLocationTrackingService _locationService;
  final TripNavigationVoiceService _voiceService;

  @override
  Future<TripRouteResponseData?> requestRoute({
    required LatLng from,
    required LatLng to,
  }) async {
    try {
      final response = await _api.post(
        EndPoints.getActivityRoute,
        data: {
          'travelMode': 'driving',
          'waypoints': [
            {'lat': from.latitude, 'lng': from.longitude, 'order': 1},
            {'lat': to.latitude, 'lng': to.longitude, 'order': 2},
          ],
        },
      );

      if (response is! Map<String, dynamic>) return null;

      final canDrawRoute = response['canDrawRoute'] == true;
      final encoded = response['polyline']?.toString();
      final totalDistance = response['totalDistance']?.toString() ?? '--';
      final totalDuration = response['totalDuration']?.toString() ?? '--';
      final steps = extractTripRouteSteps(response['steps']);
      final firstStep = steps.isNotEmpty ? steps.first : null;
      final nextInstruction = firstStep?.instruction ?? 'Follow the route';
      final nextInstructionDuration = firstStep?.duration ?? totalDuration;

      if (!canDrawRoute || encoded == null || encoded.isEmpty) {
        return TripRouteResponseData(
          polylinePoints: [from, to],
          totalDistance: totalDistance,
          totalDuration: totalDuration,
          nextInstruction: nextInstruction,
          nextInstructionDuration: nextInstructionDuration,
          steps: steps,
        );
      }

      final decoded = decodeTripPolylinePoints(encoded);
      return TripRouteResponseData(
        polylinePoints: decoded.length >= 2 ? decoded : [from, to],
        totalDistance: totalDistance,
        totalDuration: totalDuration,
        nextInstruction: nextInstruction,
        nextInstructionDuration: nextInstructionDuration,
        steps: steps,
      );
    } catch (e, stackTrace) {
      AppLogger.instance.w(
        'NavigationService: route request failed',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  @override
  Future<LatLng?> startNavigation() async {
    await _voiceService.configure();
    final position = await _locationService.getCurrentLocation();
    if (position == null) return null;
    return LatLng(position.latitude, position.longitude);
  }

  @override
  Future<void> stopNavigation() async {
    _locationService.stopTracking();
    await _voiceService.stop();
  }

  @override
  Future<void> speakInstruction(String instruction) {
    return _voiceService.speak(instruction);
  }
}
