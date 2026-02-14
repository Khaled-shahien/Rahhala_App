import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A reusable primary button component following Material 3 design principles
class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final Widget? icon;
  final ButtonSize size;
  final ButtonStyle? style;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.icon,
    this.size = ButtonSize.medium,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = style ?? _getDefaultStyle(context);

    return SizedBox(
      width: double.infinity,
      height: size.height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: isLoading
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    SizedBox(width: 8.w),
                  ],
                  Text(
                    text,
                    style: size.textStyle,
                  ),
                ],
              ),
      ),
    );
  }

  ButtonStyle _getDefaultStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: size.paddingHorizontal,
        vertical: size.paddingVertical,
      ),
    );
  }
}

/// Button size configuration
class ButtonSize {
  final double height;
  final double paddingHorizontal;
  final double paddingVertical;
  final TextStyle textStyle;

  const ButtonSize({
    required this.height,
    required this.paddingHorizontal,
    required this.paddingVertical,
    required this.textStyle,
  });

  static const small = ButtonSize(
    height: 40,
    paddingHorizontal: 16,
    paddingVertical: 8,
    textStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  );

  static const medium = ButtonSize(
    height: 48,
    paddingHorizontal: 24,
    paddingVertical: 12,
    textStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
  );

  static const large = ButtonSize(
    height: 56,
    paddingHorizontal: 32,
    paddingVertical: 16,
    textStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
    ),
  );
}
