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
  String get commonOr => 'Or';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonLogin => 'Login';

  @override
  String get commonTryAgain => 'Try Again';

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
  String get splashAppName => 'Rahhala';

  @override
  String get splashSubtitle => 'Your Travel Companion';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Start';

  @override
  String get onboardingTagline => 'Thoughtfully crafted journeys, just for you';

  @override
  String get onboardingTitle1 => 'Discover';

  @override
  String get onboardingSubtitle1 => 'Amazing\nDestinations';

  @override
  String get onboardingDesc1 =>
      'From the Nile to the desert — your\nEgyptian journey begins.';

  @override
  String get onboardingTitle2 => 'Designing';

  @override
  String get onboardingSubtitle2 => 'Your Trip';

  @override
  String get onboardingDesc2 =>
      'Finding destinations and experiences\nthat match your vibe.';

  @override
  String get onboardingTitle3 => 'Ready to';

  @override
  String get onboardingSubtitle3 => 'Explore ?';

  @override
  String get onboardingDesc3 =>
      'Your personalized adventure awaits —\nlet\'s start the journey!';

  @override
  String get authWelcomeBackTitle => 'Welcome Back';

  @override
  String get authWelcomeBackSubtitle =>
      'Log in to continue exploring curated trips.';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'Enter your email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordHint => 'Enter your password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authForgotPassword => 'Forgot Password?';

  @override
  String get authLoggingIn => 'Logging In...';

  @override
  String get authLogIn => 'Log In';

  @override
  String get authWelcomeBackNotifTitle => 'Welcome Back';

  @override
  String get authWelcomeBackNotifMessage =>
      'Let\'s explore something new today.';

  @override
  String authWelcomeBackUser(Object name) {
    return 'Welcome Back, $name!';
  }

  @override
  String get authSecureSignIn => 'Secure sign-in to continue your journey.';

  @override
  String get authCreateAccountTitle => 'Create Account';

  @override
  String get authCreateAccountSubtitle =>
      'Fill in your information below to sign up';

  @override
  String get authFullNameLabel => 'Full Name';

  @override
  String get authFullNameHint => 'Enter your full name';

  @override
  String get authPhoneLabel => 'Phone Number';

  @override
  String get authPhoneHint => 'Enter your phone number';

  @override
  String get authConfirmPasswordLabel => 'Confirm Password';

  @override
  String get authConfirmPasswordHint => 'Re-enter your password';

  @override
  String get authCountryLabel => 'Country';

  @override
  String get authCountryHint => 'Select your country';

  @override
  String get authCreatingAccount => 'Creating...';

  @override
  String get authCreateAccount => 'Create Account';

  @override
  String get authAlreadyHaveAccount => 'Already have an account?';

  @override
  String get authSignUp => 'Sign Up';

  @override
  String get authGuest => 'Guest';

  @override
  String get authGetStarted => 'Get Started';

  @override
  String get authWelcomeSlogan => 'Every place has a story..Start yours today!';

  @override
  String get authDontHaveAccount => 'Don\'t have an account?';

  @override
  String get authForgotPasswordTitle => 'Forgot Password';

  @override
  String get authForgotPasswordDesc =>
      'Enter your email address below and we\'ll send you a verification code to reset your password.';

  @override
  String get authEmailAddress => 'Email Address';

  @override
  String get authSendingCode => 'Sending...';

  @override
  String get authSendCode => 'Send Code';

  @override
  String get authRememberedPassword => 'Remembered your password?';

  @override
  String get authBackToLogin => 'Back to Login';

  @override
  String get authVerifyCodeTitle => 'Verify Code';

  @override
  String get authVerifyCodeSignUpDesc =>
      'Enter the 6-digit verification code sent to your email to activate your account.';

  @override
  String get authVerifyCodeResetDesc =>
      'Enter the 6-digit verification code sent to your email to reset your password.';

  @override
  String get authVerified => 'Verified';

  @override
  String get authEnterOtp => 'Please enter the 6-digit code.';

  @override
  String get authContinue => 'Continue';

  @override
  String get authResetPasswordTitle => 'Reset Password';

  @override
  String get authResetPasswordHint =>
      'Use 8+ chars with upper/lowercase, number & symbol';

  @override
  String get authNewPassword => 'New Password';

  @override
  String get authNewPasswordHint => 'Enter new password';

  @override
  String get authConfirmNewPassword => 'Confirm new password';

  @override
  String get authConfirmNewPasswordHint => 'Re-enter new password';

  @override
  String get authResetting => 'Resetting...';

  @override
  String get authResetPassword => 'Reset Password';

  @override
  String get authUpdating => 'Updating...';

  @override
  String get authUpdateAccountPassword => 'Update your account password';

  @override
  String get authNewPasswordMustDiffer =>
      'Your new password must be different from previous used password';

  @override
  String get authCurrentPassword => 'Current password';

  @override
  String get authCurrentPasswordHint => 'Enter current password';

  @override
  String get authPasswordRequired => 'Password is required';

  @override
  String get passwordRule8Chars => '8 or more characters';

  @override
  String get passwordRuleUppercase => 'At least 1 uppercase letter';

  @override
  String get passwordRuleLowercase => 'At least 1 lowercase letter';

  @override
  String get passwordRuleNumber => 'At least 1 number';

  @override
  String get passwordRuleSpecial => 'At least 1 special character';

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
  String get tripTypeSelectTitle => 'Select Trip Type';

  @override
  String get tripTypeSelectSubtitle => 'Choose how you want to plan your trip';

  @override
  String get tripTypeCustom => 'Custom Trip';

  @override
  String get tripTypeCustomDesc =>
      'Plan your trip yourself with full control over every detail';

  @override
  String get tripTypeGeneral => 'General Trip';

  @override
  String get tripTypeGeneralDesc =>
      'Let AI create a personalized trip plan for you';

  @override
  String get chatbotName => 'ANIS';

  @override
  String get chatbotSubtitle => 'Your AI travel assistant';

  @override
  String get chatbotWelcome => 'Welcome to ANIS!';

  @override
  String get chatbotHelp =>
      'I am here to help you plan your next trip. Try one of the suggestions below:';

  @override
  String get chatbotSuggestion1 => 'Plan a trip to Dubai';

  @override
  String get chatbotSuggestion2 => 'What are the best hotels in Mecca?';

  @override
  String get chatbotSuggestion3 =>
      'Suggest family-friendly entertainment places';

  @override
  String get chatbotClearTitle => 'Clear Conversation';

  @override
  String get chatbotClearMessage =>
      'Are you sure you want to delete all messages? This action cannot be undone.';

  @override
  String get chatbotTypeMessage => 'Type your message...';

  @override
  String get nearbyTitle => 'Nearby Places';

  @override
  String get nearbySubtitle => 'Around your location';

  @override
  String get nearbyGettingLocation => 'Getting your location...';

  @override
  String get nearbyFindingPlaces => 'Finding nearby places...';

  @override
  String get nearbyPermissionTitle => 'See what\'s Good nearby';

  @override
  String get nearbyPermissionDesc =>
      'Allow location access\nto discover places around you';

  @override
  String get nearbyAllowAccess => 'Allow access';

  @override
  String get nearbyLoginRequired => 'Login Required';

  @override
  String get nearbyLoginMessage =>
      'You need to login first to discover nearby places.';

  @override
  String get nearbyPermDenied => 'Location permission was denied.';

  @override
  String get nearbyPermPermanentDenied =>
      'Location permission permanently denied.\nPlease enable it from device settings.';

  @override
  String nearbyPlacesFound(Object count) {
    return '$count places found';
  }

  @override
  String nearbyCount(Object count) {
    return '$count nearby';
  }

  @override
  String get nearbyNoPlaces => 'No places found in this category';

  @override
  String get nearbyGo => 'Go';

  @override
  String get nearbyCategoryAll => 'All';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get editProfileSave => 'Save Changes';

  @override
  String get editProfileSaving => 'Saving...';

  @override
  String get tripHistoryTitle => 'Plan History';

  @override
  String tripHistorySavedPlans(Object count) {
    return '$count saved plans';
  }

  @override
  String get tripHistoryNoPlans => 'No Plans Yet';

  @override
  String get tripHistoryNoPlansDesc =>
      'You haven\'t created any travel plans yet. Generate your first trip and start exploring amazing destinations.';

  @override
  String get tripHistoryGenerateFirst => 'Generate Your First Trip';

  @override
  String get tripHistoryLoginPrompt =>
      'Join us! Log in to unlock more features and view your trips!';

  @override
  String get tripHistoryLoginNow => 'Login Now';

  @override
  String tripHistoryDaysCount(Object count) {
    return '$count days';
  }

  @override
  String tripHistoryCreated(Object timeAgo) {
    return 'Created $timeAgo';
  }

  @override
  String tripHistoryMonthsAgo(Object count) {
    return '$count months ago';
  }

  @override
  String tripHistoryWeeksAgo(Object count) {
    return '$count weeks ago';
  }

  @override
  String tripHistoryDaysAgo(Object count) {
    return '$count days ago';
  }

  @override
  String get tripHistoryToday => 'Today';

  @override
  String get tripInfoWhereToGo => 'Where do you want to go?';

  @override
  String get tripInfoSelectCountry => 'Select a country';

  @override
  String get tripInfoWhenToGo => 'When do you want to go?';

  @override
  String get tripInfoTotalDays => 'Total days';

  @override
  String get tripInfoSelectSeason => 'Select a season';

  @override
  String get tripInfoSeasonWinter => 'Winter (December - February)';

  @override
  String get tripInfoSeasonSpring => 'Spring (March - May)';

  @override
  String get tripInfoSeasonSummer => 'Summer (June - August)';

  @override
  String get tripInfoSeasonAutumn => 'Autumn (September - November)';

  @override
  String get tripBudgetTitle => 'Your Budget range';

  @override
  String get tripBudgetLess5000 => 'Less 5000';

  @override
  String get tripBudgetFrom5kTo10k => 'From 5000 to 10000';

  @override
  String get tripBudgetFrom10kTo15k => 'From 10000 to 15000';

  @override
  String get tripBudgetFrom15kTo20k => 'From 15000 to 20000';

  @override
  String get tripBudgetMoreThan20k => 'More than 20000';

  @override
  String get tripInterestsTitle =>
      'What are you most\nexcited to do on your trip?';

  @override
  String get tripInterestNature => 'Nature';

  @override
  String get tripInterestAdventure => 'Adventure';

  @override
  String get tripInterestRelaxation => 'Relaxation';

  @override
  String get tripInterestHistorical => 'Historical sites';

  @override
  String get tripInterestMorning => 'Morning';

  @override
  String get tripInterestNight => 'Night activity';

  @override
  String get tripInterestShopping => 'Shopping';

  @override
  String get tripInterestHiddenGems => 'Hidden gems';

  @override
  String get commonNext => 'Next';

  @override
  String get customTripWhereToGo => 'Where do you want to go?';

  @override
  String get customTripSelectGovernorate => 'Select a governorate';

  @override
  String get customTripSelectGovernorateTitle => 'Select Governorate';

  @override
  String get customTripHowManyDays => 'How many days?';

  @override
  String get customTripTotalDays => 'Total days';

  @override
  String get editProfileSubtitle => 'Update your personal information';

  @override
  String get editProfilePersonalInfo => 'Personal Information';

  @override
  String get editProfileFullName => 'Full Name';

  @override
  String get editProfileFullNameHint => 'Enter your full name';

  @override
  String get editProfileEmail => 'Email';

  @override
  String get editProfileEmailHint => 'Your email';

  @override
  String get editProfileBirthDate => 'Birth Date';

  @override
  String get editProfileBirthDateHint => 'Select date';

  @override
  String get editProfileGender => 'Gender';

  @override
  String get editProfileGenderHint => 'Select';

  @override
  String get editProfileSelectGender => 'Select Gender';

  @override
  String get editProfileGenderMale => 'Male';

  @override
  String get editProfileGenderFemale => 'Female';

  @override
  String get editProfileGenderOther => 'Other';

  @override
  String get editProfileContactInfo => 'Contact Information';

  @override
  String get editProfilePhone => 'Phone Number';

  @override
  String get editProfilePhoneHint => 'Enter your phone number';

  @override
  String get editProfileCountry => 'Country';

  @override
  String get editProfileCountryHint => 'Select your country';

  @override
  String get editProfileSearchCountry => 'Search country';

  @override
  String get editProfileSaveChanges => 'Save Changes';

  @override
  String get editProfileChooseGallery => 'Choose from gallery';

  @override
  String get editProfileTakePhoto => 'Take a photo';

  @override
  String get editProfileUploadError => 'Failed to upload photo';

  @override
  String get editProfileSaved => 'Saved';

  @override
  String get editProfileUpdated => 'Updated';

  @override
  String get favouritesTitle => 'Your Favorites';

  @override
  String get favouritesSubtitle => 'All your saved journeys in one place';

  @override
  String get favouritesEmpty => 'No favourites yet.';

  @override
  String get favouritesLoginPrompt =>
      'Please log in to view and manage your favourites.';

  @override
  String favouritesSavedOn(Object date) {
    return 'Saved on $date';
  }
}
