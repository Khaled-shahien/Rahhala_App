import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/constants/app_text_styles.dart';
import 'package:rahhala_app/features/custom_trip/presentation/constants/egypt_governorates.dart';
import 'package:rahhala_app/features/custom_trip/presentation/cubit/custom_trip_cubit.dart';
import 'package:rahhala_app/core/localization/app_localization_extensions.dart';

class CustomTripInputStep extends StatelessWidget {
  final VoidCallback onNext;

  const CustomTripInputStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CustomTripCubit>();

    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<CustomTripCubit, CustomTripState>(
      builder: (context, state) {
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
                context.l10n.customTripWhereToGo,
                style: AppTextStyles.heading.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 16.h),
              _buildGovernorateSelector(
                  context, state.selectedRegion, cubit, colorScheme),
              SizedBox(height: 44.h),
              Text(
                context.l10n.customTripHowManyDays,
                style: AppTextStyles.heading.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 20.h),
              _buildDaysSelector(context, state.numberOfDays, cubit, colorScheme),
              SizedBox(height: 60.h),
              _buildNextButton(context, state, onNext),
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
            margin: EdgeInsetsDirectional.only(end: i < 2 ? 8.w : 0),
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFA88866),
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
    CustomTripCubit cubit,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onTap: () => _showGovernorateSheet(context, selected, cubit),
      child: AbsorbPointer(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: const Color(0xFFA88866),
              width: 1.8.w,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Color(0xFFA88866)),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  selected ?? context.l10n.customTripSelectGovernorate,
                  style: TextStyle(
                    color: selected != null
                        ? colorScheme.onSurface
                        : colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Color(0xFFA88866)),
            ],
          ),
        ),
      ),
    );
  }

  void _showGovernorateSheet(
    BuildContext context,
    String? selected,
    CustomTripCubit cubit,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
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
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  context.l10n.customTripSelectGovernorateTitle,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
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
                      color: colorScheme.outlineVariant,
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
                            color: colorScheme.onSurface,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle,
                                color: const Color(0xFFA88866), size: 20.sp)
                            : null,
                        onTap: () {
                          cubit.updateRegion(gov);
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

  Widget _buildDaysSelector(
      BuildContext context, int days, CustomTripCubit cubit, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
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
            context.l10n.customTripTotalDays,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
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
                  color: colorScheme.onSurface,
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

  Widget _buildDayButton(
      {required IconData icon, required VoidCallback onPressed}) {
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

  Widget _buildNextButton(BuildContext context, CustomTripState state, VoidCallback onNext) {
    final isEnabled =
        state.selectedRegion != null && state.selectedRegion!.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? onNext : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFA88866),
          disabledBackgroundColor:
              const Color(0xFFA88866).withValues(alpha: 0.4),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
          elevation: 0,
        ),
        child: Text(
          context.l10n.commonNext,
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
