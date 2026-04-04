import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';

class ProfileListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool trailingChevron;
  final Color? tint;

  const ProfileListTile({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.trailingChevron = true,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final c = tint ?? ThemeColor.primaryColor;
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
      leading: Container(
        width: 42.w,
        height: 42.w,
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: ThemeColor.bgColor),
      ),
      title: Text(title, style: TextStyle(fontSize: 16.sp)),
      trailing: trailingChevron
          ? const Icon(Icons.chevron_right_rounded, color: Colors.grey)
          : null,
      onTap: onTap,
    );
  }
}
