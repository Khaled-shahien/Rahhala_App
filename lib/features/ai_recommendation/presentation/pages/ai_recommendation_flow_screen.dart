import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/core/constants/app_colors.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/ai_trip_cubit.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/pages/trip_budget_range_screen.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/pages/trip_info_screen.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/pages/trip_interests_screen.dart';

class AIRecommendationFlowScreen extends StatefulWidget {
  const AIRecommendationFlowScreen({super.key});

  @override
  State<AIRecommendationFlowScreen> createState() =>
      _AIRecommendationFlowScreenState();
}

class _AIRecommendationFlowScreenState
    extends State<AIRecommendationFlowScreen> {
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

  void _onBackPressed() {
    if (_currentStep == 0) {
      Navigator.pop(context);
    } else {
      _previousPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AiTripCubit(geminiRepository: sl()),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_outlined,
                color: Colors.black),
            onPressed: _onBackPressed,
          ),
          backgroundColor: AppColors.white,
          elevation: 0,
        ),
        body: PageView(
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
    );
  }
}
