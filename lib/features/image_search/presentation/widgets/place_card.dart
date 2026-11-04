import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:rahhala_app/features/image_search/data/models/image_search_model.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';

class PlaceCard extends StatelessWidget {
  final PlaceResult place;

  const PlaceCard({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color:
                isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Image ─────────────────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: place.photoUrl,
                  height: 180.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Shimmer.fromColors(
                    baseColor:
                        isDark ? Colors.grey[800]! : Colors.grey.shade300,
                    highlightColor:
                        isDark ? Colors.grey[700]! : Colors.grey.shade100,
                    child: Container(
                      height: 180.h,
                      color: colorScheme.surface,
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 180.h,
                    color: isDark ? Colors.grey[900] : Colors.grey.shade200,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 40.sp,
                      color: Colors.grey,
                    ),
                  ),
                ),
                // Rating badge
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? colorScheme.secondaryContainer
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded,
                            color: Colors.amber, size: 16.sp),
                        SizedBox(width: 4.w),
                        Text(
                          place.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    // Stars
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          i < place.rating.floor()
                              ? Icons.star_rounded
                              : i < place.rating
                                  ? Icons.star_half_rounded
                                  : Icons.star_outline_rounded,
                          color: Colors.amber,
                          size: 16.sp,
                        );
                      }),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '(${place.rating.toStringAsFixed(1)})',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16.sp,
                      color: ThemeColor.primaryColor,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        place.address,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
