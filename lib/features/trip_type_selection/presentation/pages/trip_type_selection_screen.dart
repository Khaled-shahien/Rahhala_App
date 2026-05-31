import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';
import 'package:rahhala_app/core/localization/app_localization_extensions.dart';

import 'package:rahhala_app/features/custom_trip/presentation/pages/custom_trip_flow_screen.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/pages/ai_recommendation_flow_screen.dart';

class TripTypeSelectionScreen extends StatelessWidget {
  const TripTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: ThemeColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 88.h,
        leadingWidth: 56.w,
        leading: Padding(
          padding: EdgeInsetsDirectional.only(start: 12.w),
          child: Icon(
            Icons.alt_route_rounded,
            color: Colors.white,
            size: 22.sp,
          ),
        ),
        titleSpacing: 12.w,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.l10n.tripTypeSelectTitle,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              context.l10n.tripTypeSelectSubtitle,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.white.withValues(alpha: 0.85),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),

              // Custom Trip Option
              _buildTripTypeCard(
                context,
                icon: Icons.edit_document,
                title: context.l10n.tripTypeCustom,
                description: context.l10n.tripTypeCustomDesc,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CustomTripFlowScreen(),
                    ),
                  );
                },
              ),

              SizedBox(height: 20.h),

              // General Trip (AI-Powered) Option
              _buildTripTypeCard(
                context,
                icon: Icons.auto_awesome,
                title: context.l10n.tripTypeGeneral,
                description: context.l10n.tripTypeGeneralDesc,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AIRecommendationFlowScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripTypeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: ThemeColor.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                icon,
                size: 30.sp,
                color: ThemeColor.primaryColor,
              ),
            ),
            SizedBox(width: 16.w),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16.sp,
              color: ThemeColor.primaryColor.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
