import 'package:flutter/material.dart';
import 'package:rahhala_app/core/constants/app_colors.dart';

/// Color palette for the Rahhala travel application
class ThemeColor {
  // Primary brand colors
  static const Color primary = AppColors.primary; // Gold/Bronze accent
  static const Color onPrimary = AppColors.textOnPrimary; // Text on primary

  // Secondary colors
  static const Color secondary = AppColors.charcoal; // Charcoal
  static const Color onSecondary = AppColors.textOnPrimary; // Text on secondary

  // Surface and background
  static const Color surface = AppColors.backgroundWhite;
  static const Color onSurface = AppColors.textPrimaryDark;
  static const Color background = AppColors.backgroundLight;
  static const Color onBackground = AppColors.textPrimaryDark;

  // Error colors
  static const Color error = AppColors.materialError;
  static const Color onError = AppColors.textOnPrimary;

  // Additional semantic colors
  static const Color success = AppColors.success;
  static const Color warning = AppColors.orange;
  static const Color info = AppColors.info;

  // Neutral colors
  static const Color neutral50 = AppColors.cardBackground;
  static const Color neutral100 = AppColors.backgroundGray;
  static const Color neutral200 = AppColors.borderExtraLight;
  static const Color neutral300 = AppColors.borderLight;
  static const Color neutral400 = AppColors.borderMedium;
  static const Color neutral500 = AppColors.inputPlaceholder;
  static const Color neutral600 = AppColors.textSecondary;
  static const Color neutral700 = AppColors.neutral700;
  static const Color neutral800 = AppColors.neutral800;
  static const Color neutral900 = AppColors.textPrimary;

  // Deprecated colors - for backward compatibility
  static const Color primaryColor = primary;
  static const Color darkGreenColor = AppColors.darkGreen;
  static const Color charcoalColor = secondary;
  static const Color neutralGrayColor = neutral500;
  static const Color bgColor = background;
  static const Color errorColor = error;
  static const Color amber = AppColors.amber;
  static const Color orange = AppColors.orange;
}

class AppTypography {
  static const TextStyle displayLarge = TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      height: 1.12);
  static const TextStyle displayMedium = TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.16);
  static const TextStyle displaySmall = TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.22);
  static const TextStyle headlineLarge = TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.25);
  static const TextStyle headlineMedium = TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.29);
  static const TextStyle headlineSmall = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.33);
  static const TextStyle titleLarge = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.27);
  static const TextStyle titleMedium = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      height: 1.50);
  static const TextStyle titleSmall = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43);
  static const TextStyle bodyLarge = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      height: 1.50);
  static const TextStyle bodyMedium = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.43);
  static const TextStyle bodySmall = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.33);
  static const TextStyle labelLarge = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43);
  static const TextStyle labelMedium = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.33);
  static const TextStyle labelSmall = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.45);

  static const TextStyle textStyle18 = titleLarge;
  static const TextStyle textStyle16 = bodyLarge;
  static const TextStyle textStyle14 = bodyMedium;
  static const TextStyle textStyle12 = bodySmall;
}

class AppTheme {
  /// Light theme configuration
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: ThemeColor.primary,
      primary: ThemeColor.primary,
      onPrimary: ThemeColor.onPrimary,
      secondary: ThemeColor.secondary,
      onSecondary: ThemeColor.onSecondary,
      surface: ThemeColor.surface,
      onSurface: ThemeColor.onSurface,
      // surface already set above
      // onSurface already set above
      error: ThemeColor.error,
      onError: ThemeColor.onError,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ThemeColor.primary,
      foregroundColor: ThemeColor.onPrimary,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: ThemeColor.onPrimary),
      actionsIconTheme: IconThemeData(color: ThemeColor.onPrimary),
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: ThemeColor.onPrimary,
      ),
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ThemeColor.neutral100,
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ThemeColor.neutral300)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ThemeColor.primary, width: 2)),
    ),
    textTheme: const TextTheme(
      displayLarge: AppTypography.displayLarge,
      bodyLarge: AppTypography.bodyLarge,
      titleLarge: AppTypography.titleLarge,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: ThemeColor.primary,
      primary: ThemeColor.primary,
      onPrimary: ThemeColor.onPrimary,
      secondary: ThemeColor.secondary,
      onSecondary: ThemeColor.onSecondary,
      surface: AppColors.surfaceDark,
      onSurface: Colors.white,
      // surface already set above
      // onSurface already set above
      error: ThemeColor.error,
      onError: ThemeColor.onError,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ThemeColor.primary,
      foregroundColor: ThemeColor.onPrimary,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: ThemeColor.onPrimary),
      actionsIconTheme: IconThemeData(color: ThemeColor.onPrimary),
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: ThemeColor.onPrimary,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceDarkHigh,
      hintStyle: const TextStyle(color: ThemeColor.neutral500),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineDark)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ThemeColor.primary, width: 2)),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    textTheme: TextTheme(
      displayLarge: AppTypography.displayLarge,
      bodyLarge: AppTypography.bodyLarge.copyWith(color: Colors.white),
      titleLarge: AppTypography.titleLarge.copyWith(color: Colors.white),
    ),
  );
}
