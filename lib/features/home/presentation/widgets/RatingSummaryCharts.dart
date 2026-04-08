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
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "$averageRating",
            style: TextStyle(
              fontSize: 54.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1F26),
            ),
          ),
          RatingStars(rating: averageRating, size: 26.w),
          SizedBox(height: 8.h),
          Text(
            "Based on $totalReviews reviews",
            style: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
          ),
          SizedBox(height: 20.h),
          const Divider(thickness: 0.8),
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
                            fontWeight: FontWeight.bold, fontSize: 14.sp)),
                    SizedBox(width: 4.w),
                    Icon(Icons.star,
                        size: 14.sp, color: const Color(0xFFB08968)),
                    SizedBox(width: 15.w),
                    //Charts
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 8.h,
                          backgroundColor: Colors.grey[100],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFB08968)),
                        ),
                      ),
                    ),
                    SizedBox(width: 15.w),
                    // النسبة المئوية
                    SizedBox(
                      width: 35.w,
                      child: Text("${(ratio * 100).toInt()}%",
                          style: TextStyle(
                              fontSize: 13.sp, color: Colors.grey[600])),
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
