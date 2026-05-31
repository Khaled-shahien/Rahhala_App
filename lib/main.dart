import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/localization/app_locale_controller.dart';
import 'package:rahhala_app/core/localization/app_localization_extensions.dart';
import 'package:rahhala_app/core/routing/app_router.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';
import 'package:rahhala_app/core/theme/theme_controller.dart';
import 'package:rahhala_app/l10n/generated/app_localizations.dart';

/// Entry point of the Rahhala travel application
void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await setupServiceLocator();
  await sl<AppLocaleController>().initialize();
  await sl<AppThemeController>().initialize();
  // Run the application
  runApp(const RahhalaApp());
}

/// Main application widget that bootstraps the entire app
class RahhalaApp extends StatelessWidget {
  /// Creates a RahhalaApp widget
  const RahhalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        final localeController = sl<AppLocaleController>();
        final themeController = sl<AppThemeController>();
        return ListenableBuilder(
          listenable: Listenable.merge([localeController, themeController]),
          builder: (context, child) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              onGenerateTitle: (context) => context.l10n.appTitle,
              routerConfig: AppRouter.router,
              locale: localeController.locale,
              supportedLocales: AppLocaleController.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              localeResolutionCallback: (locale, supportedLocales) {
                if (locale == null) {
                  return AppLocaleController.fallbackLocale;
                }

                for (final supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode == locale.languageCode) {
                    return supportedLocale;
                  }
                }

                return AppLocaleController.fallbackLocale;
              },
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeController.themeMode,
            );
          },
        );
      },
    );
  }
}
