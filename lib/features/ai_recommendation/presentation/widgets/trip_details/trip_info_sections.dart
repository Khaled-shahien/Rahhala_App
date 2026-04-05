import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/constants/app_colors.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/expansion_tile_components.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/trip_details/trip_details_theme.dart';

class TripInfoSections extends StatelessWidget {
  const TripInfoSections({
    super.key,
    required this.budgetTips,
    required this.travelTips,
    required this.emergencyContact,
  });

  final String budgetTips;
  final String travelTips;
  final String emergencyContact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SimpleExpansionTile(
          icon: Icons.lightbulb_outline,
          title: TripDetailsStrings.budgetTips,
          content: budgetTips,
        ),
        _SimpleExpansionTile(
          icon: Icons.favorite_border,
          title: TripDetailsStrings.travelTips,
          content: travelTips,
        ),
        _EmergencyContactSection(emergencyContact: emergencyContact),
      ],
    );
  }
}

class _SimpleExpansionTile extends StatelessWidget {
  const _SimpleExpansionTile({
    required this.icon,
    required this.title,
    required this.content,
  });

  final IconData icon;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    final details = content.isEmpty ? TripDetailsStrings.noInfo : content;
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
              child: Icon(icon, color: AppColors.primary, size: 24.sp),
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
                    details,
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
            Icon(Icons.keyboard_arrow_down,
                color: primaryTextColor, size: 20.sp),
          ],
        ),
        iconColor: Colors.transparent,
        collapsedIconColor: Colors.transparent,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
            alignment: Alignment.centerLeft,
            child: Text(
              details,
              style: TextStyle(fontSize: 13.sp, color: primaryTextColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyContactSection extends StatelessWidget {
  const _EmergencyContactSection({required this.emergencyContact});

  final String emergencyContact;

  @override
  Widget build(BuildContext context) {
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
                color: AppColors.primary.withValues(alpha: 0.1),
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
                    TripDetailsStrings.emergencyContact,
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
                      color: primaryTextColor.withValues(alpha: 0.8),
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
}
