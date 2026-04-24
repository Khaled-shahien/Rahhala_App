
import 'package:rahhala_app/l10n/generated/app_localizations.dart';

class OnboardingModel {
  final String title;
  final String subtitle;
  final String description;
  final List<String> images; 

  OnboardingModel({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.images,
  });
}

List<OnboardingModel> getOnboardingPages(AppLocalizations l10n) => [
  
  OnboardingModel(
    title: l10n.onboardingTitle1,
    subtitle: l10n.onboardingSubtitle1,
    description: l10n.onboardingDesc1,
    images: [
      'assets/images/1.png', 
      'assets/images/2.png', 
      'assets/images/3.png', 

    ],
  ),

  OnboardingModel(
    title: l10n.onboardingTitle2,
    subtitle: l10n.onboardingSubtitle2,
    description: l10n.onboardingDesc2,
    images: [
      'assets/images/Rectangle 119.png', 
      'assets/images/Rectangle 120.png', 
      'assets/images/Rectangle 121.png', 
    ],
  ),

  OnboardingModel(
    title: l10n.onboardingTitle3,
    subtitle: l10n.onboardingSubtitle3,
    description: l10n.onboardingDesc3,
    images: [
      'assets/images/7.png', 
      'assets/images/8.png', 
      'assets/images/9.png', 
    ],
  ),
];

