import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:rahhala_app/core/constants/app_assets.dart';
import 'package:rahhala_app/core/localization/app_localization_extensions.dart';
import 'package:rahhala_app/core/routing/app_router.dart';
import 'package:rahhala_app/core/startup/app_bootstrap_cubit.dart';
import 'package:rahhala_app/core/startup/app_bootstrap_service.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppBootstrapCubit, AppBootstrapState>(
      listener: (context, state) {
        if (state is AppBootstrapReady) {
          context.go(_routeFor(state.result.destination));
        } else if (state is AppBootstrapError) {
          context.go(AppRoutes.welcome);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 210.w,
                  height: 210.w,
                  child: SvgPicture.asset(
                    AppAssets.imagesLogo,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 32.h),
                Text(
                  'Rahhala',
                  style: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.bold,
                    color: ThemeColor.primaryColor,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  context.l10n.splashSubtitle,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 56.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _routeFor(BootstrapDestination destination) {
    return switch (destination) {
      BootstrapDestination.onboarding => AppRoutes.onboarding,
      BootstrapDestination.home => AppRoutes.home,
      BootstrapDestination.welcome => AppRoutes.welcome,
    };
  }
}
