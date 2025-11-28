import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/constants/app_text_styles.dart';
import 'package:rahhala_app/features/ai_recommendation/logic/ai_trip_cubit.dart';
import 'package:rahhala_app/features/ai_recommendation/logic/ai_trip_state.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/button.dart';

class TripInfoScreen extends StatelessWidget {
  final VoidCallback onNext;

  const TripInfoScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AiTripCubit>();

    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final governorates = [
      'Alexandria',
      'Aswan',
      'Asyut',
      'Beheira',
      'Beni Suef',
      'Cairo',
      'Dakahlia',
      'Damietta',
      'Faiyum',
      'Gharbia',
      'Giza',
      'Ismailia',
      'Kafr El Sheikh',
      'Luxor',
      'Matrouh',
      'Minya',
      'Monufia',
      'New Valley',
      'North Sinai',
      'Port Said',
      'Qalyubia',
      'Qena',
      'Red Sea',
      'Sharqia',
      'Sohag',
      'South Sinai',
      'Suez'
    ];

    return BlocBuilder<AiTripCubit, AiTripState>(
      builder: (context, state) {
        if (state is! AiTripData) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              Text('Where do you want to go?', style: AppTextStyles.heading),
              SizedBox(height: 28.h),
              _buildGovernorateSelector(
                governorates,
                state.destination,
                cubit,
              ),
              SizedBox(height: 44.h),
              Text('When do you want to go?', style: AppTextStyles.heading),
              SizedBox(height: 28.h),
              _buildDaysSelector(state.totalDays, cubit),
              SizedBox(height: 28.h),
              _buildMonthSelector(months, state.selectedMonth, cubit),
              SizedBox(height: 76.h),
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

  Widget _buildGovernorateSelector(List<String> governorates,
      String? selectedGovernorate, AiTripCubit cubit) {
    final bool isValueValid = selectedGovernorate != null &&
        governorates.contains(selectedGovernorate);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFF6A4D3B).withOpacity(0.12),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: const Color(0xFFA88866),
          width: 1.8.w,
        ),
      ),
      child: DropdownButton<String>(
        value: isValueValid ? selectedGovernorate : null,
        hint: Text(
          'Select a governorate',
          style: TextStyle(
            color: const Color(0xFF6A4D3B).withOpacity(0.8),
            fontSize: 17.sp,
          ),
        ),
        isExpanded: true,
        underline: const SizedBox.shrink(),
        icon: const Icon(Icons.map_outlined, color: Color(0xFF6A4D3B)),
        style: TextStyle(
          color: const Color(0xFF6A4D3B),
          fontSize: 17.sp,
          fontWeight: FontWeight.w500,
        ),
        dropdownColor: Colors.white,
        onChanged: (String? newValue) {
          if (newValue != null) {
            cubit.updateDestination(newValue);
          }
        },
        items: governorates.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDaysSelector(int days, AiTripCubit cubit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Total days', style: AppTextStyles.dayLabel),
        Row(
          children: [
            _buildDayButton(Icons.remove, () {
              if (days > 1) cubit.updateDays(days - 1);
            }),
            SizedBox(width: 14.w),
            Text('$days',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
            SizedBox(width: 14.w),
            _buildDayButton(Icons.add, () => cubit.updateDays(days + 1)),
          ],
        ),
      ],
    );
  }

  Widget _buildDayButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: const BoxDecoration(
          color: Color(0xFFA88866),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 22, color: Colors.white),
      ),
    );
  }

  Widget _buildMonthSelector(
      List<String> months, String? selectedMonth, AiTripCubit cubit) {
    final bool isValueValid =
        selectedMonth != null && months.contains(selectedMonth);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFF6A4D3B).withOpacity(0.12),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: const Color(0xFFA88866),
          width: 1.8.w,
        ),
      ),
      child: DropdownButton<String>(
        value: isValueValid ? selectedMonth : null,
        hint: Text(
          'Select a month',
          style: TextStyle(
            color: const Color(0xFF6A4D3B).withOpacity(0.8),
            fontSize: 17.sp,
          ),
        ),
        isExpanded: true,
        underline: const SizedBox.shrink(),
        icon:
            const Icon(Icons.calendar_month_outlined, color: Color(0xFF6A4D3B)),
        style: TextStyle(
          color: const Color(0xFF6A4D3B),
          fontSize: 17.sp,
          fontWeight: FontWeight.w500,
        ),
        dropdownColor: Colors.white,
        onChanged: (String? newValue) {
          if (newValue != null) {
            cubit.selectMonth(newValue);
          }
        },
        items: months.map<DropdownMenuItem<String>>((String month) {
          return DropdownMenuItem<String>(
            value: month,
            child: Text(month),
          );
        }).toList(),
      ),
    );
  }
}
