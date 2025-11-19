

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:rahhala_app/features/onboarding/data/models/onboarding_model.dart';
import 'package:rahhala_app/features/onboarding/presentation/widgets/onboarding_page_widget.dart';
import 'package:rahhala_app/features/auth/presentation/pages/welcome_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _nextPage() {
    if (_currentPage < onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const WelcomePage(),
      ),
    );
  }

  void _skipOnboarding() {
    _finishOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Column(
          children: [
            
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.only(
                  top: 8.h,
                  right: 24.w,
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: onboardingPages.length,
                
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return OnboardingPageWidget(
                    page: onboardingPages[index],
                  );
                },
              ),
            ),

            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 32.w,
                  right: 32.w,
                  bottom: 40.h,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: onboardingPages.length,
                      effect: ExpandingDotsEffect(
                        activeDotColor: ThemeColor.primaryColor,
                        dotColor: Colors.grey[300]!,
                        dotHeight: 8.h,
                        dotWidth: 8.w,
                        expansionFactor: 4,
                        spacing: 8.w,
                      ),
                    ),

                    _buildNextButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    final isLastPage = _currentPage == onboardingPages.length - 1;

    return GestureDetector(
      onTap: _nextPage,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isLastPage ? 32.w : 28.w,
          vertical: 16.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.black,
            width: 2.5,
          ),
          borderRadius: BorderRadius.circular(50.r),
        ),
        child: Text(
          isLastPage ? 'Get started' : 'Next',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
