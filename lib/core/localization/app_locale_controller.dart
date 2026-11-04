import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocaleController extends ChangeNotifier {
  AppLocaleController({
    required SharedPreferences preferences,
  }) : _preferences = preferences;

  static const Locale fallbackLocale = Locale('en');
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
  ];

  static const String _languageCodeKey = 'preferred_language_code';

  final SharedPreferences _preferences;

  Locale _locale = fallbackLocale;
  bool _isInitialized = false;

  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';

  Future<void> initialize({Locale? deviceLocale}) async {
    if (_isInitialized) {
      return;
    }

    final savedLanguageCode = _preferences.getString(_languageCodeKey);

    if (savedLanguageCode != null && savedLanguageCode.isNotEmpty) {
      _locale = _fromLanguageCode(savedLanguageCode);
    } else {
      final resolvedDeviceLocale = _resolveSupportedLocale(
          deviceLocale ?? PlatformDispatcher.instance.locale);
      _locale = resolvedDeviceLocale;
    }

    _isInitialized = true;
  }

  Future<void> setLocale(Locale locale) async {
    final target = _resolveSupportedLocale(locale);
    if (target == _locale) {
      return;
    }

    _locale = target;
    await _preferences.setString(_languageCodeKey, target.languageCode);
    notifyListeners();
  }

  Locale _fromLanguageCode(String languageCode) {
    return supportedLocales.firstWhere(
      (locale) => locale.languageCode == languageCode,
      orElse: () => fallbackLocale,
    );
  }

  Locale _resolveSupportedLocale(Locale locale) {
    return supportedLocales.firstWhere(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
      orElse: () => fallbackLocale,
    );
  }
}
