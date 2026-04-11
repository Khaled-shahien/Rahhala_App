import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bubbleColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final dotColor = ThemeColor.primaryColor.withValues(alpha: isDark ? 0.8 : 0.6);
    final iconBgColor = ThemeColor.primaryColor.withValues(alpha: isDark ? 0.2 : 0.1);

    return Row(
      children: [
        // أيقونة الروبوت (ANIS)
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Icon(
            Icons.smart_toy_outlined,
            size: 20.sp,
            color: ThemeColor.primaryColor,
          ),
        ),
        SizedBox(width: 8.w),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDot(0, dotColor),
              SizedBox(width: 4.w),
              _buildDot(1, dotColor),
              SizedBox(width: 4.w),
              _buildDot(2, dotColor),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDot(int index, Color color) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 200)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value * 3),
          child: Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
