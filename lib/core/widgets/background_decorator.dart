import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';

class BackgroundDecorator extends StatelessWidget {
  final Widget child;

  const BackgroundDecorator({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ThemeColor.primaryColor.withValues(alpha: 0.1),
                isDark ? const Color(0xFF121212) : Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          top: -120.h,
          right: -80.w,
          child: Container(
            width: 280.w,
            height: 280.w,
            decoration: BoxDecoration(
              color: ThemeColor.primaryColor.withValues(
                alpha: isDark ? 0.05 : 0.14,
              ),
              borderRadius: BorderRadius.circular(140.r),
            ),
          ),
        ),
        Positioned(
          bottom: -120.h,
          left: -100.w,
          child: Container(
            width: 320.w,
            height: 320.w,
            decoration: BoxDecoration(
              color: ThemeColor.primaryColor.withValues(
                alpha: isDark ? 0.04 : 0.1,
              ),
              borderRadius: BorderRadius.circular(160.r),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
