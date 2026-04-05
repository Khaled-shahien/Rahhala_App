// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Rahhala App';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonBack => 'Go Back';

  @override
  String get commonError => 'Error';

  @override
  String get commonSuccess => 'Success';

  @override
  String get commonComingSoon => 'Coming Soon...';

  @override
  String get commonGotIt => 'Got it';

  @override
  String get commonUnknownError => 'Unknown error';

  @override
  String get routerPageNotFound => 'Page Not Found';

  @override
  String get routerGoHome => 'Go Home';

  @override
  String routerFeatureTitle(Object featureName) {
    return '$featureName';
  }

  @override
  String routerFeatureUnderDevelopment(Object featureName) {
    return '$featureName - Coming soon!';
  }

  @override
  String get routerTripPlanner => 'Trip Planner';

  @override
  String get routerDestinations => 'Destinations';

  @override
  String routerDestinationDetails(Object id) {
    return 'Destination Details ($id)';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileNoEmail => 'No email';

  @override
  String get profileAccount => 'Account';

  @override
  String get profilePreferences => 'Preferences';

  @override
  String get profileSupport => 'Support';

  @override
  String get profileDangerZone => 'Danger zone';

  @override
  String get profileEdit => 'Edit profile';

  @override
  String get profilePlanHistory => 'Plan History';

  @override
  String get profileChangePassword => 'Change password';

  @override
  String get profileNotification => 'Notification';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profilePlans => 'Plans';

  @override
  String get profileAppearance => 'Appearance';

  @override
  String get profileHelpSupport => 'Help and Support';

  @override
  String get profileLogout => 'Logout';

  @override
  String get profileDeleteAccount => 'Delete Account';

  @override
  String get profileDeleteAccountConfirm => 'Delete your account permanently?';

  @override
  String get profileLogoutConfirm => 'Log out from your account?';

  @override
  String get profileDeleteAction => 'Delete';

  @override
  String get profileLogoutAction => 'Logout';

  @override
  String get profileLanguageBottomSheetTitle => 'Choose app language';

  @override
  String get profileLanguageBottomSheetSubtitle =>
      'Changes are applied instantly';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get homeWelcomeGuest => 'Welcome, Guest!';

  @override
  String homeWelcomeUser(Object name) {
    return 'Hi, $name!';
  }

  @override
  String get homeExploreDestinations => 'Explore amazing destinations';

  @override
  String get homeWishlist => 'Wishlist';

  @override
  String get homeSearch => 'Search';

  @override
  String get homeWishlistSoon => 'Wishlist page - Coming soon!';

  @override
  String get homeSearchSoon => 'Search - Coming soon!';

  @override
  String get navHome => 'Home';

  @override
  String get navWishlist => 'Wish list';

  @override
  String get navProfile => 'Profile';

  @override
  String get homePageContent => 'Home Page Content';

  @override
  String homeComingSoonShort(Object title) {
    return '$title - Coming soon';
  }

  @override
  String get splashSubtitle => 'Your Travel Companion';
}
