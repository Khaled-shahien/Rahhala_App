import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/home_model.dart';
import 'rating_stars.dart';

class ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final bool canManage;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isDeleting;

  const ReviewCard({
    super.key,
    required this.review,
    this.canManage = false,
    this.onEdit,
    this.onDelete,
    this.isDeleting = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    review.userName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                Text(
                  review.createdAt.length >= 10
                      ? review.createdAt.substring(0, 10)
                      : review.createdAt,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            RatingStars(rating: review.rating),
            SizedBox(height: 8.h),
            Text(
              review.comment,
              style: TextStyle(
                fontSize: 16.sp,
                height: 1.2.h,
              ),
            ),
            if (canManage) ...[
              SizedBox(height: 4.h),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Edit review',
                      onPressed: onEdit,
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 20.sp,
                        color: Colors.blueGrey,
                      ),
                    ),
                    IconButton(
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Delete review',
                      onPressed: isDeleting ? null : onDelete,
                      icon: isDeleting
                          ? SizedBox(
                              width: 16.w,
                              height: 16.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              Icons.delete_outline,
                              size: 20.sp,
                              color: Colors.redAccent,
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
