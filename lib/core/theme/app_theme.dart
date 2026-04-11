import 'package:flutter/material.dart';

/// Color palette for the Rahhala travel application
class ThemeColor {
  // Primary brand colors
  static const Color primary = Color(0xFFCDAE8A); // Gold/Bronze accent
  static const Color onPrimary = Color(0xFFFFFFFF); // Text on primary

  // Secondary colors
  static const Color secondary = Color(0xFF36454F); // Charcoal
  static const Color onSecondary = Color(0xFFFFFFFF); // Text on secondary

  // Surface and background
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1F1F1F);
  static const Color background = Color(0xFFF8F9FA);
  static const Color onBackground = Color(0xFF1F1F1F);

  // Error colors
  static const Color error = Color(0xFFB00020);
  static const Color onError = Color(0xFFFFFFFF);

  // Additional semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Neutral colors
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFEEEEEE);
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral500 = Color(0xFF9E9E9E);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral700 = Color(0xFF616161);
  static const Color neutral800 = Color(0xFF424242);
  static const Color neutral900 = Color(0xFF212121);

  // Deprecated colors - for backward compatibility
  static const Color primaryColor = primary;
  static const Color darkGreenColor = Color(0xFF006400);
  static const Color charcoalColor = secondary;
  static const Color neutralGrayColor = neutral500;
  static const Color bgColor = background;
  static const Color errorColor = error;
  static const Color amber = Color(0xFFFFC107);
  static const Color orange = Color(0xFFFF9800);
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
      background: ThemeColor.background,
      onBackground: ThemeColor.onBackground,
      error: ThemeColor.error,
      onError: ThemeColor.onError,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ThemeColor.primary,
      foregroundColor: ThemeColor.onPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.titleLarge,
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
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: ColorScheme.fromSeed(
      seedColor: ThemeColor.primary,
      primary: ThemeColor.primary,
      onPrimary: ThemeColor.onPrimary,
      secondary: ThemeColor.secondary,
      onSecondary: ThemeColor.onSecondary,
      surface: const Color(0xFF1E1E1E), // لون الكروت في الضلمة
      onSurface: Colors.white,
      background: const Color(0xFF121212),
      onBackground: Colors.white,
      error: ThemeColor.error,
      onError: ThemeColor.onError,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1F1F1F),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.titleLarge,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
      hintStyle: const TextStyle(color: ThemeColor.neutral500),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3D3D3D))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ThemeColor.primary, width: 2)),
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFF1E1E1E),
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
