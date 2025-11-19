

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';
import 'package:rahhala_app/core/utils/token_storage.dart';
import 'package:rahhala_app/features/auth/presentation/pages/welcome_page.dart';
import 'package:rahhala_app/features/auth/presentation/pages/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    
    await Future.delayed(const Duration(seconds: 5));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();

    final hasSeenOnboarding = prefs.getBool('onboarding_done') ?? false;

    final hasToken = sl<TokenStorage>().hasToken;

    if (!hasSeenOnboarding) {
      
      _navigateToOnboarding();
    } else if (hasToken) {
      
      _navigateToHome();
    } else {
      
      _navigateToWelcome();
    }
  }

  void _navigateToOnboarding() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const OnboardingScreen(),
      ),
    );
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomePage(isGuest: false),
      ),
    );
  }

  void _navigateToWelcome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const WelcomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: ThemeColor.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.flight_takeoff_rounded,
                size: 60.sp,
                color: ThemeColor.primaryColor,
              ),
            ),
            SizedBox(height: 24.h),

            Text(
              'Rahhala',
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: ThemeColor.primaryColor,
              ),
            ),
            SizedBox(height: 8.h),

            Text(
              'Your Travel Companion',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 48.h),

            SizedBox(
              width: 40.w,
              height: 40.w,
              child: const CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  ThemeColor.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
