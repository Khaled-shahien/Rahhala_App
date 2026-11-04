import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:shimmer/shimmer.dart';
import 'package:rahhala_app/core/constants/app_colors.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/logging/app_logger.dart';
import 'package:rahhala_app/core/network/api_consumer.dart';
import 'package:rahhala_app/core/network/end_points.dart';
import 'package:rahhala_app/core/widgets/background_decorator.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/expansion_tile_components.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/trip_details/trip_route_helpers.dart';
import 'package:rahhala_app/features/trip_history/data/models/trip_history_model.dart';
import 'package:rahhala_app/features/trip_history/domain/cubits/trip_history_cubit.dart';
import 'package:rahhala_app/features/trip_history/domain/cubits/trip_history_state.dart';

class TripHistoryDetailScreen extends StatelessWidget {
  final String tripId;

  const TripHistoryDetailScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TripHistoryCubit(repository: sl())..loadTripDetail(tripId),
      child: const _TripHistoryDetailView(),
    );
  }
}

class _TripHistoryDetailView extends StatelessWidget {
  const _TripHistoryDetailView();

  // ─── Theme Helpers ────────────────────────────────────────────────────────
  Color _primaryText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : AppColors.darkBrown;

  Color _lightBorder(BuildContext context) => AppColors.lightBrown;

