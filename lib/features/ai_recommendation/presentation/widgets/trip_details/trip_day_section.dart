import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/logging/app_logger.dart';
import 'package:rahhala_app/core/network/api_consumer.dart';
import 'package:rahhala_app/core/network/end_points.dart';
import 'package:rahhala_app/features/ai_recommendation/data/models/trip_plan_model.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/cubit/navigation_voice_cubit.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/expansion_tile_components.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/trip_details/trip_details_theme.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/trip_details/trip_location_tracking_service.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/trip_details/trip_navigation_voice_service.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/trip_details/trip_route_helpers.dart';

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
                        child: CachedNetworkImage(
                          imageUrl: act.image!,
                          width: double.infinity,
                          height: 180.h,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const SizedBox.shrink(),
                          errorWidget: (context, url, error) {
                            AppLogger.instance.w('Image load failed');
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                        start: 45.w, end: 12.w, bottom: 12.h),
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
  Future<TripRouteResponseData?>? _routeFuture;

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

  Future<TripRouteResponseData?> _fetchRouteData(List<LatLng> waypoints) async {
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
      final extractedSteps = extractTripRouteSteps(steps);
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
        return TripRouteResponseData(
          polylinePoints: waypoints,
          totalDistance: totalDistance,
          totalDuration: totalDuration,
          nextInstruction: instruction,
          nextInstructionDuration: instructionDuration,
          steps: extractedSteps,
        );
      }

      final decoded = decodeTripPolylinePoints(encoded);
      final points = decoded.length >= 2 ? decoded : waypoints;
      return TripRouteResponseData(
        polylinePoints: points,
        totalDistance: totalDistance,
        totalDuration: totalDuration,
        nextInstruction: instruction,
        nextInstructionDuration: instructionDuration,
        steps: extractedSteps,
      );
    } catch (error) {
      AppLogger.instance.w('Trip route API failed, using fallback polyline');
      return TripRouteResponseData(
        polylinePoints: waypoints,
        totalDistance: '--',
        totalDuration: '--',
        nextInstruction: 'Follow the route',
        nextInstructionDuration: '--',
        steps: const [],
      );
    }
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
            child: FutureBuilder<TripRouteResponseData?>(
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
                              builder: (_) =>
                                  BlocProvider<NavigationVoiceCubit>.value(
                                value: sl<NavigationVoiceCubit>(),
                                child: _FullScreenDayRouteMap(
                                  waypoints: _waypoints,
                                  routeData: routeData,
                                ),
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

  LatLng _calculateCenter(List<LatLng> points) => calculateMapCenter(points);
}

class _FullScreenDayRouteMap extends StatefulWidget {
  const _FullScreenDayRouteMap({
    required this.waypoints,
    required this.routeData,
  });

  final List<LatLng> waypoints;
  final TripRouteResponseData? routeData;

  @override
  State<_FullScreenDayRouteMap> createState() => _FullScreenDayRouteMapState();
}

class _FullScreenDayRouteMapState extends State<_FullScreenDayRouteMap> {
  static const double _offRouteThresholdMeters = 90;
  static const Color _plannedRouteColor = Color(0xFF8D7358);
  static const Color _currentLegColor = Color(0xFF1565C0);

  final Distance _distance = const Distance();
  final MapController _mapController = MapController();

  // TODO: Consider injecting these services via constructor or GetIt
  // for deeper testability improvements in a future refactor.
  final TripNavigationVoiceService _voiceService = TripNavigationVoiceService();
  final TripLocationTrackingService _locationService =
      TripLocationTrackingService();

  late List<LatLng> _routePoints;
  late List<LatLng> _plannedRoutePoints;
  late String _totalDistance;
  late String _remainingDistance;
  late String _eta;
  late String _nextInstruction;
  late String _nextInstructionDuration;

  List<TripRouteStepData> _steps = const [];
  Position? _currentPosition;

  bool _isNavigating = false;
  bool _isFollowingUser = false;
  bool _isRecentering = false;
  bool _isRerouting = false;
  bool _lockRouteToWaypoints = false;
  bool _isAdvancingLeg = false;
  int _activeLegStartIndex = 0;
  int _currentStepIndex = 0;

  @override
  void initState() {
    super.initState();
    _hydrateFromInitialRoute();
    _voiceService.configure();
  }

  @override
  void dispose() {
    _locationService.dispose();
    _voiceService.dispose();
    super.dispose();
  }

  void _hydrateFromInitialRoute() {
    final routeData = widget.routeData;
    _plannedRoutePoints = routeData?.polylinePoints ?? widget.waypoints;
    _routePoints = routeData?.polylinePoints ?? widget.waypoints;
    _totalDistance = routeData?.totalDistance ?? '--';
    _remainingDistance = routeData?.totalDistance ?? '--';
    _eta = routeData?.totalDuration ?? '--';
    _nextInstruction = routeData?.nextInstruction ?? 'Follow the route';
    _nextInstructionDuration = routeData?.nextInstructionDuration ?? '--';
    _steps = routeData?.steps ?? const [];
  }

  LatLng _calculateCenter(List<LatLng> points) => calculateMapCenter(points);

  LatLng _centerFromCurrentRoute() {
    if (_routePoints.isEmpty) {
      return widget.waypoints.isNotEmpty
          ? _calculateCenter(widget.waypoints)
          : const LatLng(30.0444, 31.2357);
    }
    return _calculateCenter(_routePoints);
  }

  Future<Position?> _requestCurrentPosition() async {
    return _locationService.getCurrentLocation(
      onServiceDisabled: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('GPS is disabled. Please enable it.')),
          );
        }
      },
      onPermissionDenied: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied.')),
          );
        }
      },
      onPermissionDeniedForever: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission denied permanently.'),
            ),
          );
        }
      },
    );
  }

  void _ensureLocationStream() {
    if (_locationService.isTracking) return;

    _locationService.startTracking(
      onUpdate: _onLocationUpdate,
      onError: (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Unable to read live location updates.')),
        );
      },
    );
  }

  Future<void> _animateCameraTo(
    LatLng target, {
    double? zoom,
    Duration duration = const Duration(milliseconds: 550),
  }) async {
    final startCenter = _mapController.camera.center;
    final startZoom = _mapController.camera.zoom;
    final endZoom = zoom ?? startZoom;
    final totalMs = math.max(1, duration.inMilliseconds);
    const frameMs = 16;
    final steps = math.max(1, totalMs ~/ frameMs);

    for (var i = 1; i <= steps; i++) {
      final t = i / steps;
      final eased = Curves.easeInOut.transform(t);
      final lat = startCenter.latitude +
          (target.latitude - startCenter.latitude) * eased;
      final lng = startCenter.longitude +
          (target.longitude - startCenter.longitude) * eased;
      final z = startZoom + (endZoom - startZoom) * eased;
      _mapController.move(LatLng(lat, lng), z);
      await Future<void>.delayed(const Duration(milliseconds: frameMs));
    }
  }

  Future<void> _onRecenterPressed() async {
    if (_isRecentering) {
      return;
    }

    setState(() => _isRecentering = true);
    try {
      final position = await _requestCurrentPosition();
      if (position == null) {
        return;
      }

      _currentPosition = position;
      _isFollowingUser = true;
      _ensureLocationStream();
      await _animateCameraTo(
        LatLng(position.latitude, position.longitude),
        zoom: 16,
      );
    } finally {
      if (mounted) {
        setState(() => _isRecentering = false);
      }
    }
  }

  Future<void> _onToggleNavigation() async {
    if (_isNavigating) {
      _stopNavigation();
      return;
    }

    if (widget.waypoints.length < 2) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Cannot start navigation without destination.')),
        );
      }
      return;
    }

    final position = await _requestCurrentPosition();
    if (position == null) {
      return;
    }

    final currentPoint = LatLng(position.latitude, position.longitude);
    final destination = widget.waypoints.first;

    _activeLegStartIndex = -1;

    final routeData = await _fetchRouteForNavigation(
      currentPoint,
      destination,
    );

    if (routeData == null || routeData.polylinePoints.length < 2) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('No valid route found. Check internet and try again.')),
        );
      }
      return;
    }

    _ensureLocationStream();
    _currentPosition = position;

    setState(() {
      _isNavigating = true;
      _isFollowingUser = true;
      _lockRouteToWaypoints = true;
      _routePoints = routeData.polylinePoints;
      _steps = routeData.steps;
      _totalDistance = routeData.totalDistance;
      _remainingDistance = routeData.totalDistance;
      _eta = routeData.totalDuration;
      _currentStepIndex = 0;
      _nextInstruction = routeData.nextInstruction;
      _nextInstructionDuration = routeData.nextInstructionDuration;
    });

    await _animateCameraTo(
      currentPoint,
      zoom: 16,
    );
    await _maybeSpeakCurrentInstruction();
  }

  void _stopNavigation() {
    _voiceService.stop();
    _locationService.stopTracking();
    setState(() {
      _isNavigating = false;
      _isFollowingUser = false;
      _isRerouting = false;
      _lockRouteToWaypoints = false;
      _isAdvancingLeg = false;
      _activeLegStartIndex = 0;
      _currentStepIndex = 0;
      _hydrateFromInitialRoute();
    });
  }

  String _pointLabel(int index) => waypointLabel(index);

  Future<void> _advanceToNextLeg() async {
    if (!_isNavigating || _isAdvancingLeg) {
      return;
    }

    final isFinalLeg = _activeLegStartIndex >= widget.waypoints.length - 2;
    if (isFinalLeg) {
      _stopNavigation();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have reached your destination.')),
        );
      }
      return;
    }

    _isAdvancingLeg = true;
    final nextLegStartIndex =
        _activeLegStartIndex < 0 ? 0 : _activeLegStartIndex + 1;
    final from = widget.waypoints[nextLegStartIndex];
    final to = widget.waypoints[nextLegStartIndex + 1];

    final routeData = await _fetchRouteForNavigation(from, to);

    if (!_isNavigating || !mounted) {
      _isAdvancingLeg = false;
      return;
    }

    if (routeData == null || routeData.polylinePoints.length < 2) {
      _isAdvancingLeg = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not load next leg route. Please try again.'),
        ),
      );
      return;
    }

    _activeLegStartIndex = nextLegStartIndex;
    setState(() {
      _routePoints = routeData.polylinePoints;
      _steps = routeData.steps;
      _totalDistance = routeData.totalDistance;
      _remainingDistance = routeData.totalDistance;
      _eta = routeData.totalDuration;
      _currentStepIndex = 0;
      _nextInstruction = routeData.nextInstruction;
      _nextInstructionDuration = routeData.nextInstructionDuration;
    });

    _isAdvancingLeg = false;
    await _maybeSpeakCurrentInstruction();

    if (mounted) {
      final fromLabel = _pointLabel(_activeLegStartIndex);
      final toLabel = _pointLabel(_activeLegStartIndex + 1);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reached $fromLabel. Continuing to $toLabel.')),
      );
    }
  }

  Future<TripRouteResponseData?> _fetchRouteForNavigation(
    LatLng from,
    LatLng to,
  ) async {
    try {
      final api = sl<ApiConsumer>();
      final response = await api.post(
        EndPoints.getActivityRoute,
        data: {
          'travelMode': 'driving',
          'waypoints': [
            {'lat': from.latitude, 'lng': from.longitude, 'order': 1},
            {'lat': to.latitude, 'lng': to.longitude, 'order': 2},
          ],
        },
      );

      if (response is! Map<String, dynamic>) {
        return null;
      }

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
    } catch (e) {
      AppLogger.instance.w('Navigation route fetch failed', error: e);
      return null;
    }
  }

  void _onLocationUpdate(Position position) {
    _currentPosition = position;
    if (!_isNavigating) {
      if (_isFollowingUser) {
        unawaited(
          _animateCameraTo(
            LatLng(position.latitude, position.longitude),
            zoom: 16,
          ),
        );
      }
      setState(() {});
      return;
    }

    final current = LatLng(position.latitude, position.longitude);
    _updateNavigationMetrics(current, speedMps: position.speed);

    if (_isFollowingUser) {
      unawaited(_animateCameraTo(current, zoom: 16));
    }

    final distanceFromRoute = distanceToPolylineMeters(current, _routePoints,
        distanceCalculator: _distance);
    if (!_lockRouteToWaypoints &&
        distanceFromRoute > _offRouteThresholdMeters &&
        !_isRerouting) {
      unawaited(_recalculateRouteFromCurrent(current));
    }

    setState(() {});
  }

  Future<void> _recalculateRouteFromCurrent(LatLng current) async {
    if (_isRerouting || widget.waypoints.isEmpty) {
      return;
    }

    _isRerouting = true;
    final destination = widget.waypoints.last;
    final routeData = await _fetchRouteForNavigation(current, destination);
    _isRerouting = false;

    if (routeData == null || !_isNavigating || !mounted) {
      return;
    }

    setState(() {
      _routePoints = routeData.polylinePoints;
      _steps = routeData.steps;
      _totalDistance = routeData.totalDistance;
      _remainingDistance = routeData.totalDistance;
      _eta = routeData.totalDuration;
      _currentStepIndex = 0;
      _nextInstruction = routeData.nextInstruction;
      _nextInstructionDuration = routeData.nextInstructionDuration;
    });

    unawaited(_maybeSpeakCurrentInstruction());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Route recalculated.')),
    );
  }

  void _updateNavigationMetrics(LatLng current, {required double speedMps}) {
    if (_routePoints.length < 2) {
      return;
    }

    final nearestIndex = nearestRoutePointIndex(current, _routePoints,
        distanceCalculator: _distance);
    final remainingMeters = polylineLengthMeters(
        _routePoints.sublist(nearestIndex),
        distanceCalculator: _distance);
    final totalMeters =
        polylineLengthMeters(_routePoints, distanceCalculator: _distance);

    final safeSpeed = speedMps > 1.2 ? speedMps : 13.9;
    final etaSeconds = (remainingMeters / safeSpeed).round();

    _remainingDistance = formatMetersDisplay(remainingMeters);
    _totalDistance = formatMetersDisplay(totalMeters);
    _eta = formatDurationDisplay(Duration(seconds: etaSeconds));

    if (_steps.isNotEmpty) {
      final nextStepIndex = _resolveStepIndex(current);
      if (nextStepIndex != _currentStepIndex) {
        _currentStepIndex = nextStepIndex;
        unawaited(_maybeSpeakCurrentInstruction());
      }
      final step = _steps[_currentStepIndex.clamp(0, _steps.length - 1)];
      _nextInstruction = step.instruction;
      _nextInstructionDuration = step.duration;
    }

    if (remainingMeters <= 30) {
      unawaited(_advanceToNextLeg());
    }
  }

  int _resolveStepIndex(LatLng current) {
    var index = _currentStepIndex;
    while (index < _steps.length - 1) {
      final end = _steps[index].endLocation;
      if (end == null) {
        break;
      }

      if (_distanceInMeters(current, end) <= 45) {
        index += 1;
      } else {
        break;
      }
    }
    return index;
  }

  double _distanceInMeters(LatLng a, LatLng b) {
    return _distance.as(LengthUnit.Meter, a, b);
  }

  Future<void> _maybeSpeakCurrentInstruction() async {
    final isMuted = context.read<NavigationVoiceCubit>().isMuted;
    if (isMuted || !_isNavigating || _nextInstruction.trim().isEmpty) {
      return;
    }

    await _voiceService.speak(_nextInstruction);
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentPosition;
    final center = current != null
        ? LatLng(current.latitude, current.longitude)
        : _centerFromCurrentRoute();
    final remainingRoute = _routePoints.length >= 2 && current != null
        ? _routePoints.sublist(nearestRoutePointIndex(center, _routePoints,
            distanceCalculator: _distance))
        : _routePoints;
    final routeColor =
        _activeLegStartIndex < 0 ? _currentLegColor : _plannedRouteColor;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 10,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture && _isFollowingUser) {
                  setState(() => _isFollowingUser = false);
                }
              },
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
              if (_isNavigating && _plannedRoutePoints.length > 1)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _plannedRoutePoints,
                      color: _plannedRouteColor.withValues(alpha: 0.55),
                      strokeWidth: 6,
                    ),
                  ],
                ),
              if (_routePoints.length > 1)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: Colors.black.withValues(alpha: 0.22),
                      strokeWidth: 7,
                    ),
                    Polyline(
                      points: remainingRoute.length >= 2
                          ? remainingRoute
                          : _routePoints,
                      color: routeColor,
                      strokeWidth: 5,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  ...widget.waypoints.asMap().entries.map((entry) {
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
                  }),
                  if (current != null)
                    Marker(
                      point: LatLng(current.latitude, current.longitude),
                      width: 24.w,
                      height: 24.h,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1565C0),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                      ),
                    ),
                  if (_isNavigating && _steps.isNotEmpty)
                    if (_steps[_currentStepIndex.clamp(0, _steps.length - 1)]
                            .endLocation !=
                        null)
                      Marker(
                        point: _steps[
                                _currentStepIndex.clamp(0, _steps.length - 1)]
                            .endLocation!,
                        width: 22.w,
                        height: 22.h,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE65100),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                ],
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
                            _nextInstruction,
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
                            'Continue for $_nextInstructionDuration',
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
            child: BlocBuilder<NavigationVoiceCubit, bool>(
              builder: (context, isMuted) {
                return Column(
                  children: [
                    _RoundMapActionIcon(
                      icon: _isRecentering
                          ? Icons.gps_fixed
                          : Icons.my_location_outlined,
                      onTap: _onRecenterPressed,
                      tooltip: 'Recenter',
                    ),
                    _RoundMapActionIcon(
                      icon: isMuted
                          ? Icons.volume_off_outlined
                          : Icons.volume_up_outlined,
                      onTap: () async {
                        final voiceCubit =
                            this.context.read<NavigationVoiceCubit>();
                        voiceCubit.toggleMute();
                        final mutedNow = voiceCubit.isMuted;

                        if (mutedNow) {
                          await _voiceService.stop();
                        } else {
                          await _maybeSpeakCurrentInstruction();
                        }
                        if (!mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text(
                              mutedNow
                                  ? 'Voice instructions muted'
                                  : 'Voice instructions enabled',
                            ),
                            duration: const Duration(milliseconds: 1200),
                          ),
                        );
                      },
                      tooltip: isMuted ? 'Unmute' : 'Mute',
                    ),
                    _RoundMapActionIcon(
                      icon: _isNavigating
                          ? Icons.stop_circle_outlined
                          : Icons.navigation_outlined,
                      onTap: _onToggleNavigation,
                      tooltip: _isNavigating ? 'End Trip' : 'Start Navigation',
                    ),
                  ],
                );
              },
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _BottomStatCard(
                          icon: Icons.pin_drop_outlined,
                          value: _totalDistance,
                          label: 'Total Distance',
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _BottomStatCard(
                          icon: Icons.near_me_outlined,
                          value: _remainingDistance,
                          label: 'Remaining',
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _BottomStatCard(
                          icon: Icons.access_time,
                          value: _eta,
                          label: 'ETA',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: brownTextColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                      ),
                      onPressed: _onToggleNavigation,
                      icon: Icon(
                        _isNavigating
                            ? Icons.stop_circle_outlined
                            : Icons.navigation_outlined,
                      ),
                      label: Text(
                        _isNavigating ? 'End Trip' : 'Start Navigation',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isRerouting)
            Positioned(
              top: 108.h,
              left: 16.w,
              right: 16.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'Rerouting...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RoundMapActionIcon extends StatelessWidget {
  const _RoundMapActionIcon({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.9),
      ),
      child: Tooltip(
        message: tooltip,
        child: IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: brownTextColor),
        ),
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
