import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/constants/app_text_styles.dart';
import 'package:rahhala_app/features/ai_recommendation/logic/ai_trip_cubit.dart';
import 'package:rahhala_app/features/ai_recommendation/logic/ai_trip_state.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/button.dart';
import 'package:country_picker/country_picker.dart';

class TripInfoScreen extends StatelessWidget {
  final VoidCallback onNext;

  const TripInfoScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AiTripCubit>();

    final seasons = [
      {'value': 'Winter', 'label': 'Winter (December - February)'},
      {'value': 'Spring', 'label': 'Spring (March - May)'},
      {'value': 'Summer', 'label': 'Summer (June - August)'},
      {'value': 'Autumn', 'label': 'Autumn (September - November)'},
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
              _buildCountrySelector(context, state.destination, cubit),
              SizedBox(height: 44.h),
              Text('When do you want to go?', style: AppTextStyles.heading),
              SizedBox(height: 28.h),
              _buildDaysSelector(state.totalDays, cubit),
              SizedBox(height: 28.h),
              _buildSeasonSelector(seasons, state.selectedMonth, cubit),
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

  Widget _buildCountrySelector(
      BuildContext context, String? selectedCountry, AiTripCubit cubit) {
    return GestureDetector(
      onTap: () {
        showCountryPicker(
          context: context,
          showPhoneCode: false,
          onSelect: (Country country) {
            cubit.updateDestination(country.name);
          },
        );
      },
      child: AbsorbPointer(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: const Color(0xFF6A4D3B).withOpacity(0.12),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: const Color(0xFFA88866),
              width: 1.8.w,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.public, color: Color(0xFF6A4D3B)),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  selectedCountry ?? 'Select a country',
                  style: TextStyle(
                    color: selectedCountry != null
                        ? const Color(0xFF6A4D3B)
                        : const Color(0xFF6A4D3B).withOpacity(0.8),
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Color(0xFF6A4D3B)),
            ],
          ),
        ),
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

  Widget _buildSeasonSelector(List<Map<String, String>> seasons,
      String? selectedSeason, AiTripCubit cubit) {
    final hasValidSelection = selectedSeason != null &&
        seasons.any((season) => season['value'] == selectedSeason);

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
        value: hasValidSelection ? selectedSeason : null,
        hint: Text(
          'Select a season',
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
        items: seasons.map<DropdownMenuItem<String>>((season) {
          return DropdownMenuItem<String>(
            value: season['value'],
            child: Text(season['label']!),
          );
        }).toList(),
      ),
    );
  }
}
