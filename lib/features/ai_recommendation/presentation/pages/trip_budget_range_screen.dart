import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/ai_trip_cubit.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/ai_trip_state.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/button.dart';

class TripBudgetRangeScreen extends StatelessWidget {
  final VoidCallback onNext;

  const TripBudgetRangeScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AiTripCubit>();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                'Your Budget range',
                style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface),
              ),
              SizedBox(height: 44.h),
              ...cubit.budgetRanges.map((range) => _buildBudgetToggle(
                    context,
                    range,
                    state.selectedRange == range,
                    () => cubit.selectRange(range),
                  )),
              SizedBox(height: 44.h),
              NextButton(
                onPressed: onNext,
              ),
              SizedBox(height: 44.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBudgetToggle(BuildContext context, String label, bool isSelected,
      VoidCallback onPressed) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : colorScheme.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
                width: 2.5.w),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                    fontSize: 18.sp,
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                    fontWeight: FontWeight.w500),
              ),
              Icon(
                Icons.money,
                color:
                    isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                size: 24.sp,
              )
            ],
          ),
        ),
      ),
    );
  }
}
