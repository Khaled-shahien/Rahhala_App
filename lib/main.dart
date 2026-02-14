import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';
import 'package:rahhala_app/features/splash/presentation/pages/splash_screen.dart';

/// Entry point of the Rahhala travel application
void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await setupServiceLocator();

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
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Rahhala App',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode
              .system, // Can be ThemeMode.light, ThemeMode.dark, or ThemeMode.system
          home: const SplashScreen(),
        );
      },
    );
  }
}
