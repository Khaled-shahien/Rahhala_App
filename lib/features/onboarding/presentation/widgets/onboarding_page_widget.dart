import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rahhala_app/core/constants/app_colors.dart';
import 'package:rahhala_app/features/onboarding/data/models/onboarding_model.dart';

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingModel page;

  const OnboardingPageWidget({
    super.key,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBackground = isDark ? const Color(0xFF191817) : Colors.white;
    final titleColor = isDark ? const Color(0xFFF8F2EA) : Colors.black;
    final descriptionColor = isDark ? const Color(0xFFD8D0C5) : Colors.black;
    final highlightTextColor = isDark ? const Color(0xFF17130F) : Colors.white;

    return Container(
      color: pageBackground,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            children: [
              SizedBox(height: 30.h),
              _buildImagesLayout(context),
              SizedBox(height: 24.h),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  page.title,
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                    height: 1.1,
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? const [Color(0xFFB78B5F), Color(0xFFD2B184)]
                          : const [Color(0xFFC19A6B), Color(0xFFC19A6B)],
                    ),
                    borderRadius: BorderRadiusDirectional.only(
                      topEnd: Radius.circular(25.r),
                      bottomEnd: Radius.circular(25.r),
                    ),
                  ),
                  child: Text(
                    page.subtitle,
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w700,
                      color: highlightTextColor,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  page.description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: descriptionColor,
                    height: 1.3,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagesLayout(BuildContext context) {
    return SizedBox(
      height: 250.h,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Row(
              children: [
                Expanded(
                  child: _buildImageWithShadow(
                    context,
                    page.images.isNotEmpty ? page.images[0] : '',
                    height: 145.h,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: _buildImageWithShadow(
                    context,
                    page.images.length > 1 ? page.images[1] : '',
                    height: 145.h,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 100.h,
            left: 30.w,
            right: 30.w,
            child: _buildImageWithShadow(
              context,
              page.images.length > 2 ? page.images[2] : '',
              height: 150.h,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWithShadow(
    BuildContext context,
    String imagePath, {
    required double height,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Handle empty image path
    if (imagePath.isEmpty) {
      return _buildPlaceholder(height: height);
    }

    final isSvg = imagePath.toLowerCase().endsWith('.svg');

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.38 : 0.15),
            blurRadius: isDark ? 22 : 18,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.transparent,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.r),
        child: isSvg ? _buildSvgImage(imagePath) : _buildRasterImage(imagePath),
      ),
    );
  }

  Widget _buildSvgImage(String imagePath) {
    return SvgPicture.asset(
      imagePath,
      fit: BoxFit.cover,
      placeholderBuilder: (context) => _buildPlaceholder(),
    );
  }

  Widget _buildRasterImage(String imagePath) {
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder({double? height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.62),
            AppColors.mediumBrown.withValues(alpha: 0.62),
          ],
        ),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 30.sp,
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
