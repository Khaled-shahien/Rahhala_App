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

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
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
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Review'),
          content: const Text('Are you sure you want to delete this review?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
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
    final hasToken = sl<TokenStorage>().hasToken;

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
      child: BlocListener<ReviewCubit, ReviewState>(
        listener: (context, state) {
          if (state is ReviewSuccess) {
            context.read<PlaceDetailsCubit>().getPlaceDetails(widget.placeId);
            if (state.action != ReviewAction.add) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else if (state is ReviewError && state.action != ReviewAction.add) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.grey[100],
          body: BlocBuilder<PlaceDetailsCubit, PlaceDetailsState>(
            builder: (context, state) {
              if (state is PlaceDetailsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is PlaceDetailsError) {
                return Center(child: Text(state.message));
              } else if (state is PlaceDetailsSuccess) {
                final place = state.placeDetails;
                final reviewState = context.watch<ReviewCubit>().state;
                final isDeleteLoading = reviewState is ReviewActionLoading &&
                    reviewState.action == ReviewAction.delete;

                return CustomScrollView(
                  slivers: [
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
                            fontSize: 30.sp,
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
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(12.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10.h),
                            Text(
                              'Description',
                              style: TextStyle(
                                  fontSize: 20.sp, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              place.description,
                              style: TextStyle(fontSize: 16.sp, height: 1.5),
                            ),
                            SizedBox(height: 20.h),
                            HorizontalSection(
                              title: 'Restaurants',
                              items: place.restaurants,
                            ),
                            SizedBox(height: 20.h),
                            HorizontalSection(
                              title: 'Hotels',
                              items: place.hotels,
                            ),
                            SizedBox(height: 20.h),
                            Text(
                              'Rating & Reviews',
                              style: TextStyle(
                                  fontSize: 22.sp, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 12.h),
                            RatingSummaryCard(
                              averageRating: place.ratingSummary.average,
                              totalReviews: place.ratingSummary.totalReviews,
                              stats: place.ratingSummary.distribution,
                            ),
                            SizedBox(height: 20.h),
                            Text(
                              'Customer Feedbacks',
                              style: TextStyle(
                                  fontSize: 22.sp, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10.h),
                            ...place.reviews.map((review) {
                              final canManage = hasToken &&
                                  review.id.isNotEmpty &&
                                  _isMyReview(review);

                              return ReviewCard(
                                review: review,
                                canManage: canManage,
                                isDeleting: canManage && isDeleteLoading,
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
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}

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
  late int _selectedRating;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController(text: widget.initialComment);
    _selectedRating = widget.initialRating.round().clamp(1, 5);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          top: 16.h,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update your review',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            Row(
              children: List.generate(5, (index) {
                final star = index + 1;
                return IconButton(
                  onPressed: () => setState(() => _selectedRating = star),
                  icon: Icon(
                    star <= _selectedRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                );
              }),
            ),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Update your comment...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mediumBrown,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  final text = _commentController.text.trim();
                  if (text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please enter your comment!')),
                    );
                    return;
                  }
                  widget.onSubmit(text, _selectedRating);
                },
                child: const Text('Update Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
