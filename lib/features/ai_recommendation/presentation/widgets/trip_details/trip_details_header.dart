import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/constants/app_colors.dart';
import 'package:rahhala_app/core/logging/app_logger.dart';
import 'package:rahhala_app/features/ai_recommendation/data/models/trip_plan_model.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/trip_details/trip_details_theme.dart';

class TripDetailsHeader extends StatelessWidget {
  const TripDetailsHeader({
    super.key,
    required this.plan,
    required this.isRegenerating,
    required this.onBack,
    required this.onRegenerate,
  });

  final TripPlan plan;
  final bool isRegenerating;
  final VoidCallback onBack;
  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final overlayColor = isDark ? Colors.black : const Color(0xFFF3E5D8);

    return SizedBox(
      width: double.infinity,
      height: 380.h,
      child: Stack(
        children: [
          if (plan.countryImage != null && plan.countryImage!.isNotEmpty)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35.r),
                  bottomRight: Radius.circular(35.r),
                ),
                child: Image.network(
                  plan.countryImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 380.h,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color:
                            isDark ? Colors.grey[900] : headerBackgroundColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(35.r),
                          bottomRight: Radius.circular(35.r),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    isDark
                        ? Colors.black.withValues(alpha: 0.2)
                        : theme.scaffoldBackgroundColor.withValues(alpha: 0.15),
                    isDark
                        ? Colors.black.withValues(alpha: 0.5)
                        : theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
                    theme.scaffoldBackgroundColor,
                  ],
                  stops: const [0.0, 0.45, 0.7, 0.85, 1.0],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    isDark
                        ? Colors.black.withValues(alpha: 0.15)
                        : theme.scaffoldBackgroundColor.withValues(alpha: 0.3),
                    isDark
                        ? Colors.black.withValues(alpha: 0.3)
                        : overlayColor.withValues(alpha: 0.8),
                  ],
                  stops: const [0.0, 0.5, 0.8, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: -20.h,
            right: -30.w,
            child: Image.asset(
              'assets/images/cover.png',
              width: 400.w,
              fit: BoxFit.contain,
              color: isDark ? Colors.white.withValues(alpha: 0.8) : null,
              colorBlendMode: isDark ? BlendMode.modulate : null,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12.h,
            left: 16.w,
            right: 16.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: const BoxDecoration(
                      color: Colors.black38,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                ),
                _buildRegenerateControl(isDark),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: MediaQuery.of(context).padding.top + 20.h,
              bottom: 30.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                _Title(),
                SizedBox(height: 30.h),
                _ModernPill(
                  icon: Icons.location_on_outlined,
                  text: plan.destination,
                  isDark: isDark,
                ),
                SizedBox(height: 12.h),
                _ModernPill(
                  text: 'Total cost: ${plan.totalEstimatedCost}',
                  isCost: true,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegenerateControl(bool isDark) {
    return GestureDetector(
      onTap: onRegenerate,
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: isRegenerating
            ? SizedBox(
                width: 20.sp,
                height: 20.sp,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240.w,
      child: Text(
        'Every place, every moment\nchosen just for you.',
        style: TextStyle(
          color: const Color(0xFFF3E5D8),
          fontSize: 25.sp,
          fontWeight: FontWeight.w800,
          height: 1.4,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.8),
              offset: const Offset(0, 2),
              blurRadius: 10,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernPill extends StatelessWidget {
  const _ModernPill({
    this.icon,
    required this.text,
    this.isCost = false,
    required this.isDark,
  });

  final IconData? icon;
  final String text;
  final bool isCost;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.5)
            : const Color(0xFFF3E5D8).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFF8B6F5A),
          width: 1.4,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon,
                size: 18.sp,
                color: isDark ? Colors.white : const Color(0xFF5C4634)),
            SizedBox(width: 8.w),
          ],
          Text(
            text,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF5C4634),
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
