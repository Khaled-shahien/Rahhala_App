import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';
import 'package:rahhala_app/features/custom_trip/presentation/pages/custom_trip_flow_screen.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/pages/ai_recommendation_flow_screen.dart';

class TripTypeSelectionScreen extends StatelessWidget {
  const TripTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.bgColor,
      // appBar: AppBar(
      //   backgroundColor: ThemeColor.bgColor,
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back_ios_new_outlined,
      //         color: Colors.black),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      // ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Text(
                'Select Trip Type',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: ThemeColor.primaryColor,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Choose how you want to plan your trip',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: ThemeColor.neutralGrayColor,
                ),
              ),
              SizedBox(height: 48.h),

              // Custom Trip Option
              _buildTripTypeCard(
                context,
                icon: Icons.edit_document,
                title: 'Custom Trip',
                description:
                    'Plan your trip yourself with full control over every detail',
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
                title: 'General Trip',
                description: 'Let AI create a personalized trip plan for you',
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: ThemeColor.primaryColor.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ThemeColor.primaryColor.withValues(alpha: 0.2),
                    ThemeColor.primaryColor.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                icon,
                size: 32.sp,
                color: ThemeColor.primaryColor,
              ),
            ),
            SizedBox(width: 20.w),

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
                      color: ThemeColor.charcoalColor,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: ThemeColor.neutralGrayColor,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios,
              size: 18.sp,
              color: ThemeColor.neutralGrayColor,
            ),
          ],
        ),
      ),
    );
  }
}
