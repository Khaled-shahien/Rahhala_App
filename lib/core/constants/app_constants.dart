// lib/core/constants/app_constants.dart

import 'package:flutter/material.dart';

/// General app constants
class AppConstants {
  AppConstants._();

  // ==================== App Info ====================

  /// App name
  static const String appName = 'Rahhala';

  /// App description
  static const String appDescription = 'Explore amazing destinations';

  /// App version
  static const String appVersion = '1.0.0';

  // ==================== API ====================

  /// API Base URL
  static const String baseUrl = 'https://rahhallaweb2026.runasp.net';

  /// Request timeout
  static const Duration apiTimeout = Duration(seconds: 30);

  /// API Version
  static const String apiVersion = 'v1';

  // ==================== Storage Keys ====================

  /// Auth token storage key
  static const String tokenKey = 'auth_token';

  /// Refresh token key
  static const String refreshTokenKey = 'refresh_token';

  /// User data key
  static const String userDataKey = 'user_data';

  /// Language key
  static const String languageKey = 'language';

  /// Theme mode key (light/dark)
  static const String themeKey = 'theme_mode';

  /// Onboarding shown key
  static const String onboardingShownKey = 'onboarding_shown';

  /// Notifications enabled key
  static const String notificationsEnabledKey = 'notifications_enabled';

  // ==================== Validation ====================

  /// Minimum password length
  static const int minPasswordLength = 8;

  /// Maximum password length
  static const int maxPasswordLength = 50;

  /// Minimum name length
  static const int minNameLength = 2;

  /// Maximum name length
  static const int maxNameLength = 50;

  /// OTP code length
  static const int otpLength = 6;

  /// OTP expiry duration (in minutes)
  static const int otpExpiryMinutes = 5;

  // ==================== UI Constants ====================

  /// Default border radius
  static const double defaultBorderRadius = 12.0;

  /// Default padding
  static const double defaultPadding = 16.0;

  /// Default spacing between elements
  static const double defaultSpacing = 8.0;

  /// Button height
  static const double buttonHeight = 50.0;

  /// Text field height
  static const double textFieldHeight = 56.0;

  /// Default icon size
  static const double defaultIconSize = 24.0;

  /// Large icon size
  static const double largeIconSize = 32.0;

  /// Small icon size
  static const double smallIconSize = 16.0;

  // ==================== Animation ====================

  /// Default animation duration
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);

  /// Fast animation duration
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);

  /// Slow animation duration
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);

  /// Default animation curve
  static const animationCurve = Curves.easeInOutCubic;

  // ==================== Image ====================

  /// Maximum image size (in megabytes)
  static const int maxImageSizeMB = 5;

  /// Compressed image quality (0-100)
  static const int imageQuality = 85;

  /// Maximum image width
  static const int maxImageWidth = 1920;

  /// Maximum image height
  static const int maxImageHeight = 1080;

  // ==================== Pagination ====================

  /// Items per page
  static const int itemsPerPage = 20;

  /// Initial load count
  static const int initialLoadCount = 10;

  // ==================== Features ====================

  /// Enable debug mode
  static const bool debugMode = true; // Change to false in production

  /// Enable logging
  static const bool enableLogging = true;

  /// Enable analytics
  static const bool enableAnalytics = false;

  /// Enable crash reporting
  static const bool enableCrashReporting = false;

  // ==================== Social Media ====================

  /// Facebook App ID (for social login)
  static const String facebookAppId = '';

  /// Google Client ID
  static const String googleClientId = '';

  /// Apple Service ID
  static const String appleServiceId = '';

  // ==================== Contact ====================

  /// Support email
  static const String supportEmail = 'support@rahhala.com';

  /// Support phone number
  static const String supportPhone = '+1234567890';

  /// Website
  static const String website = 'https://rahhala.com';

  /// Facebook page
  static const String facebookPage = 'https://facebook.com/rahhala';

  /// Twitter handle
  static const String twitterHandle = '@rahhala';

  /// Instagram handle
  static const String instagramHandle = '@rahhala';

  // ==================== Policies ====================

  /// Privacy policy URL
  static const String privacyPolicyUrl = 'https://rahhala.com/privacy';

  /// Terms of service URL
  static const String termsOfServiceUrl = 'https://rahhala.com/terms';

  /// FAQ URL
  static const String faqUrl = 'https://rahhala.com/faq';

  // ==================== Date & Time ====================

  /// Default date format
  static const String defaultDateFormat = 'dd/MM/yyyy';

  /// Default time format
  static const String defaultTimeFormat = 'HH:mm';

  /// Default date and time format
  static const String defaultDateTimeFormat = 'dd/MM/yyyy HH:mm';

  // ==================== Language & Localization ====================

  /// Supported languages
  static const List<String> supportedLanguages = ['en', 'ar'];

  /// Default language
  static const String defaultLanguage = 'en';

  /// Is default language RTL?
  static const bool defaultIsRTL = false;

  // ==================== Map & Location ====================

  /// Default map zoom level
  static const double defaultMapZoom = 12.0;

  /// Location accuracy (in meters)
  static const double locationAccuracy = 100.0;

  /// Location request timeout
  static const Duration locationTimeout = Duration(seconds: 10);

  // ==================== Search ====================

  /// Minimum search length
  static const int minSearchLength = 2;

  /// Search debounce (in milliseconds)
  static const int searchDebounceMs = 500;

  /// Initial search results count
  static const int initialSearchResults = 10;

  // ==================== Cache ====================

  /// Default cache duration
  static const Duration defaultCacheDuration = Duration(hours: 24);

  /// Image cache duration
  static const Duration imageCacheDuration = Duration(days: 7);

  /// Maximum cache size (in megabytes)
  static const int maxCacheSizeMB = 100;

  // ==================== Network ====================

  /// Maximum retry attempts
  static const int maxRetryAttempts = 3;

  /// Retry delay duration
  static const Duration retryDelay = Duration(seconds: 2);

  /// Connection check interval
  static const Duration connectionCheckInterval = Duration(seconds: 5);
}

/// Default error messages
class ErrorMessages {
  ErrorMessages._();

  static const String noInternet = 'No internet connection';
  static const String serverError = 'Server error occurred';
  static const String unknownError = 'An unexpected error occurred';
  static const String timeoutError = 'Request timeout';
  static const String invalidCredentials = 'Invalid credentials';
  static const String invalidEmail = 'Invalid email address';
  static const String weakPassword = 'Password is too weak';
  static const String passwordMismatch = 'Passwords do not match';
  static const String userNotFound = 'User not found';
  static const String emailAlreadyExists = 'Email already exists';
  static const String invalidOtp = 'Invalid verification code';
  static const String otpExpired = 'Verification code has expired';
}

/// Default success messages
class SuccessMessages {
  SuccessMessages._();

  static const String loginSuccess = 'Login successful';
  static const String signupSuccess = 'Account created successfully';
  static const String profileUpdated = 'Profile updated successfully';
  static const String passwordChanged = 'Password changed successfully';
  static const String otpSent = 'Verification code sent';
  static const String emailVerified = 'Email verified successfully';
}

/// Debug information
class DebugInfo {
  DebugInfo._();

  static const bool enableDebugPrint = true;
  static const bool enableNetworkLogs = true;
  static const bool enableBlocLogs = true;
  static const bool enableNavigationLogs = true;
}
