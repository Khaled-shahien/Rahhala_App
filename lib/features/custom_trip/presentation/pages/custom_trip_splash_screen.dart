import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:rahhala_app/core/constants/app_colors.dart';
import 'package:rahhala_app/features/ai_recommendation/data/models/trip_plan_model.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/pages/trip_details_screen.dart';

class CustomTripSplashScreen extends StatefulWidget {
  final String destination;
  final int days;

  const CustomTripSplashScreen({
    super.key,
    required this.destination,
    required this.days,
  });

  @override
  State<CustomTripSplashScreen> createState() => _CustomTripSplashScreenState();
}

class _CustomTripSplashScreenState extends State<CustomTripSplashScreen> {
  late Timer _textTimer;
  late Timer _navTimer;
  int _messageIndex = 0;

  final List<String> _loadingMessages = [
    "Exploring Egypt's hidden treasures...",
    "Crafting your perfect governorate journey...",
    "Discovering local experiences just for you...",
    "Mapping your adventure across Egypt...",
    "Your personalized Egypt trip is almost ready!",
  ];

  @override
  void initState() {
    super.initState();

    _textTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _messageIndex = (_messageIndex + 1) % _loadingMessages.length;
        });
      }
    });

    _navTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TripDetailsScreen(
            tripPlan: _buildMockTrip(),
            geminiRequest: {
              'country': widget.destination,
              'numberOfDays': widget.days,
            },
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _textTimer.cancel();
    _navTimer.cancel();
    super.dispose();
  }

  TripPlanResponse _buildMockTrip() {
    final List<DailyPlan> days = List.generate(widget.days, (i) {
      final dayNum = i + 1;
      return DailyPlan(
        day: dayNum,
        title: 'Explore ${widget.destination} - Day $dayNum',
        estimatedDayCost: '${(dayNum * 800) + 1200} EGP',
        activities: [
          Activity(
            time: '09:00 AM',
            place: '${widget.destination} Historic Center',
            description:
                'Start your day exploring the heart of ${widget.destination}. '
                'Walk through the main streets and soak in the local culture and architecture.',
            estimatedCost: '200 EGP',
            transportation: [
              Transportation(
                from: 'Hotel',
                to: '${widget.destination} Historic Center',
                method: 'Taxi',
                estimatedCost: '50 EGP',
              ),
            ],
          ),
          Activity(
            time: '12:00 PM',
            place: 'Local Restaurant',
            description:
                'Enjoy a traditional Egyptian lunch featuring local specialties of ${widget.destination} region.',
            estimatedCost: '150 EGP',
            transportation: [
              Transportation(
                from: '${widget.destination} Historic Center',
                to: 'Local Restaurant',
                method: 'Walking',
                estimatedCost: '0 EGP',
              ),
            ],
          ),
          Activity(
            time: '02:00 PM',
            place: '${widget.destination} Museum',
            description:
                'Visit the local museum to discover the rich history and heritage of '
                '${widget.destination} and its surrounding region.',
            estimatedCost: '100 EGP',
            transportation: [
              Transportation(
                from: 'Local Restaurant',
                to: '${widget.destination} Museum',
                method: 'Taxi',
                estimatedCost: '40 EGP',
              ),
            ],
          ),
        ],
      );
    });

    return TripPlanResponse(
      success: true,
      savedId: 0,
      response: TripPlan(
        destination: widget.destination,
        days: days,
        totalEstimatedCost: '${widget.days * 2000} EGP',
        budgetTips:
            'Book accommodations in advance to get better rates in ${widget.destination}. '
            'Use local transportation instead of tourist taxis to save money. '
            'Visit attractions early morning to avoid crowds and extra fees.',
        travelTips:
            'Best time to visit ${widget.destination} is during spring and autumn. '
            'Carry enough water especially during summer months. '
            'Respect local customs and dress modestly when visiting religious sites.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color topColor = AppColors.charcoal;
    const Color bottomColor = AppColors.primary;

    return Scaffold(
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
        child: SafeArea(
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
                  'Rahhala AI',
                  style: TextStyle(
                    fontSize: 34.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Crafting your ${widget.destination} adventure...',
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
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
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
