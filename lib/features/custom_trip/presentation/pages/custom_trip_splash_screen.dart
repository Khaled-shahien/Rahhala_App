// lib/features/custom_trip/presentation/pages/custom_trip_splash_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:rahhala_app/core/constants/app_colors.dart';
import 'package:rahhala_app/core/utils/app_notifications.dart';
import 'package:rahhala_app/features/custom_trip/presentation/cubit/custom_trip_cubit.dart';
import 'package:rahhala_app/features/custom_trip/utils/trip_mapper.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/pages/trip_details_screen.dart';

class CustomTripSplashScreen extends StatefulWidget {
  final CustomTripCubit cubit;

  const CustomTripSplashScreen({super.key, required this.cubit});

  @override
  State<CustomTripSplashScreen> createState() => _CustomTripSplashScreenState();
}

class _CustomTripSplashScreenState extends State<CustomTripSplashScreen> {
  late Timer _textTimer;

  int _messageIndex = 0;

  final List<String> _loadingMessages = [
    "Analyzing your travel preferences...",
    "Discovering hidden gems for your trip...",
    "Designing your personalized itinerary...",
    "Finding exclusive experiences...",
    "Your AI-powered adventure is almost ready!"
  ];

  @override
  void initState() {
    super.initState();

    _textTimer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      if (mounted) {
        setState(() {
          _messageIndex = (_messageIndex + 1) % _loadingMessages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _textTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color topColor = AppColors.charcoal;
    const Color bottomColor = AppColors.primary;

    return BlocProvider.value(
      value: widget.cubit,
      child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            // Reset cubit when user presses back button
            widget.cubit.reset();
          }
        },
        child: BlocListener<CustomTripCubit, CustomTripState>(
          listener: (context, state) {
            if (state is CustomTripSuccess) {
              // Convert TripDataEntity to TripPlanResponse
              final tripPlanResponse = TripMapper.mapToTripPlanResponse(
                tripData: state.tripData,
                region: state.selectedRegion ?? '',
                numberOfDays: state.numberOfDays,
              );

              final geminiRequest = {
                'region': state.selectedRegion,
                'numberOfDays': state.numberOfDays,
              };

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => TripDetailsScreen(
                    tripPlan: tripPlanResponse,
                    geminiRequest: geminiRequest,
                  ),
                ),
              );
            } else if (state is CustomTripFailure) {
              showAppNotification(
                context: context,
                title: "Error",
                message: state.message,
                isError: true,
              );
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    topColor,
                    topColor.withValues(alpha: 0.9),
                    bottomColor.withValues(alpha: 0.8),
                    bottomColor,
                  ],
                  stops: const [0.0, 0.4, 0.8, 1.0],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/animations/Travel is fun.json',
                      width: 280.w,
                      height: 280.w,
                      repeat: true,
                    ),
                    SizedBox(height: 30.h),
                    Text(
                      "Rahhala AI",
                      style: TextStyle(
                        fontSize: 34.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "Crafting your unique travel experience...",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 40.h),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: Text(
                        _loadingMessages[_messageIndex],
                        key: ValueKey<int>(_messageIndex),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 14.sp,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 60.w),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 6.h,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
