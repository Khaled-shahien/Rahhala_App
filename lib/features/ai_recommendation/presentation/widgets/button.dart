import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final Color? color;
  final double height;

  const NextButton({
    super.key,
    required this.onPressed,
    this.text = 'Next',
    this.color,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEnabled = onPressed != null;

    final Color effectiveColor = color ?? const Color(0xFFA88866);
    final disabledColor = theme.colorScheme.onSurface.withValues(
      alpha: isDark ? 0.18 : 0.12,
    );
    final foregroundColor = isEnabled
        ? Colors.white
        : theme.colorScheme.onSurface.withValues(alpha: 0.38);

    return Container(
      width: double.infinity,
      height: height.h,
      decoration: BoxDecoration(
        color: isEnabled ? effectiveColor : disabledColor,
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: effectiveColor.withValues(alpha: isDark ? 0.15 : 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: foregroundColor,
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
