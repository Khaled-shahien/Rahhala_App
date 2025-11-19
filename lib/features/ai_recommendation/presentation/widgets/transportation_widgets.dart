import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TransportationRoute extends StatelessWidget {
  final String from;
  final String to;
  final String method;
  final String cost;
  final Color textColor;
  final Color borderColor;
  final Color backgroundColor;

  const TransportationRoute({
    super.key,
    required this.from,
    required this.to,
    required this.method,
    required this.cost,
    required this.textColor,
    required this.borderColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
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
    final costText =
        isFree ? null : (cost.contains("EGP") ? cost : "$cost EGP");

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
              textColor: textColor,
              borderColor: borderColor,
              backgroundColor: backgroundColor,
            ),
            ArrowIcon(color: borderColor),
            TransportationPill(
              text: method,
              cost: costText,
              icon: icon,
              textColor: textColor,
              borderColor: borderColor,
              backgroundColor: backgroundColor,
            ),
            ArrowIcon(color: borderColor),
            TransportationPill(
              text: to,
              icon: null,
              textColor: textColor,
              borderColor: borderColor,
              backgroundColor: backgroundColor,
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
        maxWidth: 140.w,
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      margin: EdgeInsets.only(right: 6.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            Flexible(
              child: Text(
                cost!,
                style: TextStyle(
                  color: borderColor,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            SizedBox(width: 4.w),
          ],
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
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