  Color _costBadgeBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2C2C2C)
          : AppColors.costBadgeBackground;

  Color _screenBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF121212)
          : AppColors.screenBackground;

  Color _cardBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E1E1E)
          : Colors.white;

  Color _chipBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2A2A2A)
          : AppColors.lightBrown.withValues(alpha: 0.06);

  Color _chipBorder(BuildContext context) =>
      AppColors.lightBrown.withValues(alpha: 0.2);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripHistoryCubit, TripHistoryState>(
      builder: (context, state) {
        if (state is TripHistoryDetailLoading) {
          return _buildLoading(context);
        } else if (state is TripHistoryDetailLoaded) {
          return _buildContent(context, state.response.trip);
        } else if (state is TripHistoryDetailFailure) {
          return _buildError(context, state.message);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoading(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: _screenBg(context),
      body: Shimmer.fromColors(
        baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
        highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
        child: Column(
          children: [
            Container(height: 380.h, color: _cardBg(context)),
            SizedBox(height: 16.h),
            ...List.generate(
              3,
              (_) => Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                height: 80.h,
                decoration: BoxDecoration(
                  color: _cardBg(context),
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Scaffold(
      backgroundColor: _screenBg(context),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60.sp, color: Colors.grey.shade400),
            SizedBox(height: 16.h),
            Text(message,
                style:
                    TextStyle(fontSize: 15.sp, color: _primaryText(context))),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text('Go Back',
                  style: TextStyle(color: Colors.white, fontSize: 15.sp)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TripHistoryDetail trip) {
    return Scaffold(
      backgroundColor: _screenBg(context),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        top: false,
        child: BackgroundDecorator(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, trip),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      SizedBox(height: 16.h),
                      ...trip.days.map((day) => _buildDayTile(context, day)),
                      SizedBox(height: 12.h),
                      if (trip.budgetTips.isNotEmpty)
                        _buildSimpleTile(
                          context: context,
                          icon: Icons.lightbulb_outline,
                          title: 'Budget tips',
                          content: trip.budgetTips,
                        ),
                      if (trip.travelTips.isNotEmpty)
                        _buildSimpleTile(
                          context: context,
                          icon: Icons.favorite_border,
                          title: 'Travel tips',
                          content: trip.travelTips,
                        ),
                      if (trip.emergencyContact.isNotEmpty)
                        _buildEmergencySection(
                          context: context,
                          emergencyContact: trip.emergencyContact,
                        ),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TripHistoryDetail trip) {
    final screenBg = _screenBg(context);
    return SizedBox(
      width: double.infinity,
      height: 380.h,
      child: Stack(
        children: [
          if (trip.countryImage != null && trip.countryImage!.isNotEmpty)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35.r),
                  bottomRight: Radius.circular(35.r),
                ),
                child: CachedNetworkImage(
                  imageUrl: trip.countryImage!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: const Color(0xFFF2E7D5),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: const Color(0xFFF2E7D5),
                  ),
                ),
              ),
            ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    screenBg.withValues(alpha: 0.15),
                    screenBg.withValues(alpha: 0.5),
                    screenBg,
                  ],
                  stops: const [0.0, 0.45, 0.7, 0.85, 1.0],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.2),
                  ],
                  stops: const [0.0, 0.5, 0.8, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: -20.h,
            right: -30.w,
            child: Image.asset(
              'assets/images/cover.png',
              width: 400.w,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12.h,
            left: 16.w,
            right: 16.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: const BoxDecoration(
                      color: Colors.black38,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20.sp),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: 20.w,
              end: 20.w,
              top: MediaQuery.of(context).padding.top + 20.h,
              bottom: 30.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                SizedBox(
                  width: 240.w,
                  child: Text(
                    'Every place, every moment\nchosen just for you.',
                    style: TextStyle(
                      color: const Color(0xFFF3E5D8),
                      fontSize: 25.sp,
                      fontWeight: FontWeight.w800,
                      height: 1.4,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 1.0),
                          offset: const Offset(0, 2),
                          blurRadius: 255,
                        ),
                        Shadow(
                          color: Colors.black.withValues(alpha: 1.0),
                          offset: const Offset(0, 4),
                          blurRadius: 100,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30.h),
                _buildPill(
                    context, Icons.location_on_outlined, trip.destination),
                SizedBox(height: 12.h),
                _buildPill(
                    context, null, 'Total cost: ${trip.totalEstimatedCost}',
                    isCost: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill(BuildContext context, IconData? icon, String text,
      {bool isCost = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.45)
            : const Color(0xFFF3E5D8).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(
          color: isDark ? Colors.white24 : const Color(0xFF8B6F5A),
          width: 1.4,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16.sp,
              color: isDark ? Colors.white70 : const Color(0xFF5C4634),
            ),
            SizedBox(width: 6.w),
          ],
          Text(
            text,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF5C4634),
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayTile(BuildContext context, TripHistoryDay day) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: _cardBg(context),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
            color: Colors.black.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.3
                    : 0.08),
            width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(
                  alpha: Theme.of(context).brightness == Brightness.dark
                      ? 0.3
                      : 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: CustomExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Day ${day.day}',
              style: TextStyle(
                color: _lightBorder(context),
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              day.title,
              style: TextStyle(
                color: _primaryText(context),
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        trailing: CostBadge(
          cost: day.estimatedDayCost,
          backgroundColor: _costBadgeBg(context),
          textColor: _primaryText(context),
          borderColor: _lightBorder(context),
          iconColor: _lightBorder(context),
        ),
        iconColor: _primaryText(context),
        collapsedIconColor: _primaryText(context),
        children: [_buildActivities(context, day.activities)],
      ),
    );
  }

  Widget _buildActivities(
      BuildContext context, List<TripHistoryActivity> activities) {
    return Container(
      margin: EdgeInsets.all(12.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: _costBadgeBg(context),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HistoryDayRouteMap(activities: activities),
          ...activities.asMap().entries.map((entry) {
            final i = entry.key;
            final act = entry.value;
            return TimelineWrapperHistory(
              isFirst: i == 0,
              isLast: i == activities.length - 1,
              timelineColor: _lightBorder(context),
              child: CustomExpansionTile(
                tilePadding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                leading: NumberCircle(
                  number: i + 1,
                  backgroundColor: _lightBorder(context),
                  textColor: Colors.white,
                ),
                title: Text(
                  act.place,
                  style: TextStyle(
                    color: _primaryText(context),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                iconColor: _primaryText(context),
                collapsedIconColor: _primaryText(context),
                children: [
                  if (act.image != null && act.image!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: CachedNetworkImage(
                        imageUrl: act.image!,
                        width: double.infinity,
                        height: 180.h,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const SizedBox.shrink(),
                        errorWidget: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  if (act.image != null && act.image!.isNotEmpty)
                    SizedBox(height: 12.h),
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                        start: 45.w, end: 12.w, bottom: 12.h),
                    child: Text(
                      act.description,
                      style: TextStyle(
                          color: _primaryText(context), fontSize: 13.sp),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSimpleTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: _cardBg(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white12
                : Colors.black12),
      ),
      child: CustomExpansionTile(
        tilePadding: EdgeInsets.all(16.w),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: _primaryText(context),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 4.h),
                  Text(
                    content,
                    style: TextStyle(
                        color: _primaryText(context).withValues(alpha: 0.7),
                        fontSize: 13.sp),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down,
                color: _primaryText(context), size: 20.sp),
          ],
        ),
        iconColor: Colors.transparent,
        collapsedIconColor: Colors.transparent,
        children: [
          Container(
            padding: EdgeInsetsDirectional.fromSTEB(16.w, 0, 16.w, 16.w),
            alignment: AlignmentDirectional.centerStart,
            child: Text(content,
                style:
                    TextStyle(fontSize: 13.sp, color: _primaryText(context))),
          )
        ],
      ),
    );
  }

  Widget _buildEmergencySection({
    required BuildContext context,
    required String emergencyContact,
  }) {
    if (emergencyContact.isEmpty) return const SizedBox.shrink();

    final contacts = emergencyContact.split(',');

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: _cardBg(context),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white12
                : Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.3
                    : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.emergency_outlined,
                      color: Colors.red.shade400, size: 24.sp),
                ),
                SizedBox(width: 16.w),
                Text(
                  'Emergency Contacts',
                  style: TextStyle(
                    color: _primaryText(context),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: contacts.map((contact) {
                final parts = contact.trim().split(':');
                final label = parts.isNotEmpty ? parts[0].trim() : '';
                final number = parts.length > 1 ? parts[1].trim() : '';
                return Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: _chipBg(context),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: _chipBorder(context), width: 1),
                  ),
                  child: IntrinsicWidth(
                    child: Row(
                      children: [
                        Icon(Icons.phone_outlined,
                            size: 14.sp, color: Colors.red.shade400),
                        SizedBox(width: 6.w),
                        Flexible(
                          child: Text(
                            '$label${number.isNotEmpty ? ': $number' : ''}',
                            style: TextStyle(
                              color: _primaryText(context),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryDayRouteMap extends StatefulWidget {
  const _HistoryDayRouteMap({required this.activities});

  final List<TripHistoryActivity> activities;

  @override
  State<_HistoryDayRouteMap> createState() => _HistoryDayRouteMapState();
}

class _HistoryDayRouteMapState extends State<_HistoryDayRouteMap> {
  static final RegExp _namedCoordinatesPattern = RegExp(
    r'lat\s*:\s*([-+]?\d+(?:\.\d+)?)\s*,\s*lng\s*:\s*([-+]?\d+(?:\.\d+)?)',
    caseSensitive: false,
  );
  static final RegExp _numberPattern = RegExp(r'[-+]?\d+(?:\.\d+)?');

  late final List<LatLng> _waypoints;
  Future<TripRouteResponseData?>? _routeFuture;

  @override
  void initState() {
    super.initState();
    _waypoints = widget.activities
        .map((activity) => _parseCoordinates(activity.coordinates))
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

    final namedMatch = _namedCoordinatesPattern.firstMatch(rawCoordinates);
    if (namedMatch != null) {
      return _latLngFromStrings(namedMatch.group(1), namedMatch.group(2));
    }

    final numbers = _numberPattern
        .allMatches(rawCoordinates)
        .map((match) => match.group(0))
        .whereType<String>()
        .toList();
    if (numbers.length < 2) {
      return null;
    }

    return _latLngFromStrings(numbers[0], numbers[1]);
  }

  LatLng? _latLngFromStrings(String? latitude, String? longitude) {
    final lat = double.tryParse(latitude ?? '');
    final lng = double.tryParse(longitude ?? '');
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

      final encoded = response['polyline']?.toString();
      final canDrawRoute = response['canDrawRoute'] == true;
      final decoded = canDrawRoute && encoded != null && encoded.isNotEmpty
          ? decodeTripPolylinePoints(encoded)
          : const <LatLng>[];
      final points = decoded.length >= 2 ? decoded : waypoints;

      return TripRouteResponseData(
        polylinePoints: points,
        totalDistance: response['totalDistance']?.toString() ?? '--',
        totalDuration: response['totalDuration']?.toString() ?? '--',
        nextInstruction: 'Follow the route',
        nextInstructionDuration: response['totalDuration']?.toString() ?? '--',
        steps: extractTripRouteSteps(response['steps']),
      );
    } catch (error, stackTrace) {
      AppLogger.instance.w(
        'Trip history route API failed, using waypoint route',
        error: error,
        stackTrace: stackTrace,
      );
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
    if (_waypoints.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.darkBrown;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "day's Route",
            style: TextStyle(
              color: textColor,
              fontSize: 16.sp,
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
                  return _HistoryRouteMapView(
                    waypoints: _waypoints,
                    routeData: routeData,
                    showOpenButton: true,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryRouteMapView extends StatelessWidget {
  const _HistoryRouteMapView({
    required this.waypoints,
    required this.routeData,
    required this.showOpenButton,
  });

  final List<LatLng> waypoints;
  final TripRouteResponseData? routeData;
  final bool showOpenButton;

  @override
  Widget build(BuildContext context) {
    final polylinePoints = routeData?.polylinePoints ?? waypoints;
    final center = calculateMapCenter(waypoints);

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: waypoints.length == 1 ? 14 : 10,
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
                    color: AppColors.lightBrown,
                    strokeWidth: 4,
                  ),
                ],
              ),
            MarkerLayer(
              markers: waypoints.asMap().entries.map((entry) {
                return Marker(
                  point: entry.value,
                  width: 34.w,
                  height: 34.h,
                  child: _HistoryMapPointMarker(
                    label: waypointLabel(entry.key),
                    color: entry.key == 0 ? Colors.red : AppColors.primary,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        if (showOpenButton)
          Positioned(
            top: 10.h,
            right: 10.w,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => _HistoryRouteMapFullscreen(
                      waypoints: waypoints,
                      routeData: routeData,
                    ),
                  ),
                ),
                borderRadius: BorderRadius.circular(24.r),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
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
                    color: AppColors.darkBrown,
                  ),
                ),
              ),
            ),
          ),
        if (routeData != null && showOpenButton)
          Positioned(
            left: 10.w,
            right: 10.w,
            bottom: 10.h,
            child: _HistoryRouteSummary(routeData: routeData!),
          ),
      ],
    );
  }
}

class _HistoryRouteMapFullscreen extends StatelessWidget {
  const _HistoryRouteMapFullscreen({
    required this.waypoints,
    required this.routeData,
  });

  final List<LatLng> waypoints;
  final TripRouteResponseData? routeData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: _HistoryRouteMapView(
              waypoints: waypoints,
              routeData: routeData,
              showOpenButton: false,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12.h,
            left: 16.w,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(24.r),
                child: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ),
            ),
          ),
          if (routeData != null)
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: MediaQuery.of(context).padding.bottom + 16.h,
              child: _HistoryRouteSummary(routeData: routeData!),
            ),
        ],
      ),
    );
  }
}

class _HistoryRouteSummary extends StatelessWidget {
  const _HistoryRouteSummary({required this.routeData});

  final TripRouteResponseData routeData;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.route_outlined, size: 16.sp, color: AppColors.primary),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              '${routeData.totalDistance} • ${routeData.totalDuration}',
              style: TextStyle(
                color: AppColors.darkBrown,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryMapPointMarker extends StatelessWidget {
  const _HistoryMapPointMarker({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class TimelineWrapperHistory extends StatelessWidget {
  final Widget child;
  final bool isFirst;
  final bool isLast;
  final Color timelineColor;

  const TimelineWrapperHistory({
    super.key,
    required this.child,
    required this.timelineColor,
    this.isFirst = false,
    this.isLast = false,
  });

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
