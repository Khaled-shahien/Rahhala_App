import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/auth/auth_session_service.dart';
import 'package:rahhala_app/core/constants/app_colors.dart';
import 'package:rahhala_app/core/constants/app_text_styles.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/features/auth/presentation/pages/login_page.dart';
import 'package:rahhala_app/features/nearby/domain/cubit/nearby_cubit.dart';
import 'package:rahhala_app/features/nearby/domain/cubit/nearby_state.dart';
import 'package:rahhala_app/features/nearby/presentation/pages/nearby_permission_page.dart';
import 'package:rahhala_app/features/nearby/presentation/pages/nearby_places_page.dart';
import 'package:rahhala_app/core/localization/app_localization_extensions.dart';

class NearbyScreen extends StatelessWidget {
  const NearbyScreen({super.key, this.isGuest = false});

  final bool isGuest;

  @override
  Widget build(BuildContext context) {
    final canUseNearby = !isGuest && sl<AuthSessionService>().hasToken;
    if (!canUseNearby) {
      return const _NearbyLoginRequiredPage();
    }

    return BlocProvider(
      create: (_) => sl<NearbyCubit>(),
      child: const _NearbyBody(),
    );
  }
}

class _NearbyLoginRequiredPage extends StatelessWidget {
  const _NearbyLoginRequiredPage();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(22.r),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 50.sp,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  context.l10n.nearbyLoginRequired,
                  style: AppTextStyles.cairoBold(
                    fontSize: 20,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  context.l10n.nearbyLoginMessage,
                  style: AppTextStyles.cairoRegular(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 28.h),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 32.w,
                      vertical: 12.h,
                    ),
                  ),
                  child: Text(
                    context.l10n.commonLogin,
                    style: AppTextStyles.cairoBold(
                      fontSize: 14,
                      color: Colors.white,
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

class _NearbyBody extends StatelessWidget {
  const _NearbyBody();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<NearbyCubit, NearbyState>(
      builder: (context, state) {
        if (state is NearbyLocationLoading || state is NearbyPlacesLoading) {
          return Scaffold(
            backgroundColor: colorScheme.surface,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16.h),
                  Text(
                    state is NearbyLocationLoading
                        ? context.l10n.nearbyGettingLocation
                        : context.l10n.nearbyFindingPlaces,
                    style: AppTextStyles.cairoRegular(
                        fontSize: 14, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is NearbyPlacesLoaded) {
          return NearbyPlacesPage(
            latitude: state.latitude,
            longitude: state.longitude,
            state: state,
          );
        }

        if (state is NearbyError) {
          return Scaffold(
            backgroundColor: colorScheme.surface,
            body: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.error_outline,
                          size: 50.sp, color: AppColors.error),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      state.message,
                      style: AppTextStyles.cairoRegular(
                          fontSize: 14, color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<NearbyCubit>().requestLocationAndLoad(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                      child: Text(context.l10n.commonTryAgain,
                          style: AppTextStyles.cairoBold(
                              fontSize: 14, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is NearbyLocationDenied ||
            state is NearbyLocationPermanentlyDenied) {
          return Scaffold(
            backgroundColor: colorScheme.surface,
            body: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(
                        color: AppColors.neutralGray.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.location_off,
                          size: 50.sp, color: AppColors.neutralGray),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      state is NearbyLocationPermanentlyDenied
                          ? context.l10n.nearbyPermPermanentDenied
                          : context.l10n.nearbyPermDenied,
                      style: AppTextStyles.cairoRegular(
                          fontSize: 14, color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<NearbyCubit>().requestLocationAndLoad(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                      child: Text(context.l10n.commonTryAgain,
                          style: AppTextStyles.cairoBold(
                              fontSize: 14, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return const NearbyPermissionPage();
      },
    );
  }
}
