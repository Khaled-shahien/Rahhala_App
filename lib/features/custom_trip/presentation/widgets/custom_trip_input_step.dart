import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/constants/app_text_styles.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/ai_trip_cubit.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/ai_trip_state.dart';
import 'package:rahhala_app/features/custom_trip/presentation/constants/egypt_governorates.dart';

class CustomTripInputStep extends StatelessWidget {
  final VoidCallback onNext;

  const CustomTripInputStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AiTripCubit>();

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
              _buildProgressIndicator(),
              SizedBox(height: 36.h),
              Text(
                'Where do you want to go?',
                style: AppTextStyles.heading,
              ),
              SizedBox(height: 16.h),
              _buildGovernorateSelector(context, state.destination, cubit),
              SizedBox(height: 44.h),
              Text(
                'How many days?',
                style: AppTextStyles.heading,
              ),
              SizedBox(height: 20.h),
              _buildDaysSelector(state.totalDays, cubit),
              SizedBox(height: 60.h),
              _buildNextButton(state, onNext),
              SizedBox(height: 44.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(1, (i) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 2 ? 8.w : 0),
            height: 4.h,
            decoration: BoxDecoration(
              color: i == 0
                  ? const Color(0xFFA88866)
                  : const Color(0xFFA88866).withOpacity(0.25),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildGovernorateSelector(
    BuildContext context,
    String? selected,
    AiTripCubit cubit,
  ) {
    return GestureDetector(
      onTap: () => _showGovernorateSheet(context, selected, cubit),
      child: AbsorbPointer(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: const Color(0xFF6A4D3B).withOpacity(0.08),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: const Color(0xFFA88866),
              width: 1.8.w,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Color(0xFF6A4D3B)),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  selected ?? 'Select a governorate',
                  style: TextStyle(
                    color: selected != null
                        ? const Color(0xFF6A4D3B)
                        : const Color(0xFF6A4D3B).withOpacity(0.6),
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

  void _showGovernorateSheet(
    BuildContext context,
    String? selected,
    AiTripCubit cubit,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (_, scrollController) {
            return Column(
              children: [
                SizedBox(height: 12.h),
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Select Governorate',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3E3431),
                  ),
                ),
                SizedBox(height: 12.h),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: egyptGovernorates.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: Colors.grey.shade100,
                    ),
                    itemBuilder: (_, index) {
                      final gov = egyptGovernorates[index];
                      final isSelected = gov == selected;
                      return ListTile(
                        dense: true,
                        title: Text(
                          gov,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? const Color(0xFF6A4D3B)
                                : const Color(0xFF3E3431),
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: const Color(0xFFA88866),
                                size: 20.sp,
                              )
                            : null,
                        onTap: () {
                          cubit.updateDestination(gov);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDaysSelector(int days, AiTripCubit cubit) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFF6A4D3B).withOpacity(0.08),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: const Color(0xFFA88866),
          width: 1.8.w,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total days',
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6A4D3B),
            ),
          ),
          Row(
            children: [
              _buildDayButton(
                icon: Icons.remove,
                onPressed: () {
                  if (days > 1) cubit.updateDays(days - 1);
                },
              ),
              SizedBox(width: 16.w),
              Text(
                '$days',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3E3431),
                ),
              ),
              SizedBox(width: 16.w),
              _buildDayButton(
                icon: Icons.add,
                onPressed: () => cubit.updateDays(days + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: const BoxDecoration(
          color: Color(0xFFA88866),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }

  Widget _buildNextButton(AiTripData state, VoidCallback onNext) {
    final isEnabled =
        state.destination != null && state.destination!.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? onNext : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFA88866),
          disabledBackgroundColor: const Color(0xFFA88866).withOpacity(0.4),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
          elevation: 0,
        ),
        child: Text(
          'Next',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
