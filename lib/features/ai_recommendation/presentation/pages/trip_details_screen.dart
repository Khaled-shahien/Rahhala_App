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

// Colors based on your design
const Color headerBackgroundColor = Color(0xFFF2E7D5);
const Color brownTextColor = Color(0xFF3E3431);
const Color primaryTextColor = AppColors.darkBrown;
const Color lightBorderColor = AppColors.lightBrown;
const Color locationCardBackgroundColor = AppColors.costBadgeBackground;
const Color screenBackgroundColor = AppColors.screenBackground;
const Color timelineColor = AppColors.lightBrown;
const Color costBadgeBgColor = AppColors.costBadgeBackground;

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
            showAppNotification(
              context: context,
              title: 'Saved',
              message: data['message'] ?? 'Trip saved successfully.',
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
              // --- Header Section ---
              _buildHeader(),

              // --- Content Section ---
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      SizedBox(height: 16.h),
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: plan.days.length,
                        itemBuilder: (context, index) {
                          final day = plan.days[index];
                          return _buildDayExpansionTile(
                            context,
                            dayNumber: day.day,
                            title: day.title,
                            cost: day.estimatedDayCost,
                            activities: day.activities,
                          );
                        },
                      ),
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
        // استخدام Row مع Expanded لمنع التداخل
        title: Row(
          children: [
            Expanded(
              child: Column(
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
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ],
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
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: locationCardBackgroundColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        // تم تغيير الـ Physics للسماح بالتمرير البسيط وتجنب Overflow
        physics: const ClampingScrollPhysics(),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final act = activities[index];
          return TimelineWrapper(
            isFirst: index == 0,
            isLast: index == activities.length - 1,
            child: CustomExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 8.w),
              leading: NumberCircle(
                number: index + 1,
                backgroundColor: timelineColor,
                textColor: Colors.white,
              ),
              title: Expanded(
                child: Text(
                  act.place,
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
              iconColor: primaryTextColor,
              collapsedIconColor: primaryTextColor,
              children: [
                Padding(
                  padding:
                      EdgeInsets.only(left: 45.w, right: 12.w, bottom: 12.h),
                  child: Text(
                    act.description,
                    style: TextStyle(color: primaryTextColor, fontSize: 13.sp),
                  ),
                )
              ],
            ),
          );
        },
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
          border: Border.all(color: Colors.black12)),
      child: CustomExpansionTile(
        leading: Icon(icon, color: lightBorderColor),
        title: Text(
          title,
          style: const TextStyle(
              color: primaryTextColor, fontWeight: FontWeight.bold),
        ),
        iconColor: primaryTextColor,
        collapsedIconColor: primaryTextColor,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            alignment: Alignment.centerLeft,
            child: Text(
              content.isEmpty ? "No tips" : content,
              style: TextStyle(fontSize: 13.sp, color: primaryTextColor),
            ),
          )
        ],
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

// تم الحفاظ على الـ TimelineWrapper مع تعديل بسيط في التصميم
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
                // النقطة أو الرقم يتم وضعه عبر الـ leading في الـ Tile
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
