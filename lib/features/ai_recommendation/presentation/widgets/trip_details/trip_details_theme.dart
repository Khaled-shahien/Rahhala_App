import 'package:flutter/material.dart';
import 'package:rahhala_app/core/constants/app_colors.dart';

const Color headerBackgroundColor = Color(0xFFF2E7D5);
const Color brownTextColor = Color(0xFF3E3431);
const Color primaryTextColor = AppColors.darkBrown;
const Color lightBorderColor = AppColors.lightBrown;
const Color locationCardBackgroundColor = AppColors.costBadgeBackground;
const Color screenBackgroundColor = AppColors.screenBackground;
const Color timelineColor = AppColors.lightBrown;
const Color costBadgeBgColor = AppColors.costBadgeBackground;
const Color arrowColor = Color(0xFF008080);

class TripDetailsStrings {
  TripDetailsStrings._();

  static const String save = 'Save trip';
  static const String saving = 'Saving...';
  static const String regenerateTitle = 'Regenerate Trip Plan';
  static const String regenerateBody =
      'Would you like to regenerate the entire trip plan with new suggestions '
      'for all days and activities?';
  static const String cancel = 'Cancel';
  static const String regenerate = 'Regenerate';
  static const String budgetTips = 'Budget tips';
  static const String travelTips = 'Travel tips';
  static const String emergencyContact = 'Emergency Contact';
  static const String noInfo = 'No information available';
  static const String transportRoutes = 'Transportation Routes';
  static const String tripRegenerated = 'Trip plan regenerated successfully!';
  static const String saveFailed = 'Failed to save trip.';
  static const String regenerateFailed = 'Failed to regenerate trip.';
  static const String saveSuccessFallback = 'Trip saved successfully.';
}
