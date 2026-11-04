import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:rahhala_app/core/routing/app_router.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';
import 'package:rahhala_app/core/widgets/background_decorator.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:rahhala_app/features/onboarding/data/models/onboarding_model.dart';
import 'package:rahhala_app/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:rahhala_app/features/onboarding/presentation/widgets/onboarding_page_widget.dart';
import 'package:rahhala_app/core/localization/app_localization_extensions.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage(BuildContext context, int currentPage, int pageCount) {
    if (currentPage < pageCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      context.read<OnboardingCubit>().completeOnboarding();
    }
  }

  void _skipOnboarding(BuildContext context) {
    context.read<OnboardingCubit>().completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final pages = getOnboardingPages(context.l10n);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0F1110) : Colors.white;
    final cardColor = isDark ? const Color(0xFF191817) : Colors.white;
    final cardBorderColor = isDark
        ? const Color(0xFF3A332B)
        : ThemeColor.primaryColor.withValues(alpha: 0.08);
    final primaryTextColor =
        isDark ? const Color(0xFFF5EFE6) : ThemeColor.charcoalColor;
    final secondaryTextColor =
        isDark ? const Color(0xFFBDB2A5) : Colors.grey[700]!;

    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state.isCompleted) {
          context.go(AppRoutes.welcome);
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: backgroundColor,
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: (isDark
                    ? SystemUiOverlayStyle.light
                    : SystemUiOverlayStyle.dark)
                .copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: backgroundColor,
              systemNavigationBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
            ),
            child: SafeArea(
              child: _OnboardingBackground(
                isDark: isDark,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 10.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF22201D)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.black.withValues(alpha: 0.32)
                                      : ThemeColor.primaryColor
                                          .withValues(alpha: 0.14),
                                  blurRadius: isDark ? 18 : 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                              border: Border.all(
                                color: isDark
                                    ? ThemeColor.primaryColor
                                        .withValues(alpha: 0.18)
                                    : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.flight_takeoff_rounded,
                                  size: 20.sp,
                                  color: ThemeColor.primaryColor,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Rahhala',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: primaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: state.isCompleting
                                ? null
                                : () => _skipOnboarding(context),
                            style: TextButton.styleFrom(
                              foregroundColor: primaryTextColor,
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 10.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              context.l10n.onboardingSkip,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: primaryTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(28.r),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withValues(alpha: 0.38)
                                    : ThemeColor.primaryColor
                                        .withValues(alpha: 0.12),
                                blurRadius: isDark ? 28 : 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            border: Border.all(
                              color: cardBorderColor,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.r),
                            child: PageView.builder(
                              controller: _pageController,
                              onPageChanged:
                                  context.read<OnboardingCubit>().pageChanged,
                              itemCount: pages.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return OnboardingPageWidget(
                                  page: pages[index],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: 24.w,
                          end: 24.w,
                          bottom: 30.h,
                          top: 20.h,
                        ),
                        child: Column(
                          children: [
                            Text(
                              context.l10n.onboardingTagline,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: secondaryTextColor,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: 18.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SmoothPageIndicator(
                                  controller: _pageController,
                                  count: pages.length,
                                  effect: ExpandingDotsEffect(
                                    activeDotColor: ThemeColor.primaryColor,
                                    dotColor: isDark
                                        ? Colors.white.withValues(alpha: 0.24)
                                        : Colors.grey[300]!,
                                    dotHeight: 10.h,
                                    dotWidth: 10.w,
                                    expansionFactor: 4,
                                    spacing: 10.w,
                                  ),
                                ),
                                _buildNextButton(
                                  context,
                                  state.currentPage,
                                  pages.length,
                                  state.isCompleting,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNextButton(
    BuildContext context,
    int currentPage,
    int pageCount,
    bool isCompleting,
  ) {
    final isLastPage = currentPage == pageCount - 1;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonColors = isDark
        ? const [Color(0xFFB88D61), Color(0xFFD7B98D)]
        : [
            ThemeColor.primaryColor,
            ThemeColor.primaryColor.withValues(alpha: 0.8),
          ];

    return GestureDetector(
      onTap: isCompleting
          ? null
          : () => _nextPage(context, currentPage, pageCount),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isLastPage ? 28.w : 24.w,
          vertical: 14.h,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: buttonColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.35)
                  : ThemeColor.primaryColor.withValues(alpha: 0.28),
              blurRadius: isDark ? 20 : 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isLastPage
                  ? context.l10n.onboardingStart
                  : context.l10n.onboardingNext,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFF17130F) : Colors.white,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isLastPage ? Icons.check_rounded : Icons.arrow_forward_rounded,
                size: 18.sp,
                color: isDark ? const Color(0xFF17130F) : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingBackground extends StatelessWidget {
  const _OnboardingBackground({
    required this.child,
    required this.isDark,
  });

  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (!isDark) {
      return BackgroundDecorator(child: child);
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF151412),
            Color(0xFF171512),
            Color(0xFF101110),
            Color(0xFF090A0A),
          ],
          stops: [0.0, 0.42, 0.74, 1.0],
        ),
      ),
      child: child,
    );
  }
}
