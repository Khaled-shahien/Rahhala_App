import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomExpansionTile extends StatelessWidget {
  final Widget title;
  final List<Widget> children;
  final EdgeInsetsGeometry tilePadding;
  final EdgeInsetsGeometry childrenPadding;
  final Color iconColor;
  final Color collapsedIconColor;
  final Widget? trailing;
  final Widget? leading;

  const CustomExpansionTile({
    super.key,
    required this.title,
    required this.children,
    this.tilePadding = EdgeInsets.zero,
    this.childrenPadding = EdgeInsets.zero,
    required this.iconColor,
    required this.collapsedIconColor,
    this.trailing,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: tilePadding,
        childrenPadding: childrenPadding,
        trailing: trailing,
        leading: leading,
        title: title,
        iconColor: iconColor,
        collapsedIconColor: collapsedIconColor,
        children: children,
      ),
    );
  }
}

class CostBadge extends StatelessWidget {
  final String cost;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final Color iconColor;

  const CostBadge({
    super.key,
    required this.cost,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: borderColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.money_rounded, size: 13.sp, color: iconColor),
          SizedBox(width: 3.w),
          Text(
            cost.contains("EGP") ? cost : "$cost EGP",
            style: TextStyle(
              color: textColor,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class PillWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const PillWidget({
    super.key,
    required this.icon,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(25.r),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 16.sp),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class NumberCircle extends StatelessWidget {
  final int number;
  final Color backgroundColor;
  final Color textColor;

  const NumberCircle({
    super.key,
    required this.number,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: TextStyle(
          color: textColor,
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
