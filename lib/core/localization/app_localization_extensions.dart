import 'package:flutter/material.dart';
import 'package:rahhala_app/l10n/generated/app_localizations.dart';

extension AppLocalizationBuildContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
