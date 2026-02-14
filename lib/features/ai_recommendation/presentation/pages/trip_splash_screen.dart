import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:rahhala_app/core/utils/app_notifications.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/ai_trip_cubit.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/ai_trip_state.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/pages/trip_details_screen.dart';
import 'package:rahhala_app/core/constants/app_colors.dart';

class TripSplashScreen extends StatefulWidget {
  const TripSplashScreen({super.key});

  @override
  State<TripSplashScreen> createState() => _TripSplashScreenState();
}

class _TripSplashScreenState extends State<TripSplashScreen> {
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

    return BlocListener<AiTripCubit, AiTripState>(
      listener: (context, state) {
        if (state is AiTripSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => TripDetailsScreen(
                tripPlan: state.response,
                geminiRequest: state.geminiRequest,
              ),
            ),
          );
        } else if (state is AiTripFailure) {
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
                topColor.withOpacity(0.9),
                bottomColor.withOpacity(0.8),
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
                    color: Colors.white.withOpacity(0.9),
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
                      color: Colors.white.withOpacity(0.85),
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
                      backgroundColor: Colors.white.withOpacity(0.2),
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
    );
  }
}
