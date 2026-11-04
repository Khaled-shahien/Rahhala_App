import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/localization/app_locale_controller.dart';
import 'package:rahhala_app/core/localization/app_localization_extensions.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';

class LanguagePickerBottomSheet extends StatelessWidget {
  const LanguagePickerBottomSheet({
    super.key,
    required this.localeController,
  });

  final AppLocaleController localeController;

  @override
  Widget build(BuildContext context) {
    final currentLocale = localeController.locale;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16.w, 12.h, 16.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 56.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              context.l10n.profileLanguageBottomSheetTitle,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              context.l10n.profileLanguageBottomSheetSubtitle,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16.h),
            _LanguageTile(
              title: context.l10n.languageEnglish,
              locale: const Locale('en'),
              isSelected: currentLocale.languageCode == 'en',
              flag: '🇺🇸',
              onTap: () async {
                await localeController.setLocale(const Locale('en'));
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
            SizedBox(height: 10.h),
            _LanguageTile(
              title: context.l10n.languageArabic,
              locale: const Locale('ar'),
              isSelected: currentLocale.languageCode == 'ar',
              flag: '🇪🇬',
              onTap: () async {
                await localeController.setLocale(const Locale('ar'));
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.title,
    required this.locale,
    required this.isSelected,
    required this.flag,
    required this.onTap,
  });

  final String title;
  final Locale locale;
  final bool isSelected;
  final String flag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: isSelected
                ? ThemeColor.primaryColor.withValues(alpha: 0.14)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? ThemeColor.primaryColor
                  : Colors.grey.withValues(alpha: 0.35),
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(flag, style: TextStyle(fontSize: 22.sp)),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: isSelected
                    ? Icon(
                        Icons.check_circle_rounded,
                        key: ValueKey<String>(locale.languageCode),
                        color: ThemeColor.primaryColor,
                        size: 24.sp,
                      )
                    : Icon(
                        Icons.radio_button_unchecked_rounded,
                        key: ValueKey<String>('${locale.languageCode}_off'),
                        color: Colors.grey,
                        size: 22.sp,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
