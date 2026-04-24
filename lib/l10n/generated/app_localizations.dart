import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Rahhala App'**
  String get appTitle;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get commonBack;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @commonSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get commonSuccess;

  /// No description provided for @commonComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon...'**
  String get commonComingSoon;

  /// No description provided for @commonGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get commonGotIt;

  /// No description provided for @commonUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get commonUnknownError;

  /// No description provided for @commonOr.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get commonOr;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get commonLogin;

  /// No description provided for @commonTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get commonTryAgain;

  /// No description provided for @routerPageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page Not Found'**
  String get routerPageNotFound;

  /// No description provided for @routerGoHome.
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get routerGoHome;

  /// No description provided for @routerFeatureTitle.
  ///
  /// In en, this message translates to:
  /// **'{featureName}'**
  String routerFeatureTitle(Object featureName);

  /// No description provided for @routerFeatureUnderDevelopment.
  ///
  /// In en, this message translates to:
  /// **'{featureName} - Coming soon!'**
  String routerFeatureUnderDevelopment(Object featureName);

  /// No description provided for @routerTripPlanner.
  ///
  /// In en, this message translates to:
  /// **'Trip Planner'**
  String get routerTripPlanner;

  /// No description provided for @routerDestinations.
  ///
  /// In en, this message translates to:
  /// **'Destinations'**
  String get routerDestinations;

  /// No description provided for @routerDestinationDetails.
  ///
  /// In en, this message translates to:
  /// **'Destination Details ({id})'**
  String routerDestinationDetails(Object id);

  /// No description provided for @splashAppName.
  ///
  /// In en, this message translates to:
  /// **'Rahhala'**
  String get splashAppName;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your Travel Companion'**
  String get splashSubtitle;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get onboardingStart;

  /// No description provided for @onboardingTagline.
  ///
  /// In en, this message translates to:
  /// **'Thoughtfully crafted journeys, just for you'**
  String get onboardingTagline;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get onboardingTitle1;

  /// No description provided for @onboardingSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Amazing\nDestinations'**
  String get onboardingSubtitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'From the Nile to the desert — your\nEgyptian journey begins.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Designing'**
  String get onboardingTitle2;

  /// No description provided for @onboardingSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Your Trip'**
  String get onboardingSubtitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Finding destinations and experiences\nthat match your vibe.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Ready to'**
  String get onboardingTitle3;

  /// No description provided for @onboardingSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Explore ?'**
  String get onboardingSubtitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Your personalized adventure awaits —\nlet\'s start the journey!'**
  String get onboardingDesc3;

  /// No description provided for @authWelcomeBackTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get authWelcomeBackTitle;

  /// No description provided for @authWelcomeBackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to continue exploring curated trips.'**
  String get authWelcomeBackSubtitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get authEmailHint;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get authPasswordHint;

  /// No description provided for @authHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// No description provided for @authShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get authForgotPassword;

  /// No description provided for @authLoggingIn.
  ///
  /// In en, this message translates to:
  /// **'Logging In...'**
  String get authLoggingIn;

  /// No description provided for @authLogIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get authLogIn;

  /// No description provided for @authWelcomeBackNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get authWelcomeBackNotifTitle;

  /// No description provided for @authWelcomeBackNotifMessage.
  ///
  /// In en, this message translates to:
  /// **'Let\'s explore something new today.'**
  String get authWelcomeBackNotifMessage;

  /// No description provided for @authWelcomeBackUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back, {name}!'**
  String authWelcomeBackUser(Object name);

  /// No description provided for @authSecureSignIn.
  ///
  /// In en, this message translates to:
  /// **'Secure sign-in to continue your journey.'**
  String get authSecureSignIn;

  /// No description provided for @authCreateAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authCreateAccountTitle;

  /// No description provided for @authCreateAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill in your information below to sign up'**
  String get authCreateAccountSubtitle;

  /// No description provided for @authFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get authFullNameLabel;

  /// No description provided for @authFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get authFullNameHint;

  /// No description provided for @authPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get authPhoneLabel;

  /// No description provided for @authPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get authPhoneHint;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get authConfirmPasswordHint;

  /// No description provided for @authCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get authCountryLabel;

  /// No description provided for @authCountryHint.
  ///
  /// In en, this message translates to:
  /// **'Select your country'**
  String get authCountryHint;

  /// No description provided for @authCreatingAccount.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get authCreatingAccount;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authCreateAccount;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authAlreadyHaveAccount;

  /// No description provided for @authSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get authSignUp;

  /// No description provided for @authGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get authGuest;

  /// No description provided for @authGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get authGetStarted;

  /// No description provided for @authWelcomeSlogan.
  ///
  /// In en, this message translates to:
  /// **'Every place has a story..Start yours today!'**
  String get authWelcomeSlogan;

  /// No description provided for @authDontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authDontHaveAccount;

  /// No description provided for @authForgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get authForgotPasswordTitle;

  /// No description provided for @authForgotPasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address below and we\'ll send you a verification code to reset your password.'**
  String get authForgotPasswordDesc;

  /// No description provided for @authEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get authEmailAddress;

  /// No description provided for @authSendingCode.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get authSendingCode;

  /// No description provided for @authSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get authSendCode;

  /// No description provided for @authRememberedPassword.
  ///
  /// In en, this message translates to:
  /// **'Remembered your password?'**
  String get authRememberedPassword;

  /// No description provided for @authBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get authBackToLogin;

  /// No description provided for @authVerifyCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Code'**
  String get authVerifyCodeTitle;

  /// No description provided for @authVerifyCodeSignUpDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit verification code sent to your email to activate your account.'**
  String get authVerifyCodeSignUpDesc;

  /// No description provided for @authVerifyCodeResetDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit verification code sent to your email to reset your password.'**
  String get authVerifyCodeResetDesc;

  /// No description provided for @authVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get authVerified;

  /// No description provided for @authEnterOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 6-digit code.'**
  String get authEnterOtp;

  /// No description provided for @authContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get authContinue;

  /// No description provided for @authResetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get authResetPasswordTitle;

  /// No description provided for @authResetPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Use 8+ chars with upper/lowercase, number & symbol'**
  String get authResetPasswordHint;

  /// No description provided for @authNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get authNewPassword;

  /// No description provided for @authNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get authNewPasswordHint;

  /// No description provided for @authConfirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get authConfirmNewPassword;

  /// No description provided for @authConfirmNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter new password'**
  String get authConfirmNewPasswordHint;

  /// No description provided for @authResetting.
  ///
  /// In en, this message translates to:
  /// **'Resetting...'**
  String get authResetting;

  /// No description provided for @authResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get authResetPassword;

  /// No description provided for @authUpdating.
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get authUpdating;

  /// No description provided for @authUpdateAccountPassword.
  ///
  /// In en, this message translates to:
  /// **'Update your account password'**
  String get authUpdateAccountPassword;

  /// No description provided for @authNewPasswordMustDiffer.
  ///
  /// In en, this message translates to:
  /// **'Your new password must be different from previous used password'**
  String get authNewPasswordMustDiffer;

  /// No description provided for @authCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get authCurrentPassword;

  /// No description provided for @authCurrentPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter current password'**
  String get authCurrentPasswordHint;

  /// No description provided for @authPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get authPasswordRequired;

  /// No description provided for @passwordRule8Chars.
  ///
  /// In en, this message translates to:
  /// **'8 or more characters'**
  String get passwordRule8Chars;

  /// No description provided for @passwordRuleUppercase.
  ///
  /// In en, this message translates to:
  /// **'At least 1 uppercase letter'**
  String get passwordRuleUppercase;

  /// No description provided for @passwordRuleLowercase.
  ///
  /// In en, this message translates to:
  /// **'At least 1 lowercase letter'**
  String get passwordRuleLowercase;

  /// No description provided for @passwordRuleNumber.
  ///
  /// In en, this message translates to:
  /// **'At least 1 number'**
  String get passwordRuleNumber;

  /// No description provided for @passwordRuleSpecial.
  ///
  /// In en, this message translates to:
  /// **'At least 1 special character'**
  String get passwordRuleSpecial;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileNoEmail.
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get profileNoEmail;

  /// No description provided for @profileAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccount;

  /// No description provided for @profilePreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profilePreferences;

  /// No description provided for @profileSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get profileSupport;

  /// No description provided for @profileDangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get profileDangerZone;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEdit;

  /// No description provided for @profilePlanHistory.
  ///
  /// In en, this message translates to:
  /// **'Plan History'**
  String get profilePlanHistory;

  /// No description provided for @profileChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get profileChangePassword;

  /// No description provided for @profileNotification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get profileNotification;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profilePlans.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get profilePlans;

  /// No description provided for @profileAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get profileAppearance;

  /// No description provided for @profileHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help and Support'**
  String get profileHelpSupport;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileLogout;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get profileDeleteAccount;

  /// No description provided for @profileDeleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete your account permanently?'**
  String get profileDeleteAccountConfirm;

  /// No description provided for @profileLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Log out from your account?'**
  String get profileLogoutConfirm;

  /// No description provided for @profileDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get profileDeleteAction;

  /// No description provided for @profileLogoutAction.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileLogoutAction;

  /// No description provided for @profileLanguageBottomSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose app language'**
  String get profileLanguageBottomSheetTitle;

  /// No description provided for @profileLanguageBottomSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Changes are applied instantly'**
  String get profileLanguageBottomSheetSubtitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @homeWelcomeGuest.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Guest!'**
  String get homeWelcomeGuest;

  /// No description provided for @homeWelcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}!'**
  String homeWelcomeUser(Object name);

  /// No description provided for @homeExploreDestinations.
  ///
  /// In en, this message translates to:
  /// **'Explore amazing destinations'**
  String get homeExploreDestinations;

  /// No description provided for @homeWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get homeWishlist;

  /// No description provided for @homeSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get homeSearch;

  /// No description provided for @homeWishlistSoon.
  ///
  /// In en, this message translates to:
  /// **'Wishlist page - Coming soon!'**
  String get homeWishlistSoon;

  /// No description provided for @homeSearchSoon.
  ///
  /// In en, this message translates to:
  /// **'Search - Coming soon!'**
  String get homeSearchSoon;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wish list'**
  String get navWishlist;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @homePageContent.
  ///
  /// In en, this message translates to:
  /// **'Home Page Content'**
  String get homePageContent;

  /// No description provided for @homeComingSoonShort.
  ///
  /// In en, this message translates to:
  /// **'{title} - Coming soon'**
  String homeComingSoonShort(Object title);

  /// No description provided for @tripTypeSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Trip Type'**
  String get tripTypeSelectTitle;

  /// No description provided for @tripTypeSelectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to plan your trip'**
  String get tripTypeSelectSubtitle;

  /// No description provided for @tripTypeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom Trip'**
  String get tripTypeCustom;

  /// No description provided for @tripTypeCustomDesc.
  ///
  /// In en, this message translates to:
  /// **'Plan your trip yourself with full control over every detail'**
  String get tripTypeCustomDesc;

  /// No description provided for @tripTypeGeneral.
  ///
  /// In en, this message translates to:
  /// **'General Trip'**
  String get tripTypeGeneral;

  /// No description provided for @tripTypeGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'Let AI create a personalized trip plan for you'**
  String get tripTypeGeneralDesc;

  /// No description provided for @chatbotName.
  ///
  /// In en, this message translates to:
  /// **'ANIS'**
  String get chatbotName;

  /// No description provided for @chatbotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your AI travel assistant'**
  String get chatbotSubtitle;

  /// No description provided for @chatbotWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to ANIS!'**
  String get chatbotWelcome;

  /// No description provided for @chatbotHelp.
  ///
  /// In en, this message translates to:
  /// **'I am here to help you plan your next trip. Try one of the suggestions below:'**
  String get chatbotHelp;

  /// No description provided for @chatbotSuggestion1.
  ///
  /// In en, this message translates to:
  /// **'Plan a trip to Dubai'**
  String get chatbotSuggestion1;

  /// No description provided for @chatbotSuggestion2.
  ///
  /// In en, this message translates to:
  /// **'What are the best hotels in Mecca?'**
  String get chatbotSuggestion2;

  /// No description provided for @chatbotSuggestion3.
  ///
  /// In en, this message translates to:
  /// **'Suggest family-friendly entertainment places'**
  String get chatbotSuggestion3;

  /// No description provided for @chatbotClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Conversation'**
  String get chatbotClearTitle;

  /// No description provided for @chatbotClearMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all messages? This action cannot be undone.'**
  String get chatbotClearMessage;

  /// No description provided for @chatbotTypeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get chatbotTypeMessage;

  /// No description provided for @nearbyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby Places'**
  String get nearbyTitle;

  /// No description provided for @nearbySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Around your location'**
  String get nearbySubtitle;

  /// No description provided for @nearbyGettingLocation.
  ///
  /// In en, this message translates to:
  /// **'Getting your location...'**
  String get nearbyGettingLocation;

  /// No description provided for @nearbyFindingPlaces.
  ///
  /// In en, this message translates to:
  /// **'Finding nearby places...'**
  String get nearbyFindingPlaces;

  /// No description provided for @nearbyPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'See what\'s Good nearby'**
  String get nearbyPermissionTitle;

  /// No description provided for @nearbyPermissionDesc.
  ///
  /// In en, this message translates to:
  /// **'Allow location access\nto discover places around you'**
  String get nearbyPermissionDesc;

  /// No description provided for @nearbyAllowAccess.
  ///
  /// In en, this message translates to:
  /// **'Allow access'**
  String get nearbyAllowAccess;

  /// No description provided for @nearbyLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get nearbyLoginRequired;

  /// No description provided for @nearbyLoginMessage.
  ///
  /// In en, this message translates to:
  /// **'You need to login first to discover nearby places.'**
  String get nearbyLoginMessage;

  /// No description provided for @nearbyPermDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission was denied.'**
  String get nearbyPermDenied;

  /// No description provided for @nearbyPermPermanentDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission permanently denied.\nPlease enable it from device settings.'**
  String get nearbyPermPermanentDenied;

  /// No description provided for @nearbyPlacesFound.
  ///
  /// In en, this message translates to:
  /// **'{count} places found'**
  String nearbyPlacesFound(Object count);

  /// No description provided for @nearbyCount.
  ///
  /// In en, this message translates to:
  /// **'{count} nearby'**
  String nearbyCount(Object count);

  /// No description provided for @nearbyNoPlaces.
  ///
  /// In en, this message translates to:
  /// **'No places found in this category'**
  String get nearbyNoPlaces;

  /// No description provided for @nearbyGo.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get nearbyGo;

  /// No description provided for @nearbyCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get nearbyCategoryAll;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @editProfileSave.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get editProfileSave;

  /// No description provided for @editProfileSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get editProfileSaving;

  /// No description provided for @tripHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan History'**
  String get tripHistoryTitle;

  /// No description provided for @tripHistorySavedPlans.
  ///
  /// In en, this message translates to:
  /// **'{count} saved plans'**
  String tripHistorySavedPlans(Object count);

  /// No description provided for @tripHistoryNoPlans.
  ///
  /// In en, this message translates to:
  /// **'No Plans Yet'**
  String get tripHistoryNoPlans;

  /// No description provided for @tripHistoryNoPlansDesc.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t created any travel plans yet. Generate your first trip and start exploring amazing destinations.'**
  String get tripHistoryNoPlansDesc;

  /// No description provided for @tripHistoryGenerateFirst.
  ///
  /// In en, this message translates to:
  /// **'Generate Your First Trip'**
  String get tripHistoryGenerateFirst;

  /// No description provided for @tripHistoryLoginPrompt.
  ///
  /// In en, this message translates to:
  /// **'Join us! Log in to unlock more features and view your trips!'**
  String get tripHistoryLoginPrompt;

  /// No description provided for @tripHistoryLoginNow.
  ///
  /// In en, this message translates to:
  /// **'Login Now'**
  String get tripHistoryLoginNow;

  /// No description provided for @tripHistoryDaysCount.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String tripHistoryDaysCount(Object count);

  /// No description provided for @tripHistoryCreated.
  ///
  /// In en, this message translates to:
  /// **'Created {timeAgo}'**
  String tripHistoryCreated(Object timeAgo);

  /// No description provided for @tripHistoryMonthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} months ago'**
  String tripHistoryMonthsAgo(Object count);

  /// No description provided for @tripHistoryWeeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} weeks ago'**
  String tripHistoryWeeksAgo(Object count);

  /// No description provided for @tripHistoryDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String tripHistoryDaysAgo(Object count);

  /// No description provided for @tripHistoryToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tripHistoryToday;

  /// No description provided for @tripInfoWhereToGo.
  ///
  /// In en, this message translates to:
  /// **'Where do you want to go?'**
  String get tripInfoWhereToGo;

  /// No description provided for @tripInfoSelectCountry.
  ///
  /// In en, this message translates to:
  /// **'Select a country'**
  String get tripInfoSelectCountry;

  /// No description provided for @tripInfoWhenToGo.
  ///
  /// In en, this message translates to:
  /// **'When do you want to go?'**
  String get tripInfoWhenToGo;

  /// No description provided for @tripInfoTotalDays.
  ///
  /// In en, this message translates to:
  /// **'Total days'**
  String get tripInfoTotalDays;

  /// No description provided for @tripInfoSelectSeason.
  ///
  /// In en, this message translates to:
  /// **'Select a season'**
  String get tripInfoSelectSeason;

  /// No description provided for @tripInfoSeasonWinter.
  ///
  /// In en, this message translates to:
  /// **'Winter (December - February)'**
  String get tripInfoSeasonWinter;

  /// No description provided for @tripInfoSeasonSpring.
  ///
  /// In en, this message translates to:
  /// **'Spring (March - May)'**
  String get tripInfoSeasonSpring;

  /// No description provided for @tripInfoSeasonSummer.
  ///
  /// In en, this message translates to:
  /// **'Summer (June - August)'**
  String get tripInfoSeasonSummer;

  /// No description provided for @tripInfoSeasonAutumn.
  ///
  /// In en, this message translates to:
  /// **'Autumn (September - November)'**
  String get tripInfoSeasonAutumn;

  /// No description provided for @tripBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Budget range'**
  String get tripBudgetTitle;

  /// No description provided for @tripBudgetLess5000.
  ///
  /// In en, this message translates to:
  /// **'Less 5000'**
  String get tripBudgetLess5000;

  /// No description provided for @tripBudgetFrom5kTo10k.
  ///
  /// In en, this message translates to:
  /// **'From 5000 to 10000'**
  String get tripBudgetFrom5kTo10k;

  /// No description provided for @tripBudgetFrom10kTo15k.
  ///
  /// In en, this message translates to:
  /// **'From 10000 to 15000'**
  String get tripBudgetFrom10kTo15k;

  /// No description provided for @tripBudgetFrom15kTo20k.
  ///
  /// In en, this message translates to:
  /// **'From 15000 to 20000'**
  String get tripBudgetFrom15kTo20k;

  /// No description provided for @tripBudgetMoreThan20k.
  ///
  /// In en, this message translates to:
  /// **'More than 20000'**
  String get tripBudgetMoreThan20k;

  /// No description provided for @tripInterestsTitle.
  ///
  /// In en, this message translates to:
  /// **'What are you most\nexcited to do on your trip?'**
  String get tripInterestsTitle;

  /// No description provided for @tripInterestNature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get tripInterestNature;

  /// No description provided for @tripInterestAdventure.
  ///
  /// In en, this message translates to:
  /// **'Adventure'**
  String get tripInterestAdventure;

  /// No description provided for @tripInterestRelaxation.
  ///
  /// In en, this message translates to:
  /// **'Relaxation'**
  String get tripInterestRelaxation;

  /// No description provided for @tripInterestHistorical.
  ///
  /// In en, this message translates to:
  /// **'Historical sites'**
  String get tripInterestHistorical;

  /// No description provided for @tripInterestMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get tripInterestMorning;

  /// No description provided for @tripInterestNight.
  ///
  /// In en, this message translates to:
  /// **'Night activity'**
  String get tripInterestNight;

  /// No description provided for @tripInterestShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get tripInterestShopping;

  /// No description provided for @tripInterestHiddenGems.
  ///
  /// In en, this message translates to:
  /// **'Hidden gems'**
  String get tripInterestHiddenGems;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @customTripWhereToGo.
  ///
  /// In en, this message translates to:
  /// **'Where do you want to go?'**
  String get customTripWhereToGo;

  /// No description provided for @customTripSelectGovernorate.
  ///
  /// In en, this message translates to:
  /// **'Select a governorate'**
  String get customTripSelectGovernorate;

  /// No description provided for @customTripSelectGovernorateTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Governorate'**
  String get customTripSelectGovernorateTitle;

  /// No description provided for @customTripHowManyDays.
  ///
  /// In en, this message translates to:
  /// **'How many days?'**
  String get customTripHowManyDays;

  /// No description provided for @customTripTotalDays.
  ///
  /// In en, this message translates to:
  /// **'Total days'**
  String get customTripTotalDays;

  /// No description provided for @editProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your personal information'**
  String get editProfileSubtitle;

  /// No description provided for @editProfilePersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get editProfilePersonalInfo;

  /// No description provided for @editProfileFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get editProfileFullName;

  /// No description provided for @editProfileFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get editProfileFullNameHint;

  /// No description provided for @editProfileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get editProfileEmail;

  /// No description provided for @editProfileEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Your email'**
  String get editProfileEmailHint;

  /// No description provided for @editProfileBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get editProfileBirthDate;

  /// No description provided for @editProfileBirthDateHint.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get editProfileBirthDateHint;

  /// No description provided for @editProfileGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get editProfileGender;

  /// No description provided for @editProfileGenderHint.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get editProfileGenderHint;

  /// No description provided for @editProfileSelectGender.
  ///
  /// In en, this message translates to:
  /// **'Select Gender'**
  String get editProfileSelectGender;

  /// No description provided for @editProfileGenderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get editProfileGenderMale;

  /// No description provided for @editProfileGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get editProfileGenderFemale;

  /// No description provided for @editProfileGenderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get editProfileGenderOther;

  /// No description provided for @editProfileContactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get editProfileContactInfo;

  /// No description provided for @editProfilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get editProfilePhone;

  /// No description provided for @editProfilePhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get editProfilePhoneHint;

  /// No description provided for @editProfileCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get editProfileCountry;

  /// No description provided for @editProfileCountryHint.
  ///
  /// In en, this message translates to:
  /// **'Select your country'**
  String get editProfileCountryHint;

  /// No description provided for @editProfileSearchCountry.
  ///
  /// In en, this message translates to:
  /// **'Search country'**
  String get editProfileSearchCountry;

  /// No description provided for @editProfileSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get editProfileSaveChanges;

  /// No description provided for @editProfileChooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get editProfileChooseGallery;

  /// No description provided for @editProfileTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get editProfileTakePhoto;

  /// No description provided for @editProfileUploadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload photo'**
  String get editProfileUploadError;

  /// No description provided for @editProfileSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get editProfileSaved;

  /// No description provided for @editProfileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get editProfileUpdated;

  /// No description provided for @favouritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Favorites'**
  String get favouritesTitle;

  /// No description provided for @favouritesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'All your saved journeys in one place'**
  String get favouritesSubtitle;

  /// No description provided for @favouritesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No favourites yet.'**
  String get favouritesEmpty;

  /// No description provided for @favouritesLoginPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please log in to view and manage your favourites.'**
  String get favouritesLoginPrompt;

  /// No description provided for @favouritesSavedOn.
  ///
  /// In en, this message translates to:
  /// **'Saved on {date}'**
  String favouritesSavedOn(Object date);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
