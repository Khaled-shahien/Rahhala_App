// lib/features/ai_recommendation/presentation/pages/trip_details_screen.dart
// ✅ النسخة النهائية - إصلاح Overflow في ExpansionTile

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/features/ai_recommendation/data/models/trip_plan_model.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/transportation_widgets.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/expansion_tile_components.dart';
import 'package:rahhala_app/core/constants/app_colors.dart';
import 'package:rahhala_app/core/widgets/background_decorator.dart';

// Using centralized colors from AppColors
const Color darkBrown = AppColors.darkBrown;
const Color mediumBrown = AppColors.mediumBrown;
const Color lightBrown = AppColors.lightBrown;
const Color lightBorderColor = AppColors.lightBrown;
const Color costBadgeBgColor = AppColors.costBadgeBackground;
const Color timelineColor = AppColors.lightBrown;
const Color locationCardBackgroundColor = AppColors.costBadgeBackground;
const Color screenBackgroundColor = AppColors.screenBackground;
const Color primaryTextColor = AppColors.darkBrown;

class TripDetailsScreen extends StatelessWidget {
  final TripPlan plan;

  const TripDetailsScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      body: SafeArea(
        child: BackgroundDecorator(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(
                  left: 16.w,
                  right: 16.w,
                  bottom: 24.h,
                  top: 16.h,
                ),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [darkBrown, mediumBrown, lightBrown],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildTitle(),
                    SizedBox(height: 16.h),
                    _buildHeaderBar(plan.destination, plan.totalEstimatedCost),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 16.h),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: plan.days.length,
                        itemBuilder: (context, index) {
                          final day = plan.days[index];
                          return _buildDayExpansionTile(
                            context,
                            dayNumber: day.day,
                            title: day.title,
                            cost: day.estimatedDayCost,
                            children: [
                              _buildDayDetailsContent(context, day.activities),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 16.h),
                      _buildSimpleExpansionTile(
                        icon: Icons.lightbulb_outline,
                        title: "Budget tips",
                        content: plan.budgetTips,
                      ),
                      SizedBox(height: 16.h),
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

  Widget _buildDayDetailsContent(
      BuildContext context, List<Activity> activities) {
    List<Widget> transportationWidgets = [];
    for (int i = 0; i < activities.length; i++) {
      final activity = activities[i];
      for (var transport in activity.transportation) {
        transportationWidgets.add(
          TransportationRoute(
            from: transport.from,
            to: transport.to,
            method: transport.method,
            cost: transport.estimatedCost,
            textColor: primaryTextColor,
            borderColor: lightBorderColor,
            backgroundColor: Colors.white,
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: locationCardBackgroundColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: lightBorderColor.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              return TimelineWrapper(
                isFirst: index == 0,
                isLast: index == activities.length - 1,
                child: _buildLocationExpansionTile(
                  context,
                  number: index + 1,
                  title: activity.place,
                  children: [
                    _buildLocationDetailsContentInner(
                      time: activity.time,
                      cost: activity.estimatedCost,
                      description: activity.description,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        SizedBox(height: 16.h),
        if (transportationWidgets.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.directions_car_outlined,
                      size: 20.sp,
                      color: primaryTextColor,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        "Transportation Routes",
                        style: TextStyle(
                          color: primaryTextColor,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                ...transportationWidgets,
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLocationDetailsContentInner({
    required String time,
    required String cost,
    required String description,
  }) {
    final isFree = cost.trim() == "0" || cost.toLowerCase().contains("free");
    final costText =
        isFree ? "Free" : (cost.contains("EGP") ? cost : "$cost EGP");

    return Padding(
      padding: EdgeInsets.only(left: 8.w, right: 8.w, top: 4.h, bottom: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeAndCostRow(time, costText, isFree),
          SizedBox(height: 8.h),
          _buildDescriptionText(description),
        ],
      ),
    );
  }

  Widget _buildTimeAndCostRow(String time, String costText, bool isFree) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildTimeWidget(time),
        ),
        SizedBox(width: 8.w),
        Flexible(
          flex: 2,
          child: _buildCostContainer(costText, isFree),
        ),
      ],
    );
  }

  Widget _buildTimeWidget(String time) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.wb_sunny_outlined,
          size: 16.sp,
          color: lightBorderColor,
        ),
        SizedBox(width: 4.w),
        Flexible(
          child: Text(
            time,
            style: TextStyle(
              color: primaryTextColor.withOpacity(0.7),
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildCostContainer(String costText, bool isFree) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isFree
            ? Colors.green.withOpacity(0.15)
            : lightBorderColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        costText,
        style: TextStyle(
          color: isFree ? Colors.green.shade700 : primaryTextColor,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDescriptionText(String description) {
    return Text(
      description,
      style: TextStyle(
        color: primaryTextColor,
        fontSize: 13.sp,
        height: 1.5,
      ),
      softWrap: true,
    );
  }

  Widget _buildTitle() {
    return Center(
      child: Text(
        'Every place, every moment\nchosen just for you.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 22.sp,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _buildHeaderBar(String destination, String totalCost) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: _buildPill(
            icon: Icons.location_on_outlined,
            text: destination,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          flex: 1,
          child: _buildPill(
            icon: Icons.monetization_on_outlined,
            text: totalCost.contains("EGP")
                ? "cost: $totalCost"
                : "cost: $totalCost EGP",
          ),
        ),
      ],
    );
  }

  Widget _buildPill({required IconData icon, required String text}) {
    return PillWidget(
      icon: icon,
      text: text,
      backgroundColor: Colors.white.withOpacity(0.15),
      textColor: Colors.white,
      borderColor: Colors.white70,
    );
  }

  // ✅ إصلاح مشكلة Overflow في ExpansionTile
  Widget _buildDayExpansionTile(
    BuildContext context, {
    required int dayNumber,
    required String title,
    required String cost,
    required List<Widget> children,
  }) {
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: Stack(
          children: [
            // ✅ Price + icon on the far right
            _buildDayExpansionTilePriceIcon(cost),

            // ✅ Main content with Overflow fix
            CustomExpansionTile(
              tilePadding: EdgeInsets.only(
                left: 16.w,
                right: 110.w, // ✅ Enough space for price and icon
                top: 6.h, // ✅ Larger vertical padding
                bottom: 6.h, // ✅ Larger vertical padding
              ),
              childrenPadding: EdgeInsets.zero, // ✅ Remove excess padding
              trailing: const SizedBox.shrink(),
              collapsedIconColor: primaryTextColor,
              iconColor: primaryTextColor,
              title: _buildDayExpansionTileTitle(dayNumber, title),
              children: children,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayExpansionTilePriceIcon(String cost) {
    return Positioned(
      top: 12.h,
      right: 12.w,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCostBadge(cost),
          Icon(
            Icons.keyboard_arrow_down,
            size: 22.sp,
            color: primaryTextColor,
          ),
          SizedBox(width: 6.w),
        ],
      ),
    );
  }

  Widget _buildDayExpansionTileTitle(int dayNumber, String title) {
    return Padding(
      padding: EdgeInsets.only(top: 2.h, bottom: 2.h), // ✅ Additional padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Day $dayNumber",
            style: TextStyle(
              color: lightBorderColor,
              fontSize: 15.sp, // ✅ Slightly smaller size
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            title,
            style: TextStyle(
              color: primaryTextColor,
              fontSize: 13.sp, // ✅ Slightly smaller size
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCostBadge(String cost) {
    return CostBadge(
      cost: cost,
      backgroundColor: costBadgeBgColor,
      textColor: primaryTextColor,
      borderColor: lightBorderColor,
      iconColor: lightBorderColor,
    );
  }

  Widget _buildLocationExpansionTile(
    BuildContext context, {
    required int number,
    required String title,
    required List<Widget> children,
  }) {
    return CustomExpansionTile(
      tilePadding: EdgeInsets.only(right: 8.w),
      childrenPadding: EdgeInsets.zero,
      leading: _buildNumberCircle(number),
      title: Text(
        title,
        style: TextStyle(
          color: primaryTextColor,
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      iconColor: primaryTextColor,
      collapsedIconColor: primaryTextColor,
      children: children,
    );
  }

  Widget _buildNumberCircle(int number) {
    return NumberCircle(
      number: number,
      backgroundColor: timelineColor,
      textColor: Colors.white,
    );
  }

  Widget _buildTransportationRoute({
    required String from,
    required String to,
    required String method,
    required String cost,
  }) {
    return TransportationRoute(
      from: from,
      to: to,
      method: method,
      cost: cost,
      textColor: primaryTextColor,
      borderColor: lightBorderColor,
      backgroundColor: Colors.white,
    );
  }

  Widget _buildTransportationPillSmall({
    required String text,
    IconData? icon,
    String? cost,
  }) {
    return TransportationPill(
      text: text,
      icon: icon,
      cost: cost,
      textColor: primaryTextColor,
      borderColor: lightBorderColor,
      backgroundColor: Colors.white,
    );
  }

  Widget _buildArrowSmall() {
    return const ArrowIcon(color: lightBorderColor);
  }

  Widget _buildSimpleExpansionTile({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.black12, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        childrenPadding: EdgeInsets.zero, // ✅ إزالة padding زائد
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: lightBorderColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: lightBorderColor, size: 20.sp),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        collapsedIconColor: primaryTextColor,
        iconColor: primaryTextColor,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Text(
              content.isEmpty ? "No tips available." : content,
              style: TextStyle(
                color: primaryTextColor.withOpacity(0.7),
                fontSize: 14.sp,
                height: 1.6,
              ),
              softWrap: true,
            ),
          ),
        ],
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
        children: <Widget>[
          SizedBox(
            width: 50.w,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    width: 2.5,
                    margin: EdgeInsets.only(left: 20.w),
                    decoration: BoxDecoration(
                      color: isFirst ? Colors.transparent : timelineColor,
                      borderRadius: BorderRadius.vertical(
                        top: isFirst ? Radius.zero : const Radius.circular(2),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                Expanded(
                  child: Container(
                    width: 2.5,
                    margin: EdgeInsets.only(left: 20.w),
                    decoration: BoxDecoration(
                      color: isLast ? Colors.transparent : timelineColor,
                      borderRadius: BorderRadius.vertical(
                        bottom: isLast ? Radius.zero : const Radius.circular(2),
                      ),
                    ),
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
