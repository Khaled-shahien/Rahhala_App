import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:rahhala_app/core/constants/app_colors.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/widgets/background_decorator.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/expansion_tile_components.dart';
import 'package:rahhala_app/features/trip_history/data/models/trip_history_model.dart';
import 'package:rahhala_app/features/trip_history/domain/cubits/trip_history_cubit.dart';
import 'package:rahhala_app/features/trip_history/domain/cubits/trip_history_state.dart';

const Color _primaryTextColor = AppColors.darkBrown;
const Color _lightBorderColor = AppColors.lightBrown;
const Color _costBadgeBgColor = AppColors.costBadgeBackground;
const Color _screenBgColor = AppColors.screenBackground;
const Color _timelineColor = AppColors.lightBrown;

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripHistoryCubit, TripHistoryState>(
      builder: (context, state) {
        if (state is TripHistoryDetailLoading) {
          return _buildLoading();
        } else if (state is TripHistoryDetailLoaded) {
          return _buildContent(context, state.response.trip);
        } else if (state is TripHistoryDetailFailure) {
          return _buildError(context, state.message);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoading() {
    return Scaffold(
      backgroundColor: _screenBgColor,
      body: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          children: [
            Container(height: 380.h, color: Colors.white),
            SizedBox(height: 16.h),
            ...List.generate(
              3,
              (_) => Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                height: 80.h,
                decoration: BoxDecoration(
                  color: Colors.white,
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
      backgroundColor: _screenBgColor,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60.sp, color: Colors.grey.shade400),
            SizedBox(height: 16.h),
            Text(message,
                style: TextStyle(fontSize: 15.sp, color: Colors.grey.shade600)),
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
      backgroundColor: _screenBgColor,
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
                      ...trip.days.map((day) => _buildDayTile(day)),
                      SizedBox(height: 12.h),
                      if (trip.budgetTips.isNotEmpty)
                        _buildSimpleTile(
                          icon: Icons.lightbulb_outline,
                          title: 'Budget tips',
                          content: trip.budgetTips,
                        ),
                      if (trip.travelTips.isNotEmpty)
                        _buildSimpleTile(
                          icon: Icons.favorite_border,
                          title: 'Travel tips',
                          content: trip.travelTips,
                        ),
                      if (trip.emergencyContact.isNotEmpty)
                        _buildEmergencySection(trip.emergencyContact),
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
                child: Image.network(
                  trip.countryImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
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
                    _screenBgColor.withOpacity(0.15),
                    _screenBgColor.withOpacity(0.5),
                    _screenBgColor,
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
                    _screenBgColor.withOpacity(0.3),
                    const Color(0xFFF3E5D8).withOpacity(0.8),
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
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20.sp),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
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
                          color: Colors.black.withOpacity(1.0),
                          offset: const Offset(0, 2),
                          blurRadius: 255,
                        ),
                        Shadow(
                          color: Colors.black.withOpacity(1.0),
                          offset: const Offset(0, 4),
                          blurRadius: 100,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30.h),
                _buildPill(Icons.location_on_outlined, trip.destination),
                SizedBox(height: 12.h),
                _buildPill(null, 'Total cost: ${trip.totalEstimatedCost}',
                    isCost: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill(IconData? icon, String text, {bool isCost = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5D8).withOpacity(0.7),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: const Color(0xFF8B6F5A), width: 1.4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16.sp, color: const Color(0xFF5C4634)),
            SizedBox(width: 6.w),
          ],
          Text(
            text,
            style: TextStyle(
              color: const Color(0xFF5C4634),
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayTile(TripHistoryDay day) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: _lightBorderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
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
                color: _lightBorderColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              day.title,
              style: TextStyle(
                color: _primaryTextColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        trailing: CostBadge(
          cost: day.estimatedDayCost,
          backgroundColor: _costBadgeBgColor,
          textColor: _primaryTextColor,
          borderColor: _lightBorderColor,
          iconColor: _lightBorderColor,
        ),
        iconColor: _primaryTextColor,
        collapsedIconColor: _primaryTextColor,
        children: [_buildActivities(day.activities)],
      ),
    );
  }

  Widget _buildActivities(List<TripHistoryActivity> activities) {
    return Container(
      margin: EdgeInsets.all(12.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: _costBadgeBgColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: activities.asMap().entries.map((entry) {
          final i = entry.key;
          final act = entry.value;
          return TimelineWrapperHistory(
            isFirst: i == 0,
            isLast: i == activities.length - 1,
            child: CustomExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              leading: NumberCircle(
                number: i + 1,
                backgroundColor: _timelineColor,
                textColor: Colors.white,
              ),
              title: Text(
                act.place,
                style: TextStyle(
                  color: _primaryTextColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              iconColor: _primaryTextColor,
              collapsedIconColor: _primaryTextColor,
              children: [
                if (act.image != null && act.image!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.network(
                      act.image!,
                      width: double.infinity,
                      height: 180.h,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                if (act.image != null && act.image!.isNotEmpty)
                  SizedBox(height: 12.h),
                Padding(
                  padding:
                      EdgeInsets.only(left: 45.w, right: 12.w, bottom: 12.h),
                  child: Text(
                    act.description,
                    style: TextStyle(color: _primaryTextColor, fontSize: 13.sp),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSimpleTile({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.black12),
      ),
      child: CustomExpansionTile(
        tilePadding: EdgeInsets.all(16.w),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
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
                          color: _primaryTextColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 4.h),
                  Text(
                    content,
                    style: TextStyle(
                        color: _primaryTextColor.withOpacity(0.8),
                        fontSize: 13.sp),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down,
                color: _primaryTextColor, size: 20.sp),
          ],
        ),
        iconColor: Colors.transparent,
        collapsedIconColor: Colors.transparent,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
            alignment: Alignment.centerLeft,
            child: Text(content,
                style: TextStyle(fontSize: 13.sp, color: _primaryTextColor)),
          )
        ],
      ),
    );
  }

  Widget _buildEmergencySection(String emergencyContact) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.black12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.emergency_outlined,
                  color: AppColors.primary, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Emergency Contact',
                      style: TextStyle(
                          color: _primaryTextColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 4.h),
                  Text(emergencyContact,
                      style: TextStyle(
                          color: _primaryTextColor.withOpacity(0.8),
                          fontSize: 13.sp)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimelineWrapperHistory extends StatelessWidget {
  final Widget child;
  final bool isFirst;
  final bool isLast;

  const TimelineWrapperHistory({
    super.key,
    required this.child,
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
                  color: isFirst ? Colors.transparent : _timelineColor,
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : _timelineColor,
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
