import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/constants/app_colors.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/features/home/presentation/details_cubit/place_details_cubit.dart';
import 'package:rahhala_app/features/home/presentation/details_cubit/place_details_state.dart';
import 'package:rahhala_app/features/home/presentation/details_cubit/review_cubit.dart';
import 'package:rahhala_app/features/home/presentation/widgets/RatingSummaryCharts.dart';
import '../widgets/horizontal_section.dart';
import '../widgets/review_card.dart';
import '../widgets/submit_review.dart';

class PlaceDetailsScreen extends StatelessWidget {
  final String placeId;

  const PlaceDetailsScreen({super.key, required this.placeId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              sl<PlaceDetailsCubit>()..getPlaceDetails(placeId),
        ),
        BlocProvider(
          create: (context) => sl<ReviewCubit>(),
        ),
      ],
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

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 250.h,
                    pinned: true,
                    backgroundColor: AppColors.mediumBrown,
                    leading: CircleAvatar(
                      backgroundColor: Colors.black26,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                            "Description",
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
                            title: "Restaurants",
                            items: place.restaurants,
                          ),
                          SizedBox(height: 20.h),
                          HorizontalSection(
                            title: "Hotels",
                            items: place.hotels,
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            "Rating & Reviews",
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
                            "Customer Feedbacks",
                            style: TextStyle(
                                fontSize: 22.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10.h),
                          ...place.reviews
                              .map((review) => ReviewCard(review: review))
                              .toList(),
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
    );
  }
}
