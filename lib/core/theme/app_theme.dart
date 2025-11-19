import 'package:flutter/material.dart';

class ThemeColor {
  static const Color primaryColor = Color(0xffCDAE8A);
  static const Color darkGreenColor = Color(0xFF006400);
  static const Color charcoalColor = Color(0xFF36454F);
  static const Color neutralGrayColor = Color(0xFF8E8E8E);
  static const Color bgColor = Color(0xFFF5F5F5);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color amber = Color(0xFFFFC107);
  static const Color orange = Color(0xFFFF9800);
}

class Style {
  static const TextStyle textStyle18 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle textStyle16 = TextStyle(
    fontSize: 16,
  );
  static const TextStyle textStyle14 = TextStyle(
    fontSize: 14,
  );
  static const TextStyle textStyle12 = TextStyle(
    fontSize: 12,
  );
}

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: ThemeColor.primaryColor,
    scaffoldBackgroundColor: Colors.white,

    colorScheme: ColorScheme.fromSeed(
      seedColor: ThemeColor.primaryColor,
      primary: ThemeColor.primaryColor,
      secondary: ThemeColor.charcoalColor,
      error: ThemeColor.errorColor,
      brightness: Brightness.light,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: ThemeColor.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    textButtonTheme: const TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(ThemeColor.primaryColor),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      
      labelStyle: const TextStyle(
        color: ThemeColor.neutralGrayColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      
      floatingLabelStyle: const TextStyle(
        color: ThemeColor.primaryColor, 
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      
      hintStyle: TextStyle(
        color: Colors.grey.shade500,
        fontSize: 14,
      ),
      
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: ThemeColor.primaryColor, width: 1.6),
      ),
      
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ThemeColor.errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ThemeColor.errorColor, width: 1.6),
      ),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      prefixIconColor: ThemeColor.neutralGrayColor,
      suffixIconColor: ThemeColor.neutralGrayColor,
    ),

    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: ThemeColor.primaryColor,
      selectionColor: Color(0x33CDAE8A),
      selectionHandleColor: ThemeColor.primaryColor,
    ),

    iconTheme: const IconThemeData(color: ThemeColor.charcoalColor),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: ThemeColor.charcoalColor,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
