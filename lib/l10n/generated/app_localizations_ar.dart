// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'رحالة';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonBack => 'رجوع';

  @override
  String get commonError => 'خطأ';

  @override
  String get commonSuccess => 'نجاح';

  @override
  String get commonComingSoon => 'قريباً...';

  @override
  String get commonGotIt => 'تم';

  @override
  String get commonUnknownError => 'خطأ غير معروف';

  @override
  String get routerPageNotFound => 'الصفحة غير موجودة';

  @override
  String get routerGoHome => 'الصفحة الرئيسية';

  @override
  String routerFeatureTitle(Object featureName) {
    return '$featureName';
  }

  @override
  String routerFeatureUnderDevelopment(Object featureName) {
    return '$featureName - قريباً!';
  }

  @override
  String get routerTripPlanner => 'مخطط الرحلة';

  @override
  String get routerDestinations => 'الوجهات';

  @override
  String routerDestinationDetails(Object id) {
    return 'تفاصيل الوجهة ($id)';
  }

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get profileNoEmail => 'لا يوجد بريد إلكتروني';

  @override
  String get profileAccount => 'الحساب';

  @override
  String get profilePreferences => 'التفضيلات';

  @override
  String get profileSupport => 'الدعم';

  @override
  String get profileDangerZone => 'منطقة خطرة';

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
  String get profileDeleteAccountConfirm => 'هل تريد حذف حسابك نهائياً؟';

  @override
  String get profileLogoutConfirm => 'هل تريد تسجيل الخروج؟';

  @override
  String get profileDeleteAction => 'حذف';

  @override
  String get profileLogoutAction => 'تسجيل الخروج';

  @override
  String get profileLanguageBottomSheetTitle => 'اختر لغة التطبيق';

  @override
  String get profileLanguageBottomSheetSubtitle => 'سيتم تطبيق التغييرات فوراً';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get homeWelcomeGuest => 'مرحباً، زائرنا!';

  @override
  String homeWelcomeUser(Object name) {
    return 'مرحباً، $name!';
  }

  @override
  String get homeExploreDestinations => 'اكتشف وجهات رائعة';

  @override
  String get homeWishlist => 'المفضلة';

  @override
  String get homeSearch => 'البحث';

  @override
  String get homeWishlistSoon => 'صفحة المفضلة - قريباً!';

  @override
  String get homeSearchSoon => 'البحث - قريباً!';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navWishlist => 'المفضلة';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get homePageContent => 'محتوى الصفحة الرئيسية';

  @override
  String homeComingSoonShort(Object title) {
    return '$title - قريباً';
  }

  @override
  String get splashSubtitle => 'رفيقك في السفر';
}
