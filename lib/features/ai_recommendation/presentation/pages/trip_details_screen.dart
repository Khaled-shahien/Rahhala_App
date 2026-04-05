import 'dart:async';

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
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/trip_details/trip_day_section.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/trip_details/trip_details_header.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/trip_details/trip_details_theme.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/trip_details/trip_info_sections.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/trip_details/trip_save_button.dart';

class TripDetailsScreen extends StatefulWidget {
  const TripDetailsScreen({
    super.key,
    required this.tripPlan,
    required this.geminiRequest,
  });

  final TripPlanResponse tripPlan;
  final Map<String, dynamic> geminiRequest;

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  bool _isSaving = false;
  bool _isRegenerating = false;
  late TripPlanResponse _currentTripPlan;

  @override
  void initState() {
    super.initState();
    _currentTripPlan = widget.tripPlan;
  }

  TripPlan get plan => _currentTripPlan.response;

  Future<void> _saveTrip() async {
    if (_isSaving) {
      return;
    }
    setState(() => _isSaving = true);

    try {
      final repo = sl<GeminiRepository>();
      final result = await repo.saveTripPlan(
        tripPlan: _currentTripPlan,
        geminiRequest: widget.geminiRequest,
      );

      if (!mounted) {
        return;
      }

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
                  '${data['message'] ?? TripDetailsStrings.saveSuccessFallback}\n'
                  'Trip ID: $savedTripId',
            );
            return;
          }

