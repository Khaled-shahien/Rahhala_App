import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/constants/app_colors.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/utils/token_storage.dart';
import 'package:rahhala_app/features/home/data/models/home_model.dart';
import 'package:rahhala_app/features/home/presentation/details_cubit/place_details_cubit.dart';
import 'package:rahhala_app/features/home/presentation/details_cubit/place_details_state.dart';
import 'package:rahhala_app/features/home/presentation/details_cubit/review_cubit.dart';
import 'package:rahhala_app/features/home/presentation/widgets/RatingSummaryCharts.dart';
import '../widgets/horizontal_section.dart';
import '../widgets/review_card.dart';
import '../widgets/submit_review.dart';

class PlaceDetailsScreen extends StatefulWidget {
  final String placeId;

  const PlaceDetailsScreen({super.key, required this.placeId});

  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  Future<void> _openEditReviewSheet(
    BuildContext context,
    ReviewModel review,
  ) async {
    final reviewCubit = context.read<ReviewCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (sheetContext) {
        return _EditReviewSheet(
          initialComment: review.comment,
          initialRating: review.rating,
          onSubmit: (comment, rating) {
            reviewCubit.updateReview(review.id, comment, rating);
            Navigator.of(sheetContext).pop();
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteReview(
    BuildContext context,
    ReviewModel review,
  ) async {
    final reviewCubit = context.read<ReviewCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text(
            'Delete Review',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete this review?',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontSize: 14.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text('Cancel',
                  style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text('Delete',
                  style: TextStyle(color: Colors.white, fontSize: 14.sp)),
            ),
          ],
        );
      },
    );

    if (approved == true) {
      reviewCubit.deleteReview(review.id);
    }
  }

  bool _isMyReview(ReviewModel review) {
    final storage = sl<TokenStorage>();
    final currentValues = <String>{
      if ((storage.email ?? '').trim().isNotEmpty)
        storage.email!.trim().toLowerCase(),
      if ((storage.username ?? '').trim().isNotEmpty)
        storage.username!.trim().toLowerCase(),
      if ((storage.fullName ?? '').trim().isNotEmpty)
        storage.fullName!.trim().toLowerCase(),
      storage.displayName.trim().toLowerCase(),
    };
    return currentValues.contains(review.userName.trim().toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF121212) : Colors.grey[100]!;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              sl<PlaceDetailsCubit>()..getPlaceDetails(widget.placeId),
        ),
        BlocProvider(
          create: (context) => sl<ReviewCubit>(),
        ),
      ],
      child: Scaffold(
        backgroundColor: scaffoldBg,
        body: BlocBuilder<PlaceDetailsCubit, PlaceDetailsState>(
          builder: (context, state) {
            if (state is PlaceDetailsLoading) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            } else if (state is PlaceDetailsError) {
              return Center(
                child: Text(state.message,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface)),
              );
            } else if (state is PlaceDetailsSuccess) {
              final place = state.placeDetails;

              return BlocListener<ReviewCubit, ReviewState>(
                listener: (context, reviewState) {
                  if (reviewState is ReviewSuccess) {
                    // reload place details after review action
                    context
                        .read<PlaceDetailsCubit>()
                        .getPlaceDetails(widget.placeId);
                  }
                },
                child: CustomScrollView(
                  slivers: [
                    // ─── Header ────────────────────────────────────────
                    SliverAppBar(
                      expandedHeight: 250.h,
                      pinned: true,
                      backgroundColor: AppColors.mediumBrown,
                      leading: CircleAvatar(
                        backgroundColor: Colors.black26,
                        child: IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(
                          place.name,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              place.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFFF2E7D5),
                                child: Icon(Icons.landscape_outlined,
                                    color: AppColors.lightBrown, size: 50.sp),
                              ),
                            ),
                            const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black54],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ─── Content ───────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10.h),

                            // Description
                            Text(
                              "Description",
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              place.description,
                              style: TextStyle(
                                fontSize: 15.sp,
                                height: 1.5,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.8),
                              ),
                            ),
                            SizedBox(height: 20.h),

                            // Restaurants
                            HorizontalSection(
                              title: "Restaurants",
                              items: place.restaurants,
                            ),
                            SizedBox(height: 20.h),

                            // Hotels
                            HorizontalSection(
                              title: "Hotels",
                              items: place.hotels,
                            ),
                            SizedBox(height: 20.h),

                            // Rating Summary
                            Text(
                              "Rating & Reviews",
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            RatingSummaryCard(
                              averageRating: place.ratingSummary.average,
                              totalReviews: place.ratingSummary.totalReviews,
                              stats: place.ratingSummary.distribution,
                            ),
                            SizedBox(height: 20.h),

                            // Customer Feedbacks
                            Text(
                              "Customer Feedbacks",
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 10.h),

                            ...place.reviews.map((review) {
                              final canManage = _isMyReview(review);
                              return ReviewCard(
                                review: review,
                                canManage: canManage,
                                onEdit: canManage
                                    ? () =>
                                        _openEditReviewSheet(context, review)
                                    : null,
                                onDelete: canManage
                                    ? () =>
                                        _confirmDeleteReview(context, review)
                                    : null,
                              );
                            }),

                            SizedBox(height: 20.h),
                            SubmitReview(placeId: place.id),
                            SizedBox(height: 30.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

// ─── Edit Review Bottom Sheet ─────────────────────────────────────────────────

class _EditReviewSheet extends StatefulWidget {
  final String initialComment;
  final double initialRating;
  final void Function(String comment, int rating) onSubmit;

  const _EditReviewSheet({
    required this.initialComment,
    required this.initialRating,
    required this.onSubmit,
  });

  @override
  State<_EditReviewSheet> createState() => _EditReviewSheetState();
}

class _EditReviewSheetState extends State<_EditReviewSheet> {
  late final TextEditingController _commentController;
  late double _selectedRating;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController(text: widget.initialComment);
    _selectedRating = widget.initialRating;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[600] : Colors.grey[300],
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          Text(
            'Edit Review',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 16.h),

          // Stars
          Text('Your Rating',
              style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.6))),
          SizedBox(height: 8.h),
          Row(
            children: List.generate(5, (i) {
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedRating = (i + 1).toDouble()),
                child: Icon(
                  i < _selectedRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32.sp,
                ),
              );
            }),
          ),
          SizedBox(height: 16.h),

          // Comment
          TextField(
            controller: _commentController,
            maxLines: 4,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Update your review...',
              hintStyle: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
              filled: true,
              fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 16.h),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_commentController.text.trim().isNotEmpty) {
                  widget.onSubmit(
                    _commentController.text.trim(),
                    _selectedRating.toInt(),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text(
                'Update Review',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
