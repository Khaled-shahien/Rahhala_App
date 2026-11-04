import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:rahhala_app/core/localization/app_messages.dart';
import 'package:rahhala_app/core/utils/app_validators.dart';
import 'package:rahhala_app/l10n/generated/app_localizations.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final ar = lookupAppLocalizations(const Locale('ar'));

  setUp(() => AppMessages.localeResolver = () => const Locale('en'));

  group('validateEmail', () {
    test('requires a value', () {
      expect(AppValidators.validateEmail(null), en.validationEmailRequired);
      expect(AppValidators.validateEmail('   '), en.validationEmailRequired);
    });

    test('rejects malformed addresses', () {
      for (final email in [
        'plain',
        'a@b',
        'a..b@x.com',
        '.a@x.com',
        'a@x..com',
        'a@.x.com',
      ]) {
        expect(AppValidators.validateEmail(email), en.validationEmailInvalid,
            reason: email);
      }
    });

    test('accepts valid addresses, trimming whitespace', () {
      expect(AppValidators.validateEmail(' user.name+tag@mail.co.eg '), isNull);
    });
  });

  group('validatePassword', () {
    test('enforces every rule in order', () {
      expect(AppValidators.validatePassword(''), en.authPasswordRequired);
      expect(AppValidators.validatePassword('Ab1!'),
          en.validationPasswordTooShort);
      expect(AppValidators.validatePassword('abcdefg1!'),
          en.validationPasswordUppercase);
      expect(AppValidators.validatePassword('ABCDEFG1!'),
          en.validationPasswordLowercase);
      expect(AppValidators.validatePassword('Abcdefgh!'),
          en.validationPasswordNumber);
      expect(AppValidators.validatePassword('Abcdefgh1'),
          en.validationPasswordSpecial);
      expect(AppValidators.validatePassword('Abcdefg1!'), isNull);
    });
  });

  group('other validators', () {
    test('name', () {
      expect(AppValidators.validateName(''), en.validationNameRequired);
      expect(AppValidators.validateName('Al'), en.validationNameTooShort);
      expect(AppValidators.validateName('Ali'), isNull);
    });

    test('phone', () {
      expect(AppValidators.validatePhone(''), en.validationPhoneRequired);
      expect(AppValidators.validatePhone('12345'), en.validationPhoneInvalid);
      expect(AppValidators.validatePhone('01012345678'), isNull);
    });

    test('confirm password', () {
      expect(AppValidators.validateConfirmPassword('', 'x'),
          en.validationConfirmPasswordRequired);
      expect(AppValidators.validateConfirmPassword('y', 'x'),
          en.validationPasswordsMismatch);
      expect(AppValidators.validateConfirmPassword('x', 'x'), isNull);
    });

    test('login password only requires a value', () {
      expect(AppValidators.validateLoginPassword(''), en.authPasswordRequired);
      expect(AppValidators.validateLoginPassword('x'), isNull);
    });

    test('dropdown', () {
      expect(AppValidators.validateDropdown(null, 'country'),
          en.validationSelectField('country'));
      expect(AppValidators.validateDropdown('EG', 'country'), isNull);
    });
  });

  test('messages follow the app language', () {
    AppMessages.localeResolver = () => const Locale('ar');
    expect(AppValidators.validateEmail(''), ar.validationEmailRequired);
    expect(
        AppValidators.validatePassword('short'), ar.validationPasswordTooShort);
  });
}
