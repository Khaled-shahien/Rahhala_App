import 'package:rahhala_app/core/localization/app_messages.dart';
import 'package:rahhala_app/l10n/generated/app_localizations.dart';

/// Form validators. Messages are localized in the current app language.
class AppValidators {
  AppValidators._();

  static AppLocalizations get _l10n => AppMessages.current;

  static final RegExp _emailRegex = RegExp(
    r'^[A-Z0-9._%+-]+@(?:[A-Z0-9-]+\.)+[A-Z]{2,}$',
    caseSensitive: false,
  );

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return _l10n.validationNameRequired;
    }
    if (value.trim().length < 3) {
      return _l10n.validationNameTooShort;
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return _l10n.validationEmailRequired;
    }
    final email = value.trim();
    final hasInvalidDots = email.contains('..') ||
        email
            .split('@')
            .any((part) => part.startsWith('.') || part.endsWith('.'));
    if (!_emailRegex.hasMatch(email) || hasInvalidDots) {
      return _l10n.validationEmailInvalid;
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return _l10n.validationPhoneRequired;
    }
    if (value.trim().length < 10) {
      return _l10n.validationPhoneInvalid;
    }
    return null;
  }

  static String? validatePassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return _l10n.authPasswordRequired;
    if (v.length < 8) return _l10n.validationPasswordTooShort;
    if (!RegExp(r'[A-Z]').hasMatch(v)) return _l10n.validationPasswordUppercase;
    if (!RegExp(r'[a-z]').hasMatch(v)) return _l10n.validationPasswordLowercase;
    if (!RegExp(r'\d').hasMatch(v)) return _l10n.validationPasswordNumber;
    if (!RegExp(r'[^A-Za-z0-9\s]').hasMatch(v)) {
      return _l10n.validationPasswordSpecial;
    }
    return null;
  }

  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) return _l10n.authPasswordRequired;
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return _l10n.validationConfirmPasswordRequired;
    }
    if (value != password) return _l10n.validationPasswordsMismatch;
    return null;
  }

  static String? validateDropdown(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return _l10n.validationSelectField(fieldName);
    }
    return null;
  }
}
