import 'package:latlong2/latlong.dart';

List<LatLng> decodeTripPolylinePoints(String encoded) {
  final points = <LatLng>[];
  int index = 0;
  int lat = 0;
  int lng = 0;

  while (index < encoded.length) {
    int result = 0;
    int shift = 0;
    int byte;
    do {
      byte = encoded.codeUnitAt(index++) - 63;
      result |= (byte & 0x1f) << shift;
      shift += 5;
    } while (byte >= 0x20);
    final deltaLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    lat += deltaLat;

    result = 0;
    shift = 0;
    do {
      byte = encoded.codeUnitAt(index++) - 63;
      result |= (byte & 0x1f) << shift;
      shift += 5;
    } while (byte >= 0x20);
    final deltaLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    lng += deltaLng;

    points.add(LatLng(lat / 1e5, lng / 1e5));
  }

  return points;
}

LatLng? extractTripStepPoint(dynamic value) {
  if (value is Map<String, dynamic>) {
    final lat = (value['lat'] as num?)?.toDouble() ??
        (value['latitude'] as num?)?.toDouble();
    final lng = (value['lng'] as num?)?.toDouble() ??
        (value['longitude'] as num?)?.toDouble();
    if (lat != null && lng != null) {
      return LatLng(lat, lng);
    }
  }
  return null;
}

List<TripRouteStepData> extractTripRouteSteps(dynamic rawSteps) {
  if (rawSteps is! List) {
    return const [];
  }

  final steps = <TripRouteStepData>[];
  for (final step in rawSteps) {
    if (step is! Map<String, dynamic>) {
      continue;
    }

    final instruction = step['instruction']?.toString().trim() ?? '';
    if (instruction.isEmpty) {
      continue;
    }

    steps.add(
      TripRouteStepData(
        instruction: instruction,
        duration: step['duration']?.toString().trim().isNotEmpty == true
            ? step['duration'].toString().trim()
            : '--',
        distance: step['distance']?.toString().trim().isNotEmpty == true
            ? step['distance'].toString().trim()
            : '--',
        startLocation: extractTripStepPoint(step['startLocation']),
        endLocation: extractTripStepPoint(step['endLocation']),
      ),
    );
  }

  return steps;
}

class TripRouteResponseData {
  const TripRouteResponseData({
    required this.polylinePoints,
    required this.totalDistance,
    required this.totalDuration,
    required this.nextInstruction,
    required this.nextInstructionDuration,
    required this.steps,
  });

  final List<LatLng> polylinePoints;
  final String totalDistance;
  final String totalDuration;
  final String nextInstruction;
  final String nextInstructionDuration;
  final List<TripRouteStepData> steps;
}

class TripRouteStepData {
  const TripRouteStepData({
    required this.instruction,
    required this.duration,
    required this.distance,
    this.startLocation,
    this.endLocation,
  });

  final String instruction;
  final String duration;
  final String distance;
  final LatLng? startLocation;
  final LatLng? endLocation;
}

// ==================== Pure Map/Route Helpers ====================

/// Calculate the geographic center (centroid) of a list of [points].
LatLng calculateMapCenter(List<LatLng> points) {
  assert(points.isNotEmpty, 'Cannot calculate center of empty point list');
  var sumLat = 0.0;
  var sumLng = 0.0;
  for (final point in points) {
    sumLat += point.latitude;
    sumLng += point.longitude;
  }
  return LatLng(sumLat / points.length, sumLng / points.length);
}

/// Find the index of the nearest point in [points] to [current].
int nearestRoutePointIndex(
  LatLng current,
  List<LatLng> points, {
  Distance distanceCalculator = const Distance(),
}) {
  var nearestIndex = 0;
  var minDistance = double.infinity;
  for (var i = 0; i < points.length; i++) {
    final d = distanceCalculator.as(LengthUnit.Meter, current, points[i]);
    if (d < minDistance) {
      minDistance = d;
      nearestIndex = i;
    }
  }
  return nearestIndex;
}

/// Calculate the total length of a polyline in meters.
double polylineLengthMeters(
  List<LatLng> points, {
  Distance distanceCalculator = const Distance(),
}) {
  if (points.length < 2) return 0;
  var total = 0.0;
  for (var i = 0; i < points.length - 1; i++) {
    total += distanceCalculator.as(LengthUnit.Meter, points[i], points[i + 1]);
  }
  return total;
}

/// Calculate the minimum distance from [current] to any point on [polyline].
double distanceToPolylineMeters(
  LatLng current,
  List<LatLng> polyline, {
  Distance distanceCalculator = const Distance(),
}) {
  if (polyline.isEmpty) return double.infinity;
  var min = double.infinity;
  for (final point in polyline) {
    final d = distanceCalculator.as(LengthUnit.Meter, current, point);
    if (d < min) min = d;
  }
  return min;
}

/// Format a distance in meters to a human-readable string.
String formatMetersDisplay(double meters) {
  if (meters >= 1000) {
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }
  return '${meters.round()} m';
}

/// Format a [Duration] to a human-readable string like "1h 30m" or "5 mins".
String formatDurationDisplay(Duration d) {
  if (d.inHours >= 1) {
    final minutes = d.inMinutes % 60;
    return '${d.inHours}h ${minutes}m';
  }
  return '${d.inMinutes.clamp(1, 59)} mins';
}

/// Generate a waypoint label from an index (0 → "A", 1 → "B", etc.).
String waypointLabel(int index) => String.fromCharCode(65 + index);

