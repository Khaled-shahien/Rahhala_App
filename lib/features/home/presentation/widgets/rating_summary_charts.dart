import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'rating_stars.dart';

class RatingSummaryCard extends StatelessWidget {
  final double averageRating;
  final int totalReviews;
  final Map<int, double> stats;

  const RatingSummaryCard({
    super.key,
    required this.averageRating,
    required this.totalReviews,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            "$averageRating",
            style: TextStyle(
              fontSize: 54.sp,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          RatingStars(rating: averageRating, size: 26.w),
          SizedBox(height: 8.h),
          Text(
            "Based on $totalReviews reviews",
            style: TextStyle(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontSize: 14.sp),
          ),
          SizedBox(height: 20.h),
          Divider(
            thickness: 0.8,
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          SizedBox(height: 15.h),
          Column(
            children: [5, 4, 3, 2, 1].map((starCount) {
              double ratio = stats[starCount] ?? 0.0;
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Row(
                  children: [
                    Text("$starCount",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          color: colorScheme.onSurface,
                        )),
                    SizedBox(width: 4.w),
                    Icon(Icons.star,
                        size: 14.sp, color: const Color(0xFFB08968)),
                    SizedBox(width: 15.w),
                    // البار (Chart)
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 8.h,
                          backgroundColor: isDark
                              ? colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.3)
                              : Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFB08968)),
                        ),
                      ),
                    ),
                    SizedBox(width: 15.w),
                    SizedBox(
                      width: 35.w,
                      child: Text("${(ratio * 100).toInt()}%",
                          style: TextStyle(
                              fontSize: 13.sp,
                              color: colorScheme.onSurfaceVariant)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
