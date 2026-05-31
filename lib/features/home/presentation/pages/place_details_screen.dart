import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/auth/auth_session_service.dart';
import 'package:rahhala_app/core/constants/app_colors.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/localization/app_localization_extensions.dart';
import 'package:rahhala_app/features/home/data/models/home_model.dart';
import 'package:rahhala_app/features/home/presentation/details_cubit/place_details_cubit.dart';
import 'package:rahhala_app/features/home/presentation/details_cubit/place_details_state.dart';
import 'package:rahhala_app/features/home/presentation/details_cubit/review_cubit.dart';
import 'package:rahhala_app/features/home/presentation/widgets/rating_summary_charts.dart';
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
    final l10n = context.l10n;

    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text(
            l10n.reviewDeleteTitle,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold),
          ),
          content: Text(
            l10n.reviewDeleteMessage,
            style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
                fontSize: 14.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.commonCancel,
                  style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.commonDelete,
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
    final session = sl<AuthSessionService>();
    // TODO: Prefer a stable backend user id when review payloads expose one.
    // The current API only gives reviewer display data, so ownership falls
    // back to normalized profile identifiers stored in the auth session.
    final currentValues = <String>{
      if ((session.email ?? '').trim().isNotEmpty)
        session.email!.trim().toLowerCase(),
      if ((session.username ?? '').trim().isNotEmpty)
        session.username!.trim().toLowerCase(),
      if ((session.fullName ?? '').trim().isNotEmpty)
        session.fullName!.trim().toLowerCase(),
      session.displayName.trim().toLowerCase(),
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
              return const Center(
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
                      backgroundColor: AppColors.primary,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
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
                            CachedNetworkImage(
                              imageUrl: place.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: const Color(0xFFF2E7D5),
                              ),
                              errorWidget: (_, __, ___) => Container(
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
                                    .withValues(alpha: 0.8),
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
                            HorizontalSection(
                              title: "Activities",
                              items: place.activities,
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
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: 20.w,
        end: 20.w,
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
            l10n.reviewEditTitle,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 16.h),

          // Stars
          Text(l10n.reviewYourRating,
              style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6))),
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
              hintText: l10n.reviewUpdateHint,
              hintStyle: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4)),
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
                l10n.reviewUpdate,
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
