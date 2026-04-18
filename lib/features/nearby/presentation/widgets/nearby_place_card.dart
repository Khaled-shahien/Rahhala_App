import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/constants/app_colors.dart';
import 'package:rahhala_app/core/constants/app_text_styles.dart';
import 'package:rahhala_app/features/nearby/data/models/nearby_place_model.dart';

class NearbyPlaceCard extends StatelessWidget {
  final NearbyPlaceModel place;
  const NearbyPlaceCard({super.key, required this.place});

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Restaurant':
        return const Color(0xFFA1887F);
      case 'Cafe':
        return const Color(0xFF8B5E3C);
      case 'Shopping':
        return const Color(0xFF1976D2);
      case 'Emergency':
        return const Color(0xFFD32F2F);
      case 'Supermarket':
        return const Color.fromARGB(255, 6, 103, 10);
      default:
        return AppColors.primary;
    }
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Restaurant':
        return Icons.restaurant;
      case 'Cafe':
        return Icons.local_cafe;
      case 'Shopping':
        return Icons.shopping_bag_outlined;
      case 'Emergency':
        return Icons.local_hospital_outlined;
      case 'Supermarket':
        return Icons.local_grocery_store_outlined;
      default:
        return Icons.place_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final catColor = _categoryColor(place.primaryCategory);
    final isOpen = place.openNow;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.07),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: isDark
            ? Border.all(color: Colors.white.withValues(alpha: 0.06))
            : null,
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              bottomLeft: Radius.circular(20.r),
            ),
            child: place.photoUrl != null
                ? CachedNetworkImage(
                    imageUrl: place.photoUrl!,
                    width: 110.w,
                    height: 120.h,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 110.w,
                      height: 120.h,
                      color: isDark
                          ? catColor.withValues(alpha: 0.15)
                          : AppColors.backgroundGray,
                      child: Icon(_categoryIcon(place.primaryCategory),
                          color: catColor, size: 36.sp),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 110.w,
                      height: 120.h,
                      color: isDark
                          ? catColor.withValues(alpha: 0.15)
                          : AppColors.backgroundGray,
                      child: Icon(_categoryIcon(place.primaryCategory),
                          color: catColor, size: 36.sp),
                    ),
                  )
                : Container(
                    width: 110.w,
                    height: 120.h,
                    color: isDark
                        ? catColor.withValues(alpha: 0.15)
                        : catColor.withValues(alpha: 0.1),
                    child: Icon(_categoryIcon(place.primaryCategory),
                        color: catColor, size: 40.sp),
                  ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    place.name,
                    style: AppTextStyles.cairoSemiBold(
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5.h),
                  // Category badge
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                          color:
                              catColor.withValues(alpha: isDark ? 0.4 : 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_categoryIcon(place.primaryCategory),
                            size: 10.sp, color: catColor),
                        SizedBox(width: 4.w),
                        Text(
                          place.primaryCategory,
                          style: AppTextStyles.cairoMedium(
                              fontSize: 10, color: catColor),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 6.h),
                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 12.sp, color: AppColors.neutralGray),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          place.vicinity,
                          style: AppTextStyles.cairoRegular(
                              fontSize: 11, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  // Distance + Rating
                  Row(
                    children: [
                      Icon(Icons.near_me,
                          size: 12.sp, color: AppColors.primary),
                      SizedBox(width: 3.w),
                      Text(
                        place.formattedDistance,
                        style: AppTextStyles.cairoRegular(
                            fontSize: 11, color: AppColors.textSecondary),
                      ),
                      if (place.rating != null) ...[
                        SizedBox(width: 10.w),
                        Icon(Icons.star, size: 12.sp, color: Colors.amber),
                        SizedBox(width: 2.w),
                        Text(
                          place.rating!.toStringAsFixed(1),
                          style: AppTextStyles.cairoMedium(
                            fontSize: 11,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  // Open/Closed
                  if (isOpen != null)
                    Row(
                      children: [
                        Container(
                          width: 7.w,
                          height: 7.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                isOpen ? AppColors.darkGreen : AppColors.error,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          isOpen ? 'Open Now' : 'Closed',
                          style: AppTextStyles.cairoMedium(
                            fontSize: 11,
                            color:
                                isOpen ? AppColors.darkGreen : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
    );
  }
}
