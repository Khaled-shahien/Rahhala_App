import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/logging/app_logger.dart';
import 'package:rahhala_app/core/network/api_consumer.dart';
import 'package:rahhala_app/core/network/end_points.dart';
import 'package:rahhala_app/features/ai_recommendation/data/models/trip_plan_model.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/expansion_tile_components.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/trip_details/trip_details_theme.dart';

class TripDaySection extends StatelessWidget {
  const TripDaySection({
    super.key,
    required this.day,
  });

  final DailyPlan day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cleanCost = day.estimatedDayCost.replaceAll('EGP', '').trim();

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark ? Colors.white10 : lightBorderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomExpansionTile(
        minTileHeight: 74.h,
        tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Day ${day.day}',
              style: TextStyle(
                color: isDark ? theme.primaryColorLight : lightBorderColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              day.title,
              style: TextStyle(
                color: isDark ? Colors.white : primaryTextColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        trailing: CostBadge(
          cost: cleanCost,
          backgroundColor: isDark
              ? theme.primaryColor.withValues(alpha: 0.2)
              : costBadgeBgColor,
          textColor: isDark ? Colors.white : primaryTextColor,
          borderColor:
              isDark ? Colors.white.withValues(alpha: 0.2) : lightBorderColor,
          iconColor: isDark ? theme.primaryColorLight : lightBorderColor,
        ),
        iconColor: isDark ? Colors.white : primaryTextColor,
        collapsedIconColor: isDark ? Colors.white70 : primaryTextColor,
        children: [_DayDetailsContent(activities: day.activities)],
      ),
    );
  }
}

class _DayDetailsContent extends StatelessWidget {
  const _DayDetailsContent({required this.activities});

