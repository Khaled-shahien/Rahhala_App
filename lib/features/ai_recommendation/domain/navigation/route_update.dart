import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class RouteUpdate extends Equatable {
  const RouteUpdate({
    required this.location,
    required this.speedMetersPerSecond,
  });

  final LatLng location;
  final double speedMetersPerSecond;

  @override
  List<Object?> get props => [location, speedMetersPerSecond];
}
