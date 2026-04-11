import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timeago/timeago.dart' as timeago;
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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final String displayName = review.userName.contains('@')
        ? review.userName.split('@')[0]
        : review.userName;

    DateTime reviewDate = DateTime.tryParse(review.createdAt) ?? DateTime.now();
    DateTime now = DateTime.now();
    Duration difference = now.difference(reviewDate);

    String formattedDate;
    if (difference.inDays > 7) {
      formattedDate = review.createdAt.length >= 10
          ? review.createdAt.substring(0, 10)
          : review.createdAt;
    } else {
      formattedDate = timeago.format(reviewDate);
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22.r,
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                  backgroundImage: (review.userImageUrl != null &&
                          review.userImageUrl!.isNotEmpty)
                      ? NetworkImage(review.userImageUrl!)
                      : null,
                  child: (review.userImageUrl == null ||
                          review.userImageUrl!.isEmpty)
                      ? Text(
                          displayName.isNotEmpty
                              ? displayName[0].toUpperCase()
                              : "?",
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                        )
                      : null,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              displayName, // HEAD (محافظين عليه)
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15.sp,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            formattedDate.isNotEmpty
                                ? formattedDate
                                : (review.createdAt.length >= 10
                                    ? review.createdAt.substring(0, 10)
                                    : review.createdAt),
                            style: TextStyle(
                              color:
                                  colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 4.h),

                      // FEATURE من النسخة التانية (لو مش موجود عندك تجاهله)
                      RatingStars(rating: review.rating),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // نص التعليق
            Text(
              review.comment,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.4.h,
                color: colorScheme.onSurface.withValues(alpha: 0.9),
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