          HapticFeedback.mediumImpact();
          showAppNotification(
            context: context,
            title: 'Error',
            message: data['message'] ?? 'Error occurred',
            isError: true,
          );
        },
      );
    } catch (_) {
      if (mounted) {
        HapticFeedback.mediumImpact();
        showAppNotification(
          context: context,
          title: 'Error',
          message: TripDetailsStrings.saveFailed,
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _regenerateTrip() async {
    if (_isRegenerating) {
      return;
    }
    setState(() => _isRegenerating = true);

    try {
      final repo = sl<GeminiRepository>();

      final requestBody = {
        'success': true,
        'tripData': {
          'destination': plan.destination,
          'days': plan.days
              .map((day) => {
                    'day': day.day,
                    'title': day.title,
                    'estimatedDayCost': day.estimatedDayCost,
                    'activities': day.activities
                        .map((activity) => {
                              'time': activity.time,
                              'place': activity.place,
                              'description': activity.description,
                              'estimatedCost': activity.estimatedCost,
                              'image': activity.image,
                              'transportation': [],
                            })
                        .toList(),
                  })
              .toList(),
          'totalEstimatedCost': plan.totalEstimatedCost,
          'budgetTips': plan.budgetTips,
          'travelTips': plan.travelTips,
          'emergencycontact': plan.emergencyContact,
          'tripId': '00000000-0000-0000-0000-000000000000',
        },
        'geminiRequest': widget.geminiRequest,
      };

      final result = await repo.regenerateTripPlan(requestBody);

      if (!mounted) {
        return;
      }

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
          if (data['success'] == true && data['tripData'] != null) {
            final newPlan = TripPlan.fromJson(data['tripData']);
            final newResponse = TripPlanResponse(
              success: true,
              response: newPlan,
              savedId: 0,
              tripId: _currentTripPlan.tripId,
              message: 'Trip regenerated successfully',
              geminiRequest: widget.geminiRequest,
            );

            showAppNotification(
              context: context,
              title: 'Success',
              message: TripDetailsStrings.tripRegenerated,
            );

            setState(() {
              _currentTripPlan = newResponse;
            });
            return;
          }

          HapticFeedback.mediumImpact();
          showAppNotification(
            context: context,
            title: 'Error',
            message: data['message'] ?? 'Failed to regenerate trip',
            isError: true,
          );
        },
      );
    } catch (_) {
      if (mounted) {
        HapticFeedback.mediumImpact();
        showAppNotification(
          context: context,
          title: 'Error',
          message: TripDetailsStrings.regenerateFailed,
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRegenerating = false);
      }
    }
  }

  void _showRegenerateDialog() {
    unawaited(showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text(
            TripDetailsStrings.regenerateTitle,
            style: TextStyle(
              color: primaryTextColor,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            TripDetailsStrings.regenerateBody,
            style: TextStyle(color: primaryTextColor, fontSize: 14.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                TripDetailsStrings.cancel,
                style: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                unawaited(_regenerateTrip());
              },
              child: Text(
                TripDetailsStrings.regenerate,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      extendBodyBehindAppBar: true,
      bottomNavigationBar: TripSaveButton(
        isSaving: _isSaving,
        onSave: _saveTrip,
      ),
      body: SafeArea(
        top: false,
        child: BackgroundDecorator(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TripDetailsHeader(
                plan: plan,
                isRegenerating: _isRegenerating,
                onBack: () => Navigator.pop(context),
                onRegenerate: _showRegenerateDialog,
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      SizedBox(height: 16.h),
                      ...plan.days.map((day) => TripDaySection(day: day)),
                      SizedBox(height: 16.h),
                      _buildEmergencyContactSection(
                        emergencyContact: plan.emergencyContact ?? '',
                      ),
                      // TripInfoSections(
                      //   budgetTips: plan.budgetTips,
                      //   travelTips: plan.travelTips,
                      //   emergencyContact: plan.emergencyContact,
                      // ),
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
    return SizedBox(
      width: double.infinity,
      height: 380.h,
      child: Stack(
        children: [
          // Display country image as full-bleed background
          if (plan.countryImage != null && plan.countryImage!.isNotEmpty)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35.r),
                  bottomRight: Radius.circular(35.r),
                ),
                child: Image.network(
                  plan.countryImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 380.h,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading country image: $error');
                    return Container(
                      decoration: BoxDecoration(
                        color: headerBackgroundColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(35.r),
                          bottomRight: Radius.circular(35.r),
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: headerBackgroundColor.withValues(alpha: 0.3),
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    );
                  },
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
                    screenBackgroundColor.withValues(alpha: 0.15),
                    screenBackgroundColor.withValues(alpha: 0.5),
                    screenBackgroundColor,
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
                    screenBackgroundColor.withValues(alpha: 0.3),

                    /// screenBackgroundColor,
                    const Color(0xFFF3E5D8).withValues(alpha: 0.8)
                  ],
                  stops: const [0.0, 0.5, 0.8, 1.0],
                ),
              ),
            ),
          ),
          // Decorative assets in top-right corner
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

          // Back and Regenerate buttons
          Positioned(
            top: MediaQuery.of(context).padding.top + 12.h,
            left: 16.w,
            right: 16.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                _isRegenerating
                    ? Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: SizedBox(
                          width: 20.sp,
                          height: 20.sp,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: _showRegenerateDialog,
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.refresh_rounded,
                              color: Colors.white, size: 20.sp),
                        ),
                      ),
              ],
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
                SizedBox(
                  height: 20.h,
                ),
                _buildTitle(),
                SizedBox(height: 30.h),
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
    );
  }

  Widget _buildModernPill(
      {IconData? icon, required String text, bool isCost = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5D8).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(
          color: const Color(0xFF8B6F5A),
          width: 1.4,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18.sp,
            color: const Color(0xFF5C4634),
          ),
          SizedBox(width: 8.w),
          Text(
            text,
            style: TextStyle(
              color: const Color(0xFF5C4634),
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
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
              color: Colors.black.withValues(alpha: 0.08),
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
                  // Activity image if available
                  if (act.image != null && act.image!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.network(
                        act.image!,
                        width: double.infinity,
                        height: 180.h,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading activity image: $error');
                          return const SizedBox.shrink();
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: double.infinity,
                            height: 180.h,
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    primaryTextColor),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  if (act.image != null && act.image!.isNotEmpty)
                    SizedBox(height: 12.h),
                  // Activity description
                  Padding(
                    padding:
                        EdgeInsets.only(left: 45.w, right: 12.w, bottom: 12.h),
                    child: Text(
                      act.description,
                      style:
                          TextStyle(color: primaryTextColor, fontSize: 13.sp),
                    ),
                  ),
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
        border: Border.all(color: lightBorderColor.withValues(alpha: 0.4), width: 1),
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
                color: AppColors.primary.withValues(alpha: 0.1),
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
                      color: primaryTextColor.withValues(alpha: 0.8),
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
    if (emergencyContact.isEmpty) return const SizedBox.shrink();

    final contacts = emergencyContact.split(',');

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
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
                    color: lightBorderColor.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.emergency_outlined,
                      color: Colors.red.shade400, size: 24.sp),
                ),
                SizedBox(width: 16.w),
                Text(
                  'Emergency Contacts',
                  style: TextStyle(
                    color: primaryTextColor,
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
                    color: lightBorderColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                        color: lightBorderColor.withValues(alpha: 0.2), width: 1),
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
                              color: primaryTextColor,
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