  final List<Activity> activities;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.all(12.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : locationCardBackgroundColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _DayRouteMapSection(activities: activities),
          SizedBox(height: 12.h),
          ...activities.asMap().entries.map((entry) {
            final index = entry.key;
            final act = entry.value;
            return TimelineWrapper(
              isFirst: index == 0,
              isLast: index == activities.length - 1,
              child: CustomExpansionTile(
                minTileHeight: 86.h,
                tilePadding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                leading: NumberCircle(
                  number: index + 1,
                  backgroundColor: timelineColor,
                  textColor: Colors.white,
                ),
                title: Row(
                  children: [
                    Flexible(
                      child: Text(
                        act.place,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? Colors.white : primaryTextColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                iconColor: isDark ? Colors.white70 : primaryTextColor,
                collapsedIconColor: isDark ? Colors.white70 : primaryTextColor,
                children: [
                  if (act.image != null && act.image!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.network(
                          act.image!,
                          width: double.infinity,
                          height: 180.h,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            AppLogger.instance.w('Image load failed');
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                  Padding(
                    padding:
                        EdgeInsets.only(left: 45.w, right: 12.w, bottom: 12.h),
                    child: Text(
                      act.description,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : primaryTextColor,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          _TransportationSection(activities: activities),
        ],
      ),
    );
  }
}

class _DayRouteMapSection extends StatefulWidget {
  const _DayRouteMapSection({required this.activities});

  final List<Activity> activities;

  @override
  State<_DayRouteMapSection> createState() => _DayRouteMapSectionState();
}

class _DayRouteMapSectionState extends State<_DayRouteMapSection> {
  static final RegExp _coordPattern = RegExp(
    r'lat\s*:\s*([-+]?\d+(?:\.\d+)?)\s*,\s*lng\s*:\s*([-+]?\d+(?:\.\d+)?)',
    caseSensitive: false,
  );

  late final List<LatLng> _waypoints;
  Future<_RouteResponseData?>? _routeFuture;

  @override
  void initState() {
    super.initState();
    _waypoints = widget.activities
        .map((a) => _parseCoordinates(a.coordinates))
        .whereType<LatLng>()
        .toList();

    if (_waypoints.length >= 2) {
      _routeFuture = _fetchRouteData(_waypoints);
    }
  }

  LatLng? _parseCoordinates(String? rawCoordinates) {
    if (rawCoordinates == null || rawCoordinates.trim().isEmpty) {
      return null;
    }

    final match = _coordPattern.firstMatch(rawCoordinates);
    if (match == null) {
      return null;
    }

    final lat = double.tryParse(match.group(1) ?? '');
    final lng = double.tryParse(match.group(2) ?? '');
    if (lat == null || lng == null) {
      return null;
    }

    return LatLng(lat, lng);
  }

  Future<_RouteResponseData?> _fetchRouteData(List<LatLng> waypoints) async {
    try {
      final api = sl<ApiConsumer>();
      final response = await api.post(
        EndPoints.getActivityRoute,
        data: {
          'travelMode': 'driving',
          'waypoints': waypoints.asMap().entries.map((entry) {
            return {
              'lat': entry.value.latitude,
              'lng': entry.value.longitude,
              'order': entry.key + 1,
            };
          }).toList(),
        },
      );

      if (response is! Map<String, dynamic>) {
        return null;
      }

      final canDrawRoute = response['canDrawRoute'] == true;
      final encoded = response['polyline']?.toString();
      final totalDistance = response['totalDistance']?.toString() ?? '--';
      final totalDuration = response['totalDuration']?.toString() ?? '--';

      String instruction = 'Follow the route';
      String instructionDuration = totalDuration;
      final steps = response['steps'];
      if (steps is List &&
          steps.isNotEmpty &&
          steps.first is Map<String, dynamic>) {
        final firstStep = steps.first as Map<String, dynamic>;
        final rawInstruction = firstStep['instruction']?.toString();
        final stepDuration = firstStep['duration']?.toString();
        if (rawInstruction != null && rawInstruction.trim().isNotEmpty) {
          instruction = rawInstruction.trim();
        }
        if (stepDuration != null && stepDuration.trim().isNotEmpty) {
          instructionDuration = stepDuration.trim();
        }
      }

      if (!canDrawRoute || encoded == null || encoded.isEmpty) {
        return _RouteResponseData(
          polylinePoints: waypoints,
          totalDistance: totalDistance,
          totalDuration: totalDuration,
          nextInstruction: instruction,
          nextInstructionDuration: instructionDuration,
        );
      }

      final decoded = _decodePolyline(encoded);
      final points = decoded.length >= 2 ? decoded : waypoints;
      return _RouteResponseData(
        polylinePoints: points,
        totalDistance: totalDistance,
        totalDuration: totalDuration,
        nextInstruction: instruction,
        nextInstructionDuration: instructionDuration,
      );
    } catch (error) {
      AppLogger.instance.w('Trip route API failed, using fallback polyline');
      return _RouteResponseData(
        polylinePoints: waypoints,
        totalDistance: '--',
        totalDuration: '--',
        nextInstruction: 'Follow the route',
        nextInstructionDuration: '--',
      );
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_waypoints.isEmpty) {
      return const SizedBox.shrink();
    }

    final center = _calculateCenter(_waypoints);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TripDetailsStrings.dayRoute,
          style: TextStyle(
            color: isDark ? Colors.white : primaryTextColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: SizedBox(
            width: double.infinity,
            height: 200.h,
            child: FutureBuilder<_RouteResponseData?>(
              future: _routeFuture,
              builder: (context, snapshot) {
                final routeData = snapshot.data;
                final polylinePoints = routeData?.polylinePoints ?? _waypoints;

                return Stack(
                  children: [
                    FlutterMap(
                      options: MapOptions(
                        initialCenter: center,
                        initialZoom: 10,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.drag |
                              InteractiveFlag.pinchZoom |
                              InteractiveFlag.doubleTapZoom,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.rahhala.app',
                        ),
                        if (polylinePoints.length > 1)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: polylinePoints,
                                color: const Color(0xFF8D7358),
                                strokeWidth: 4,
                              ),
                            ],
                          ),
                        MarkerLayer(
                          markers: _waypoints.asMap().entries.map((entry) {
                            final index = entry.key;
                            final point = entry.value;
                            final isFirst = index == 0;
                            return Marker(
                              point: point,
                              width: 34.w,
                              height: 34.h,
                              child: _MapPointMarker(
                                label: String.fromCharCode(65 + index),
                                color: isFirst
                                    ? Colors.red
                                    : const Color(0xFF009688),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 10.h,
                      right: 10.w,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => _FullScreenDayRouteMap(
                                waypoints: _waypoints,
                                routeData: routeData,
                              ),
                            ),
                          ),
                          borderRadius: BorderRadius.circular(24.r),
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.open_in_full,
                              size: 18.sp,
                              color: brownTextColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  LatLng _calculateCenter(List<LatLng> points) {
    var sumLat = 0.0;
    var sumLng = 0.0;
    for (final point in points) {
      sumLat += point.latitude;
      sumLng += point.longitude;
    }
    return LatLng(sumLat / points.length, sumLng / points.length);
  }
}

class _RouteResponseData {
  const _RouteResponseData({
    required this.polylinePoints,
    required this.totalDistance,
    required this.totalDuration,
    required this.nextInstruction,
    required this.nextInstructionDuration,
  });

  final List<LatLng> polylinePoints;
  final String totalDistance;
  final String totalDuration;
  final String nextInstruction;
  final String nextInstructionDuration;
}

class _FullScreenDayRouteMap extends StatelessWidget {
  const _FullScreenDayRouteMap({
    required this.waypoints,
    required this.routeData,
  });

  final List<LatLng> waypoints;
  final _RouteResponseData? routeData;

  @override
  Widget build(BuildContext context) {
    final polylinePoints = routeData?.polylinePoints ?? waypoints;
    final center = _calculateCenter(waypoints);

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 10,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.drag |
                    InteractiveFlag.pinchZoom |
                    InteractiveFlag.doubleTapZoom,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.rahhala.app',
              ),
              if (polylinePoints.length > 1)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: polylinePoints,
                      color: const Color(0xFF8D7358),
                      strokeWidth: 5,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: waypoints.asMap().entries.map((entry) {
                  final index = entry.key;
                  final point = entry.value;
                  final isFirst = index == 0;
                  return Marker(
                    point: point,
                    width: 36.w,
                    height: 36.h,
                    child: _MapPointMarker(
                      label: String.fromCharCode(65 + index),
                      color: isFirst ? const Color(0xFF8D7358) : Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF8D7358),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            routeData?.nextInstruction ?? 'Follow the route',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: brownTextColor,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Continue for ${routeData?.nextInstructionDuration ?? '--'}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: brownTextColor.withValues(alpha: 0.75),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 14.w,
            top: 220.h,
            child: const Column(
              children: [
                _RoundMapActionIcon(icon: Icons.my_location_outlined),
                _RoundMapActionIcon(icon: Icons.volume_up_outlined),
                _RoundMapActionIcon(icon: Icons.navigation_outlined),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(8.w, 14.h, 8.w, 20.h),
              decoration: BoxDecoration(
                color: const Color(0xFF8D7358),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.r),
                  topRight: Radius.circular(18.r),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _BottomStatCard(
                      icon: Icons.pin_drop_outlined,
                      value: routeData?.totalDistance ?? '--',
                      label: 'Total Distance',
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _BottomStatCard(
                      icon: Icons.near_me_outlined,
                      value: routeData?.totalDistance ?? '--',
                      label: 'Remaining',
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _BottomStatCard(
                      icon: Icons.access_time,
                      value: routeData?.totalDuration ?? '--',
                      label: 'ETA',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LatLng _calculateCenter(List<LatLng> points) {
    var sumLat = 0.0;
    var sumLng = 0.0;
    for (final point in points) {
      sumLat += point.latitude;
      sumLng += point.longitude;
    }
    return LatLng(sumLat / points.length, sumLng / points.length);
  }
}

class _RoundMapActionIcon extends StatelessWidget {
  const _RoundMapActionIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.9),
      ),
      child: IconButton(
        onPressed: () {},
        icon: Icon(icon, color: brownTextColor),
      ),
    );
  }
}

class _BottomStatCard extends StatelessWidget {
  const _BottomStatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(7.w),
            decoration: const BoxDecoration(
              color: Color(0xFFF0E6D9),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16.sp, color: const Color(0xFFB56D3A)),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              color: brownTextColor,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              color: brownTextColor.withValues(alpha: 0.7),
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPointMarker extends StatelessWidget {
  const _MapPointMarker({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: Colors.black,
          fontSize: 12.sp,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _TransportationSection extends StatelessWidget {
  const _TransportationSection({required this.activities});

  final List<Activity> activities;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allTransports = activities.expand((a) => a.transportation).toList();

    if (allTransports.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
          child: Row(
            children: [
              Icon(
                Icons.directions_car_outlined,
                size: 18.sp,
                color: isDark ? Colors.white70 : brownTextColor,
              ),
              SizedBox(width: 8.w),
              Text(
                TripDetailsStrings.transportRoutes,
                style: TextStyle(
                  color: isDark ? Colors.white : brownTextColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                allTransports.map((t) => _RouteRow(transport: t)).toList(),
          ),
        ),
      ],
    );
  }
}

class _RouteRow extends StatelessWidget {
  const _RouteRow({required this.transport});
  final Transportation transport;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          _RoutePill(text: transport.from),
          _RouteArrow(),
          _RoutePill(text: transport.method, isMethod: true),
          _RouteArrow(),
          _RoutePill(text: transport.to),
        ],
      ),
    );
  }
}

class _RoutePill extends StatelessWidget {
  const _RoutePill({required this.text, this.isMethod = false});
  final String text;
  final bool isMethod;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color:
              isDark ? Colors.white24 : lightBorderColor.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isMethod) ...[
            Icon(Icons.directions_car,
                size: 12.sp, color: isDark ? Colors.white70 : brownTextColor),
            SizedBox(width: 4.w),
          ],
          Text(
            text,
            style: TextStyle(
              color: isDark ? Colors.white : brownTextColor,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteArrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Icon(Icons.trending_flat, color: arrowColor, size: 18.sp),
    );
  }
}

class TimelineWrapper extends StatelessWidget {
  const TimelineWrapper({
    super.key,
    required this.child,
    this.isFirst = false,
    this.isLast = false,
  });

  final Widget child;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40.w,
            child: Column(
              children: [
                Container(
                  height: 25.h,
                  width: 2,
                  color: isFirst ? Colors.transparent : timelineColor,
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : timelineColor,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
