import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/constants/app_colors.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/utils/app_notifications.dart';
import 'package:rahhala_app/core/widgets/background_decorator.dart';
import 'package:rahhala_app/features/ai_recommendation/data/models/trip_plan_model.dart';
import 'package:rahhala_app/features/ai_recommendation/data/repositories/gemini_repository.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/expansion_tile_components.dart';

// الألوان والثوابت
const Color headerBackgroundColor = Color(0xFFF2E7D5);
const Color brownTextColor = Color(0xFF3E3431);
const Color primaryTextColor = AppColors.darkBrown;
const Color lightBorderColor = AppColors.lightBrown;
const Color locationCardBackgroundColor = AppColors.costBadgeBackground;
const Color screenBackgroundColor = AppColors.screenBackground;
const Color timelineColor = AppColors.lightBrown;
const Color costBadgeBgColor = AppColors.costBadgeBackground;
const Color arrowColor = Color(0xFF008080);

class TripDetailsScreen extends StatefulWidget {
  final TripPlanResponse tripPlan;
  final Map<String, dynamic> geminiRequest;

  const TripDetailsScreen({
    super.key,
    required this.tripPlan,
    required this.geminiRequest,
  });

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  bool _isSaving = false;

  TripPlan get plan => widget.tripPlan.response;

  Future<void> _saveTrip() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final repo = sl<GeminiRepository>();
      final result = await repo.saveTripPlan(
        tripPlan: widget.tripPlan,
        geminiRequest: widget.geminiRequest,
      );

      if (!mounted) return;

