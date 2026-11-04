import 'dart:ui';

import 'package:rahhala_app/l10n/generated/app_localizations.dart';

/// Context-free access to localized strings for the data and domain layers.
///
/// Cubits and repositories produce user-facing messages (for example,
/// failure messages) without a [BuildContext]. They read the current app
/// locale through [localeResolver], which the service locator wires to
/// `AppLocaleController`.
class AppMessages {
  AppMessages._();

  static const List<String> _supportedLanguageCodes = <String>['en', 'ar'];

  /// Returns the locale the app is currently displayed in.
  static Locale Function() localeResolver =
      () => PlatformDispatcher.instance.locale;

  /// Localized strings for the current app locale. Falls back to English for
  /// unsupported locales.
  static AppLocalizations get current {
    final locale = localeResolver();
    final code = _supportedLanguageCodes.contains(locale.languageCode)
        ? locale.languageCode
        : 'en';
    return lookupAppLocalizations(Locale(code));
  }
}
