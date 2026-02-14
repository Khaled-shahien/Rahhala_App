import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/ai_trip_cubit.dart';

import 'package:rahhala_app/features/ai_recommendation/presentation/pages/trip_budget_range_screen.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/pages/trip_info_screen.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/pages/trip_interests_screen.dart';
import 'package:rahhala_app/core/constants/app_colors.dart';

class AIRecommendationTabFlow extends StatefulWidget {
  const AIRecommendationTabFlow({super.key});

  @override
  State<AIRecommendationTabFlow> createState() =>
      _AIRecommendationTabFlowState();
}

class _AIRecommendationTabFlowState extends State<AIRecommendationTabFlow> {
  late PageController _pageController;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildNavigationHeader() {
    return Container(
      height: 60.0,
      color: AppColors.backgroundGray,
      alignment: Alignment.centerLeft,
      child: _currentStep == 0
          ? const SizedBox.shrink()
          : IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_outlined,
                  color: Colors.black),
              onPressed: _previousPage,
            ),
    );
  }

  Widget _buildDashedProgress(int currentStep) {
    const int totalSteps = 3;
    List<Widget> dashes = [];

    for (int i = 0; i < totalSteps; i++) {
      bool isActive = i <= currentStep;
      dashes.add(
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 6.h,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
        ),
      );
      if (i < totalSteps - 1) {
        dashes.add(SizedBox(width: 10.w));
      }
    }
    return Row(children: dashes);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AiTripCubit>(),
      child: Column(
        children: [
          _buildNavigationHeader(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 44.w, vertical: 20.h),
            child: _buildDashedProgress(_currentStep),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) {
                setState(() {
                  _currentStep = page;
                });
              },
              children: [
                TripInfoScreen(onNext: _nextPage),
                TripBudgetRangeScreen(onNext: _nextPage),
                const TripInterestsScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
