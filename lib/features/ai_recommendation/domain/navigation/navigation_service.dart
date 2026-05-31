import 'package:latlong2/latlong.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/trip_details/trip_route_helpers.dart';

abstract class NavigationService {
  Future<TripRouteResponseData?> requestRoute({
    required LatLng from,
    required LatLng to,
  });

  Future<LatLng?> startNavigation();

  Future<void> stopNavigation();

  Future<void> speakInstruction(String instruction);
}
