// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'رحّالة';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonBack => 'رجوع';

  @override
  String get commonError => 'خطأ';

  @override
  String get commonSuccess => 'تم بنجاح';

  @override
  String get commonComingSoon => 'قريباً...';

  @override
  String get commonGotIt => 'حسناً';

  @override
  String get commonUnknownError => 'خطأ غير معروف';

  @override
  String get commonOr => 'أو';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonLogin => 'تسجيل الدخول';

  @override
  String get commonTryAgain => 'أعد المحاولة';

  @override
  String get routerPageNotFound => 'الصفحة غير موجودة';

  @override
  String get routerGoHome => 'الرئيسية';

  @override
  String routerFeatureTitle(Object featureName) {
    return '$featureName';
  }

  @override
  String routerFeatureUnderDevelopment(Object featureName) {
    return '$featureName - قريباً!';
  }

  @override
  String get routerTripPlanner => 'مخطط الرحلات';

  @override
  String get routerDestinations => 'الوجهات';

  @override
  String routerDestinationDetails(Object id) {
    return 'تفاصيل الوجهة ($id)';
  }

  @override
  String get splashAppName => 'رحّالة';

  @override
  String get splashSubtitle => 'رفيق سفرك';

  @override
  String get onboardingSkip => 'تخطي';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingStart => 'ابدأ';

  @override
  String get onboardingTagline => 'رحلات مُعدّة بعناية، خصيصاً لك';

  @override
  String get onboardingTitle1 => 'اكتشف';

  @override
  String get onboardingSubtitle1 => 'وجهات\nمذهلة';

  @override
  String get onboardingDesc1 =>
      'من النيل إلى الصحراء — رحلتك\nالمصرية تبدأ من هنا.';

  @override
  String get onboardingTitle2 => 'صمّم';

  @override
  String get onboardingSubtitle2 => 'رحلتك';

  @override
  String get onboardingDesc2 => 'اعثر على الوجهات والتجارب\nالتي تناسب ذوقك.';

  @override
  String get onboardingTitle3 => 'جاهز';

  @override
  String get onboardingSubtitle3 => 'للاستكشاف؟';

  @override
  String get onboardingDesc3 => 'مغامرتك المخصصة بانتظارك —\nلنبدأ الرحلة!';

  @override
  String get authWelcomeBackTitle => 'مرحباً بعودتك';

  @override
  String get authWelcomeBackSubtitle =>
      'سجّل دخولك لمواصلة استكشاف الرحلات المميزة.';

  @override
  String get authEmailLabel => 'البريد الإلكتروني';

  @override
  String get authEmailHint => 'أدخل بريدك الإلكتروني';

  @override
  String get authPasswordLabel => 'كلمة المرور';

  @override
  String get authPasswordHint => 'أدخل كلمة المرور';

  @override
  String get authHidePassword => 'إخفاء كلمة المرور';

  @override
  String get authShowPassword => 'إظهار كلمة المرور';

  @override
  String get authForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get authLoggingIn => 'جاري الدخول...';

  @override
  String get authLogIn => 'تسجيل الدخول';

  @override
  String get authWelcomeBackNotifTitle => 'مرحباً بعودتك';

  @override
  String get authWelcomeBackNotifMessage => 'لنستكشف شيئاً جديداً اليوم.';

  @override
  String authWelcomeBackUser(Object name) {
    return 'مرحباً بعودتك، $name!';
  }

  @override
  String get authSecureSignIn => 'تسجيل دخول آمن لمتابعة رحلتك.';

  @override
  String get authCreateAccountTitle => 'إنشاء حساب';

  @override
  String get authCreateAccountSubtitle => 'أدخل بياناتك أدناه للتسجيل';

  @override
  String get authFullNameLabel => 'الاسم الكامل';

  @override
  String get authFullNameHint => 'أدخل اسمك الكامل';

  @override
  String get authPhoneLabel => 'رقم الهاتف';

  @override
  String get authPhoneHint => 'أدخل رقم هاتفك';

  @override
  String get authConfirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get authConfirmPasswordHint => 'أعد إدخال كلمة المرور';

  @override
  String get authCountryLabel => 'الدولة';

  @override
  String get authCountryHint => 'اختر دولتك';

  @override
  String get authCreatingAccount => 'جاري الإنشاء...';

  @override
  String get authCreateAccount => 'إنشاء حساب';

  @override
  String get authAlreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get authSignUp => 'تسجيل';

  @override
  String get authGuest => 'ضيف';

  @override
  String get authGetStarted => 'ابدأ';

  @override
  String get authWelcomeSlogan => 'كل مكان يحكي قصة.. ابدأ قصتك اليوم!';

  @override
  String get authDontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get authForgotPasswordTitle => 'نسيت كلمة المرور';

  @override
  String get authForgotPasswordDesc =>
      'أدخل عنوان بريدك الإلكتروني أدناه وسنرسل لك رمز تحقق لإعادة تعيين كلمة المرور.';

  @override
  String get authEmailAddress => 'البريد الإلكتروني';

  @override
  String get authSendingCode => 'جاري الإرسال...';

  @override
  String get authSendCode => 'إرسال الرمز';

  @override
  String get authRememberedPassword => 'تذكرت كلمة المرور؟';

  @override
  String get authBackToLogin => 'العودة لتسجيل الدخول';

  @override
  String get authVerifyCodeTitle => 'تحقق من الرمز';

  @override
  String get authVerifyCodeSignUpDesc =>
      'أدخل رمز التحقق المكون من 6 أرقام المرسل إلى بريدك الإلكتروني لتفعيل حسابك.';

  @override
  String get authVerifyCodeResetDesc =>
      'أدخل رمز التحقق المكون من 6 أرقام المرسل إلى بريدك الإلكتروني لإعادة تعيين كلمة المرور.';

  @override
  String get authVerified => 'تم التحقق';

  @override
  String get authEnterOtp => 'يرجى إدخال الرمز المكون من 6 أرقام.';

  @override
  String get authContinue => 'متابعة';

  @override
  String get authResetPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get authResetPasswordHint =>
      'استخدم 8+ أحرف مع أحرف كبيرة/صغيرة ورقم ورمز';

  @override
  String get authNewPassword => 'كلمة المرور الجديدة';

  @override
  String get authNewPasswordHint => 'أدخل كلمة المرور الجديدة';

  @override
  String get authConfirmNewPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get authConfirmNewPasswordHint => 'أعد إدخال كلمة المرور الجديدة';

  @override
  String get authResetting => 'جاري الإعادة...';

  @override
  String get authResetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get authUpdating => 'جاري التحديث...';

  @override
  String get authUpdateAccountPassword => 'تحديث كلمة مرور حسابك';

  @override
  String get authNewPasswordMustDiffer =>
      'يجب أن تكون كلمة المرور الجديدة مختلفة عن كلمة المرور السابقة';

  @override
  String get authCurrentPassword => 'كلمة المرور الحالية';

  @override
  String get authCurrentPasswordHint => 'أدخل كلمة المرور الحالية';

  @override
  String get authPasswordRequired => 'كلمة المرور مطلوبة';

  @override
  String get passwordRule8Chars => '8 أحرف أو أكثر';

  @override
  String get passwordRuleUppercase => 'حرف كبير واحد على الأقل';

  @override
  String get passwordRuleLowercase => 'حرف صغير واحد على الأقل';

  @override
  String get passwordRuleNumber => 'رقم واحد على الأقل';

  @override
  String get passwordRuleSpecial => 'رمز خاص واحد على الأقل';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get profileNoEmail => 'لا يوجد بريد';

  @override
  String get profileAccount => 'الحساب';

  @override
  String get profilePreferences => 'التفضيلات';

  @override
  String get profileSupport => 'الدعم';

  @override
  String get profileDangerZone => 'منطقة الخطر';

  @override
  String get profileEdit => 'تعديل الملف الشخصي';

  @override
  String get profilePlanHistory => 'سجل الخطط';

  @override
  String get profileChangePassword => 'تغيير كلمة المرور';

  @override
  String get profileNotification => 'الإشعارات';

  @override
  String get profileLanguage => 'اللغة';

  @override
  String get profilePlans => 'الخطط';

  @override
  String get profileAppearance => 'المظهر';

  @override
  String get profileHelpSupport => 'المساعدة والدعم';

  @override
  String get profileLogout => 'تسجيل الخروج';

  @override
  String get profileDeleteAccount => 'حذف الحساب';

  @override
  String get profileDeleteAccountConfirm => 'حذف حسابك نهائياً؟';

  @override
  String get profileLogoutConfirm => 'تسجيل الخروج من حسابك؟';

  @override
  String get profileDeleteAction => 'حذف';

  @override
  String get profileLogoutAction => 'خروج';

  @override
  String get profileLanguageBottomSheetTitle => 'اختر لغة التطبيق';

  @override
  String get profileLanguageBottomSheetSubtitle => 'يتم تطبيق التغييرات فوراً';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get homeWelcomeGuest => '!أهلاً، ضيف';

  @override
  String homeWelcomeUser(Object name) {
    return 'أهلاً، $name!';
  }

  @override
  String get homeExploreDestinations => 'استكشف وجهات مذهلة';

  @override
  String get homeWishlist => 'قائمة الأمنيات';

  @override
  String get homeSearch => 'بحث';

  @override
  String get homeWishlistSoon => 'صفحة قائمة الأمنيات - قريباً!';

  @override
  String get homeSearchSoon => 'البحث - قريباً!';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navWishlist => 'الأمنيات';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get homePageContent => 'محتوى الصفحة الرئيسية';

  @override
  String homeComingSoonShort(Object title) {
    return '$title - قريباً';
  }

  @override
  String get tripTypeSelectTitle => 'اختر نوع الرحلة';

  @override
  String get tripTypeSelectSubtitle => 'اختر كيف تريد تخطيط رحلتك';

  @override
  String get tripTypeCustom => 'رحلة مخصصة';

  @override
  String get tripTypeCustomDesc =>
      'خطط رحلتك بنفسك مع تحكم كامل في كل التفاصيل';

  @override
  String get tripTypeGeneral => 'رحلة عامة';

  @override
  String get tripTypeGeneralDesc =>
      'دع الذكاء الاصطناعي يصنع خطة رحلة مخصصة لك';

  @override
  String get chatbotName => 'أنيس';

  @override
  String get chatbotSubtitle => 'مساعد السفر الذكي';

  @override
  String get chatbotWelcome => '!مرحباً في أنيس';

  @override
  String get chatbotHelp =>
      'أنا هنا لمساعدتك في تخطيط رحلتك القادمة. جرّب أحد الاقتراحات أدناه:';

  @override
  String get chatbotSuggestion1 => 'خطط رحلة إلى دبي';

  @override
  String get chatbotSuggestion2 => 'ما هي أفضل الفنادق في مكة؟';

  @override
  String get chatbotSuggestion3 => 'اقترح أماكن ترفيهية مناسبة للعائلة';

  @override
  String get chatbotClearTitle => 'مسح المحادثة';

  @override
  String get chatbotClearMessage =>
      'هل أنت متأكد من حذف جميع الرسائل؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get chatbotTypeMessage => 'اكتب رسالتك...';

  @override
  String get nearbyTitle => 'أماكن قريبة';

  @override
  String get nearbySubtitle => 'حول موقعك';

  @override
  String get nearbyGettingLocation => 'جاري تحديد موقعك...';

  @override
  String get nearbyFindingPlaces => 'جاري البحث عن أماكن قريبة...';

  @override
  String get nearbyPermissionTitle => 'اكتشف ما حولك';

  @override
  String get nearbyPermissionDesc =>
      'اسمح بالوصول إلى الموقع\nلاكتشاف الأماكن حولك';

  @override
  String get nearbyAllowAccess => 'السماح بالوصول';

  @override
  String get nearbyLoginRequired => 'يجب تسجيل الدخول';

  @override
  String get nearbyLoginMessage =>
      'يجب تسجيل الدخول أولاً لاكتشاف الأماكن القريبة.';

  @override
  String get nearbyPermDenied => 'تم رفض إذن الموقع.';

  @override
  String get nearbyPermPermanentDenied =>
      'تم رفض إذن الموقع نهائياً.\nيرجى تفعيله من إعدادات الجهاز.';

  @override
  String nearbyPlacesFound(Object count) {
    return 'تم العثور على $count مكان';
  }

  @override
  String nearbyCount(Object count) {
    return '$count قريب';
  }

  @override
  String get nearbyNoPlaces => 'لا توجد أماكن في هذه الفئة';

  @override
  String get nearbyGo => 'اذهب';

  @override
  String get nearbyCategoryAll => 'الكل';

  @override
  String get editProfileTitle => 'تعديل الملف الشخصي';

  @override
  String get editProfileSave => 'حفظ التغييرات';

  @override
  String get editProfileSaving => 'جارٍ الحفظ...';

  @override
  String get tripHistoryTitle => 'سجل الخطط';

  @override
  String tripHistorySavedPlans(Object count) {
    return '$count خطط محفوظة';
  }

  @override
  String get tripHistoryNoPlans => 'لا توجد خطط بعد';

  @override
  String get tripHistoryNoPlansDesc =>
      'لم تنشئ أي خطط سفر بعد. أنشئ أول رحلة لك وابدأ باستكشاف وجهات مذهلة.';

  @override
  String get tripHistoryGenerateFirst => 'أنشئ أول رحلة لك';

  @override
  String get tripHistoryLoginPrompt =>
      'انضم إلينا! سجّل دخولك لفتح المزيد من الميزات وعرض رحلاتك!';

  @override
  String get tripHistoryLoginNow => 'سجّل الدخول الآن';

  @override
  String tripHistoryDaysCount(Object count) {
    return '$count أيام';
  }

  @override
  String tripHistoryCreated(Object timeAgo) {
    return 'أُنشئت $timeAgo';
  }

  @override
  String tripHistoryMonthsAgo(Object count) {
    return 'منذ $count أشهر';
  }

  @override
  String tripHistoryWeeksAgo(Object count) {
    return 'منذ $count أسابيع';
  }

  @override
  String tripHistoryDaysAgo(Object count) {
    return 'منذ $count أيام';
  }

  @override
  String get tripHistoryToday => 'اليوم';

  @override
  String get tripInfoWhereToGo => 'إلى أين تريد الذهاب؟';

  @override
  String get tripInfoSelectCountry => 'اختر دولة';

  @override
  String get tripInfoWhenToGo => 'متى تريد الذهاب؟';

  @override
  String get tripInfoTotalDays => 'إجمالي الأيام';

  @override
  String get tripInfoSelectSeason => 'اختر الموسم';

  @override
  String get tripInfoSeasonWinter => 'الشتاء (ديسمبر - فبراير)';

  @override
  String get tripInfoSeasonSpring => 'الربيع (مارس - مايو)';

  @override
  String get tripInfoSeasonSummer => 'الصيف (يونيو - أغسطس)';

  @override
  String get tripInfoSeasonAutumn => 'الخريف (سبتمبر - نوفمبر)';

  @override
  String get tripBudgetTitle => 'نطاق ميزانيتك';

  @override
  String get tripBudgetLess5000 => 'أقل من 5000';

  @override
  String get tripBudgetFrom5kTo10k => 'من 5000 إلى 10000';

  @override
  String get tripBudgetFrom10kTo15k => 'من 10000 إلى 15000';

  @override
  String get tripBudgetFrom15kTo20k => 'من 15000 إلى 20000';

  @override
  String get tripBudgetMoreThan20k => 'أكثر من 20000';

  @override
  String get tripInterestsTitle => 'ما الذي يثيرك أكثر\nفي رحلتك؟';

  @override
  String get tripInterestNature => 'الطبيعة';

  @override
  String get tripInterestAdventure => 'المغامرة';

  @override
  String get tripInterestRelaxation => 'الاسترخاء';

  @override
  String get tripInterestHistorical => 'المواقع التاريخية';

  @override
  String get tripInterestMorning => 'صباحية';

  @override
  String get tripInterestNight => 'نشاط ليلي';

  @override
  String get tripInterestShopping => 'التسوق';

  @override
  String get tripInterestHiddenGems => 'الجواهر المخفية';

  @override
  String get commonNext => 'التالي';

  @override
  String get customTripWhereToGo => 'إلى أين تريد الذهاب؟';

  @override
  String get customTripSelectGovernorate => 'اختر محافظة';

  @override
  String get customTripSelectGovernorateTitle => 'اختر المحافظة';

  @override
  String get customTripHowManyDays => 'كم عدد الأيام؟';

  @override
  String get customTripTotalDays => 'إجمالي الأيام';

  @override
  String get editProfileSubtitle => 'تحديث معلوماتك الشخصية';

  @override
  String get editProfilePersonalInfo => 'المعلومات الشخصية';

  @override
  String get editProfileFullName => 'الاسم الكامل';

  @override
  String get editProfileFullNameHint => 'أدخل اسمك الكامل';

  @override
  String get editProfileEmail => 'البريد الإلكتروني';

  @override
  String get editProfileEmailHint => 'بريدك الإلكتروني';

  @override
  String get editProfileBirthDate => 'تاريخ الميلاد';

  @override
  String get editProfileBirthDateHint => 'اختر التاريخ';

  @override
  String get editProfileGender => 'الجنس';

  @override
  String get editProfileGenderHint => 'اختر';

  @override
  String get editProfileSelectGender => 'اختر الجنس';

  @override
  String get editProfileGenderMale => 'ذكر';

  @override
  String get editProfileGenderFemale => 'أنثى';

  @override
  String get editProfileGenderOther => 'آخر';

  @override
  String get editProfileContactInfo => 'معلومات الاتصال';

  @override
  String get editProfilePhone => 'رقم الهاتف';

  @override
  String get editProfilePhoneHint => 'أدخل رقم هاتفك';

  @override
  String get editProfileCountry => 'الدولة';

  @override
  String get editProfileCountryHint => 'اختر دولتك';

  @override
  String get editProfileSearchCountry => 'ابحث عن دولة';

  @override
  String get editProfileSaveChanges => 'حفظ التغييرات';

  @override
  String get editProfileChooseGallery => 'اختر من المعرض';

  @override
  String get editProfileTakePhoto => 'التقط صورة';

  @override
  String get editProfileUploadError => 'فشل تحميل الصورة';

  @override
  String get editProfileSaved => 'تم الحفظ';

  @override
  String get editProfileUpdated => 'تم التحديث';

  @override
  String get favouritesTitle => 'المفضلة';

  @override
  String get favouritesSubtitle => 'جميع رحلاتك المحفوظة في مكان واحد';

  @override
  String get favouritesEmpty => 'لا توجد مفضلات بعد.';

  @override
  String get favouritesLoginPrompt => 'يرجى تسجيل الدخول لعرض وإدارة المفضلة.';

  @override
  String favouritesSavedOn(Object date) {
    return 'تم الحفظ في $date';
  }

  @override
  String get homeLoadingMorePlaces => 'جارٍ تحميل المزيد من الأماكن...';

  @override
  String get homeEndOfList => 'لقد شاهدت كل شيء!';

  @override
  String get homeNoPlaces => 'لا توجد أماكن متاحة الآن.';

  @override
  String get homeLoadMoreError =>
      'تعذر تحميل المزيد من الأماكن. حاول مرة أخرى.';

  @override
  String get homeFavouriteError => 'تعذر تحديث المفضلة. حاول مرة أخرى.';

  @override
  String get reviewLoginRequired => 'يجب تسجيل الدخول لإضافة تقييم ومراجعة.';

  @override
  String get reviewSubmitTitle => 'أرسل مراجعتك';

  @override
  String get reviewYourRate => 'تقييمك';

  @override
  String get reviewYourRating => 'تقييمك';

  @override
  String get reviewHint => 'اكتب مراجعتك...';

  @override
  String get reviewUpdateHint => 'حدّث مراجعتك...';

  @override
  String get reviewEditTitle => 'تعديل المراجعة';

  @override
  String get reviewUpdate => 'تحديث المراجعة';

  @override
  String get reviewSelectRating => 'يرجى اختيار تقييم قبل إرسال المراجعة.';

  @override
  String get reviewEnterComment => 'يرجى كتابة تعليقك.';

  @override
  String get reviewSubmit => 'إرسال';

  @override
  String get reviewDeleteTitle => 'حذف المراجعة';

  @override
  String get reviewDeleteMessage => 'هل أنت متأكد أنك تريد حذف هذه المراجعة؟';

  @override
  String get reviewEditTooltip => 'تعديل المراجعة';

  @override
  String get reviewDeleteTooltip => 'حذف المراجعة';

  @override
  String get imageSearchHint => 'ابحث بالصورة';

  @override
  String get imageSearchSearching => 'جارٍ البحث...';

  @override
  String get imageSearchMatchingPlaces => 'أماكن مشابهة';

  @override
  String get imageSearchNoMatches => 'لم يتم العثور على أماكن مطابقة';

  @override
  String get imageSearchTryAnotherImage => 'جرّب صورة أخرى';

  @override
  String get imageSearchNoCamera => 'لا توجد كاميرا متاحة.';

  @override
  String get imageSearchCameraUnavailable =>
      'الكاميرا غير متاحة. تحقق من الإذن وحاول مرة أخرى.';

  @override
  String get imageSearchPhotoAccessRequired => 'يلزم السماح بالوصول إلى الصور.';

  @override
  String get imageSearchNoPhotos => 'لا توجد صور.';

  @override
  String get imageSearchPhotoOpenError => 'تعذر فتح هذه الصورة.';

  @override
  String get tripLoadingBrand => 'رحّالة AI';

  @override
  String get tripLoadingSubtitle => 'نصمم تجربة سفر فريدة لك...';

  @override
  String get tripLoadingPreference => 'نحلل تفضيلات سفرك...';

  @override
  String get tripLoadingHiddenGems => 'نكتشف أماكن مميزة لرحلتك...';

  @override
  String get tripLoadingItinerary => 'نصمم برنامجك المخصص...';

  @override
  String get tripLoadingExperiences => 'نبحث عن تجارب مميزة...';

  @override
  String get tripLoadingAlmostReady =>
      'مغامرتك المدعومة بالذكاء الاصطناعي أوشكت على الاكتمال!';
}
