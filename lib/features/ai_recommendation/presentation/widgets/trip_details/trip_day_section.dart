import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/logging/app_logger.dart';
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
          ...activities.asMap().entries.map((entry) {
            final index = entry.key;
            final act = entry.value;
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
