import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';
import 'app_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle cairoRegular({
    double? fontSize,
    Color? color,
    double? height,
    TextDecoration? decoration,
  }) =>
      TextStyle(
        fontFamily: AppFonts.cairo,
        fontWeight: FontWeight.w400,
        fontSize: fontSize?.sp ?? 14.sp,
        color: color ?? AppColors.textPrimary,
        height: height,
        decoration: decoration,
      );

  static TextStyle cairoMedium({
    double? fontSize,
    Color? color,
    double? height,
    TextDecoration? decoration,
  }) =>
      TextStyle(
        fontFamily: AppFonts.cairo,
        fontWeight: FontWeight.w500,
        fontSize: fontSize?.sp ?? 14.sp,
        color: color ?? AppColors.textPrimary,
        height: height,
        decoration: decoration,
      );

  static TextStyle cairoSemiBold({
    double? fontSize,
    Color? color,
    double? height,
    TextDecoration? decoration,
  }) =>
      TextStyle(
        fontFamily: AppFonts.cairo,
        fontWeight: FontWeight.w600,
        fontSize: fontSize?.sp ?? 14.sp,
        color: color ?? AppColors.textPrimary,
        height: height,
        decoration: decoration,
      );

  static TextStyle cairoBold({
    double? fontSize,
    Color? color,
    double? height,
    TextDecoration? decoration,
  }) =>
      TextStyle(
        fontFamily: AppFonts.cairo,
        fontWeight: FontWeight.w700,
        fontSize: fontSize?.sp ?? 14.sp,
        color: color ?? AppColors.textPrimary,
        height: height,
        decoration: decoration,
      );

  static TextStyle displayLarge = cairoBold(fontSize: 32, height: 1.2);
  static TextStyle displayMedium = cairoBold(fontSize: 28, height: 1.3);
  static TextStyle displaySmall = cairoSemiBold(fontSize: 24, height: 1.3);

  static TextStyle headline1 = cairoSemiBold(fontSize: 21, height: 1.4);
  static TextStyle headline2 = cairoSemiBold(fontSize: 18, height: 1.4);
  static TextStyle headline3 = cairoSemiBold(fontSize: 16, height: 1.4);

  static TextStyle bodyLarge = cairoRegular(fontSize: 16, height: 1.5);
  static TextStyle bodyMedium = cairoRegular(fontSize: 14, height: 1.5);
  static TextStyle bodySmall =
      cairoRegular(fontSize: 12, color: AppColors.textSecondary, height: 1.5);

  static TextStyle labelLarge = cairoSemiBold(fontSize: 14);
  static TextStyle labelMedium = cairoMedium(fontSize: 12);
  static TextStyle labelSmall =
      cairoMedium(fontSize: 10, color: AppColors.textSecondary);
  static TextStyle caption =
      cairoRegular(fontSize: 12, color: AppColors.textSecondary);
  static TextStyle overline =
      cairoMedium(fontSize: 10, color: AppColors.textSecondary);

  static TextStyle buttonText =
      cairoSemiBold(fontSize: 16, color: AppColors.buttonTextOnPrimary);
  static TextStyle buttonTextSecondary =
      cairoSemiBold(fontSize: 14, color: AppColors.primary);

  static TextStyle hintText =
      cairoRegular(fontSize: 14, color: AppColors.inputPlaceholder);
  static TextStyle labelText =
      cairoMedium(fontSize: 14, color: AppColors.neutralGray);
  static TextStyle labelTextFocused =
      cairoSemiBold(fontSize: 14, color: AppColors.primary);
  static TextStyle errorText =
      cairoMedium(fontSize: 12, color: AppColors.error);

  static TextStyle appBarTitle =
      cairoSemiBold(fontSize: 18, color: AppColors.textOnPrimary);
  static TextStyle appBarSubtitle =
      cairoRegular(fontSize: 14, color: AppColors.textOnPrimary);

  static TextStyle cardTitle = cairoSemiBold(fontSize: 16);
  static TextStyle cardBody =
      cairoRegular(fontSize: 14, color: AppColors.textSecondary);
  static TextStyle cardCaption =
      cairoRegular(fontSize: 12, color: AppColors.textSecondary);

  static TextStyle dialogTitle = cairoSemiBold(fontSize: 18);
  static TextStyle dialogBody =
      cairoRegular(fontSize: 14, color: AppColors.textSecondary);

  static TextStyle priceLarge =
      cairoBold(fontSize: 24, color: AppColors.primary);
  static TextStyle priceMedium =
      cairoSemiBold(fontSize: 18, color: AppColors.primary);
  static TextStyle priceSmall =
      cairoSemiBold(fontSize: 14, color: AppColors.primary);

  // Additional semantic text styles
  static TextStyle heading =
      cairoBold(fontSize: 26, height: 1.2, color: Colors.black);
  static TextStyle subHeading =
      cairoMedium(fontSize: 16, height: 1.4, color: Colors.black);
  static TextStyle body =
      cairoRegular(fontSize: 14, height: 1.5, color: Colors.grey.shade700);
  static TextStyle button =
      cairoBold(fontSize: 24, height: 1.0, color: Colors.white);
  static TextStyle dayCount =
      cairoBold(fontSize: 18, height: 1.0, color: Colors.black);
  static TextStyle dayLabel =
      cairoRegular(fontSize: 26, height: 1.0, color: Colors.black87);
}
