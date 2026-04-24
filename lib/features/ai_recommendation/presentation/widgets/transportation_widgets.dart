import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TransportationRoute extends StatelessWidget {
  final String from;
  final String to;
  final String method;
  final String cost;

  final Color? textColor;
  final Color? borderColor;
  final Color? backgroundColor;

  const TransportationRoute({
    super.key,
    required this.from,
    required this.to,
    required this.method,
    required this.cost,
    this.textColor,
    this.borderColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveTextColor = textColor ??
        (isDark ? theme.primaryColorLight : const Color(0xFF5C4634));
    final effectiveBorderColor = borderColor ??
        (isDark
            ? theme.primaryColor.withValues(alpha: 0.5)
            : const Color(0xFF8B6F5A));
    final effectiveBgColor = backgroundColor ??
        (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white);

    IconData icon;
    switch (method.toLowerCase()) {
      case 'taxi':
        icon = Icons.local_taxi;
        break;
      case 'walking':
        icon = Icons.directions_walk;
        break;
      case 'private car':
        icon = Icons.directions_car;
        break;
      default:
        icon = Icons.directions_bus;
    }

    final isFree = cost.trim() == "0" || cost.toLowerCase().contains("free");
    final costText = isFree ? null : cost;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            TransportationPill(
              text: from,
              icon: null,
              textColor: effectiveTextColor,
              borderColor: effectiveBorderColor,
              backgroundColor: effectiveBgColor,
            ),
            ArrowIcon(color: effectiveBorderColor),
            TransportationPill(
              text: method,
              cost: costText,
              icon: icon,
              textColor: effectiveTextColor,
              borderColor: effectiveBorderColor,
              backgroundColor: effectiveBgColor,
            ),
            ArrowIcon(color: effectiveBorderColor),
            TransportationPill(
              text: to,
              icon: null,
              textColor: effectiveTextColor,
              borderColor: effectiveBorderColor,
              backgroundColor: effectiveBgColor,
            ),
          ],
        ),
      ),
    );
  }
}

class TransportationPill extends StatelessWidget {
  final String text;
  final IconData? icon;
  final String? cost;
  final Color textColor;
  final Color borderColor;
  final Color backgroundColor;

  const TransportationPill({
    super.key,
    required this.text,
    this.icon,
    this.cost,
    required this.textColor,
    required this.borderColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minWidth: 60.w,
        maxWidth: 160.w,
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      margin: EdgeInsetsDirectional.only(end: 6.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.r),
        border:
            Border.all(color: borderColor.withValues(alpha: 0.5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor, size: 14.sp),
            SizedBox(width: 4.w),
          ],
          if (cost != null) ...[
            Text(
              "$cost - ",
              style: TextStyle(
                color: borderColor,
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class ArrowIcon extends StatelessWidget {
  final Color color;
  const ArrowIcon({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Icon(Icons.arrow_right_alt, color: color, size: 20.sp),
    );
  }
}
