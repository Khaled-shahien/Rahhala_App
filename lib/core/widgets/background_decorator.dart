import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';

class BackgroundDecorator extends StatelessWidget {
  final Widget child;

  const BackgroundDecorator({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ThemeColor.primaryColor.withOpacity(0.1),
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // Top right decorative circle
        Positioned(
          top: -120.h,
          right: -80.w,
          child: Container(
            width: 280.w,
            height: 280.w,
            decoration: BoxDecoration(
              color: ThemeColor.primaryColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(140.r),
            ),
          ),
        ),

        // Bottom left decorative circle
        Positioned(
          bottom: -120.h,
          left: -100.w,
          child: Container(
            width: 320.w,
            height: 320.w,
            decoration: BoxDecoration(
              color: ThemeColor.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(160.r),
            ),
          ),
        ),

        // Child content
        child,
      ],
    );
  }
}
