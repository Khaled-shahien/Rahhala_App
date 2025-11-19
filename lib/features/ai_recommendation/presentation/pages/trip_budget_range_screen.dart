

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/constants/app_colors.dart';
import 'package:rahhala_app/features/ai_recommendation/logic/ai_trip_cubit.dart';
import 'package:rahhala_app/features/ai_recommendation/logic/ai_trip_state.dart'; 
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/button.dart';

class TripBudgetRangeScreen extends StatelessWidget {
  final VoidCallback onNext;

  const TripBudgetRangeScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    
    final cubit = context.read<AiTripCubit>();

    return BlocBuilder<AiTripCubit, AiTripState>(
      builder: (context, state) {
        
        if (state is! AiTripData) {

          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 50.h),
              Text(
                'Your Budget range',
                style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black),
              ),
              SizedBox(height: 40.h),
              
              ...cubit.budgetRanges.map((range) => _buildBudgetToggle(
                    range,
                    
                    state.selectedRange == range,
                    () => cubit.selectRange(range), 
                  )),
              SizedBox(height: 40.h),
              NextButton(
                onPressed: onNext,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBudgetToggle(
      String label, bool isSelected, VoidCallback onPressed) {
    
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.borderDark,
                width: 2.w),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                    fontSize: 16.sp,
                    color: isSelected ? AppColors.white : AppColors.black,
                    fontWeight: FontWeight.w500),
              ),
              Icon(
                Icons.money,
                color: isSelected ? AppColors.white : AppColors.black,
                size: 20.sp,
              )
            ],
          ),
        ),
      ),
    );
  }
}