      result.fold(
        (failure) {
          HapticFeedback.mediumImpact();
          showAppNotification(
            context: context,
            title: 'Error',
            message: failure.message,
            isError: true,
          );
        },
        (data) {
          if (data['success'] == true) {
            final savedTripId = data['tripId'] ?? 'N/A';
            showAppNotification(
              context: context,
              title: 'Saved',
              message:
                  '${data['message'] ?? 'Trip saved successfully.'}\nTrip ID: $savedTripId',
            );
          } else {
            HapticFeedback.mediumImpact();
            showAppNotification(
              context: context,
              title: 'Error',
              message: data['message'] ?? 'Error occurred',
              isError: true,
            );
          }
        },
      );
    } catch (_) {
      if (mounted) {
        HapticFeedback.mediumImpact();
        showAppNotification(
          context: context,
          title: 'Error',
          message: 'Failed to save trip.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      bottomNavigationBar: _buildBottomSaveButton(),
      body: SafeArea(
        child: BackgroundDecorator(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      SizedBox(height: 16.h),
                      ...plan.days.map((day) => _buildDayExpansionTile(
                            context,
                            dayNumber: day.day,
                            title: day.title,
                            cost: day.estimatedDayCost,
                            activities: day.activities,
                          )),
                      SizedBox(height: 16.h),
                      _buildSimpleExpansionTile(
                        icon: Icons.lightbulb_outline,
                        title: "Budget tips",
                        content: plan.budgetTips,
                      ),
                      _buildSimpleExpansionTile(
                        icon: Icons.favorite_border,
                        title: "Travel tips",
                        content: plan.travelTips,
                      ),
                      _buildEmergencyContactSection(
                        emergencyContact: plan.emergencyContact,
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

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: headerBackgroundColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35.r),
          bottomRight: Radius.circular(35.r),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset(
              'assets/images/cover.png',
              width: 350.w,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              bottom: 30.h,
              top: 30.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(),
                SizedBox(height: 20.h),
                _buildModernPill(
                  icon: Icons.location_on_outlined,
                  text: plan.destination,
                ),
                SizedBox(height: 12.h),
                _buildModernPill(
                  text: "Total cost: ${plan.totalEstimatedCost}",
                  isCost: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return SizedBox(
      width: 240.w,
      child: Text(
        'Every place, every moment\nchosen just for you.',
        style: TextStyle(
          color: brownTextColor,
          fontSize: 22.sp,
          fontWeight: FontWeight.w900,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildModernPill(
      {IconData? icon, required String text, bool isCost = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: brownTextColor, width: 2.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: brownTextColor, size: 20.sp),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: brownTextColor,
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayExpansionTile(
    BuildContext context, {
    required int dayNumber,
    required String title,
    required String cost,
    required List<Activity> activities,
  }) {
    final cleanCost = cost.replaceAll("EGP", "").trim();
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: lightBorderColor, width: 1.5),
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
              "Day $dayNumber",
              style: TextStyle(
                color: lightBorderColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: primaryTextColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        trailing: CostBadge(
          cost: cleanCost,
          backgroundColor: costBadgeBgColor,
          textColor: primaryTextColor,
          borderColor: lightBorderColor,
          iconColor: lightBorderColor,
        ),
        iconColor: primaryTextColor,
        collapsedIconColor: primaryTextColor,
        children: [_buildDayDetailsContent(context, activities)],
      ),
    );
  }

  Widget _buildDayDetailsContent(
      BuildContext context, List<Activity> activities) {
    return Container(
      margin: EdgeInsets.all(12.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: locationCardBackgroundColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...activities.asMap().entries.map((entry) {
            int index = entry.key;
            var act = entry.value;
            return TimelineWrapper(
              isFirst: index == 0,
              isLast: index == activities.length - 1,
              child: CustomExpansionTile(
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
                        style: TextStyle(
                          color: primaryTextColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
                iconColor: primaryTextColor,
                collapsedIconColor: primaryTextColor,
                children: [
                  Padding(
                    padding:
                        EdgeInsets.only(left: 45.w, right: 12.w, bottom: 12.h),
                    child: Text(
                      act.description,
                      style:
                          TextStyle(color: primaryTextColor, fontSize: 13.sp),
                    ),
                  )
                ],
              ),
            );
          }),
          _buildTransportationSection(activities),
        ],
      ),
    );
  }

  Widget _buildTransportationSection(List<Activity> activities) {
    final List<Transportation> allTransports = [];
    for (var activity in activities) {
      allTransports.addAll(activity.transportation);
    }

    if (allTransports.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
          child: Row(
            children: [
              Icon(Icons.directions_car_outlined,
                  size: 18.sp, color: brownTextColor),
              SizedBox(width: 8.w),
              Text(
                "Transportation Routes",
                style: TextStyle(
                  color: brownTextColor,
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
            children: allTransports.map((t) => _buildRouteRow(t)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteRow(Transportation t) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          _buildRoutePill(t.from),
          _buildRouteArrow(),
          _buildRoutePill(t.method, isMethod: true),
          _buildRouteArrow(),
          _buildRoutePill(t.to),
        ],
      ),
    );
  }

  Widget _buildRoutePill(String text, {bool isMethod = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: lightBorderColor.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isMethod) ...[
            Icon(Icons.directions_car, size: 12.sp, color: brownTextColor),
            SizedBox(width: 4.w),
          ],
          Text(
            text,
            style: TextStyle(
              color: brownTextColor,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteArrow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Icon(
        Icons.trending_flat,
        color: arrowColor,
        size: 18.sp,
      ),
    );
  }

  Widget _buildSimpleExpansionTile({
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
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    content.isEmpty ? "No information available" : content,
                    style: TextStyle(
                      color: primaryTextColor.withOpacity(0.8),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: primaryTextColor,
              size: 20.sp,
            ),
          ],
        ),
        iconColor: Colors.transparent,
        collapsedIconColor: Colors.transparent,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
            alignment: Alignment.centerLeft,
            child: Text(
              content.isEmpty ? "No information available" : content,
              style: TextStyle(fontSize: 13.sp, color: primaryTextColor),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmergencyContactSection({required String emergencyContact}) {
    if (emergencyContact.isEmpty) {
      return const SizedBox.shrink();
    }

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
              child: Icon(
                Icons.emergency_outlined,
                color: AppColors.primary,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Emergency Contact",
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    emergencyContact,
                    style: TextStyle(
                      color: primaryTextColor.withOpacity(0.8),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSaveButton() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: ElevatedButton.icon(
          onPressed: _isSaving ? null : _saveTrip,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: Size(double.infinity, 50.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)),
          ),
          icon: _isSaving
              ? SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white)))
              : const Icon(Icons.bookmark_add_outlined, color: Colors.white),
          label: Text(
            _isSaving ? 'Saving...' : 'Save trip',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class TimelineWrapper extends StatelessWidget {
  final Widget child;
  final bool isFirst;
  final bool isLast;

  const TimelineWrapper({
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
