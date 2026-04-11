import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/ai_trip_cubit.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/ai_trip_state.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/pages/trip_splash_screen.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/button.dart';

class TripInterestsScreen extends StatelessWidget {
  const TripInterestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AiTripCubit>();
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<AiTripCubit, AiTripState>(
      builder: (context, state) {
        if (state is! AiTripData) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30.h),
              Text(
                'What are you most\nexcited to do on your trip?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 36.h),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cubit.availableInterests.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 18.h,
                  crossAxisSpacing: 18.w,
                  childAspectRatio: 3.2,
                ),
                itemBuilder: (context, index) {
                  final interest = cubit.availableInterests[index];
                  final isSelected = state.selectedInterests.contains(interest);

                  return _buildInterestToggle(
                    context,
                    interest,
                    isSelected,
                    () => cubit.toggleInterest(interest),
                  );
                },
              ),
              SizedBox(height: 44.h),
              NextButton(
                onPressed: () {
                  cubit.generateTripPlan();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider.value(
                        value: cubit,
                        child: const TripSplashScreen(),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 44.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInterestToggle(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onPressed,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 56.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.primary : colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
          width: 2.w,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
