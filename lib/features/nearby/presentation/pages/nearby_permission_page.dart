import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/constants/app_assets.dart';
import 'package:rahhala_app/core/constants/app_colors.dart';
import 'package:rahhala_app/core/constants/app_text_styles.dart';
import 'package:rahhala_app/features/nearby/domain/cubit/nearby_cubit.dart';
import 'package:rahhala_app/core/localization/app_localization_extensions.dart';

class NearbyPermissionPage extends StatelessWidget {
  const NearbyPermissionPage({super.key});

  void _handleAllowAccess(BuildContext context) {
    context.read<NearbyCubit>().requestLocationAndLoad();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Map icon circle
            Container(
              width: 280.w,
              height: 280.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.backgroundGray,
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? AppColors.primary.withValues(alpha: 0.25)
                        : AppColors.backgroundGray,
                    blurRadius: 15,
                    spreadRadius: 10,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Image.asset(
                  AppAssets.nearby,
                  width: 212.w,
                  height: 212.w,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.explore,
                      size: 80.w,
                      color: AppColors.primary,
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              context.l10n.nearbyPermissionTitle,
              style: AppTextStyles.cairoBold(
                fontSize: 20,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              context.l10n.nearbyPermissionDesc,
              style: AppTextStyles.cairoRegular(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: () => _handleAllowAccess(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    elevation: isDark ? 0 : 2,
                    shadowColor: AppColors.primary.withValues(alpha: 0.4),
                  ),
                  child: Text(
                    context.l10n.nearbyAllowAccess,
                    style: AppTextStyles.cairoBold(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
