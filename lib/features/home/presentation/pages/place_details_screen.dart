import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/features/home/presentation/widgets/RatingSummaryCharts.dart';
import '../../data/models/place_model.dart';
import '../widgets/horizontal_section.dart';
import '../widgets/rating_stars.dart';
import '../widgets/review_card.dart';
import '../widgets/submit_review.dart';

class PlaceDetailsScreen extends StatelessWidget {
  final Place place;

  const PlaceDetailsScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 100.w),
                  Expanded(
                    child: Text(
                      place.name,
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 220.h,
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                image: DecorationImage(
                  image: place.image.startsWith('http')
                      ? NetworkImage(place.image) as ImageProvider
                      : AssetImage(place.image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //description
                    Text(
                      place.description,
                      style: TextStyle(fontSize: 16.sp),
                    ),

                    SizedBox(height: 20.h),

                    // Restaurants
                    const HorizontalSection(title: "Restaurants"),

                    SizedBox(height: 20.h),

                    // hotels
                    const HorizontalSection(title: "Hotels"),

                    SizedBox(height: 20.h),

                    //tThings to do
                    const HorizontalSection(title: "Things to do"),

                    SizedBox(height: 20.h),

                    //rating section
                    Text(
                      "Rating & Reviews",
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    Text(
                      "Share your experience with us",
                      style:
                          TextStyle(color: Colors.grey[600], fontSize: 12.sp),
                    ),

                    SizedBox(height: 12.h),

                    RatingSummaryCard(
                      averageRating: 4.5,
                      totalReviews: 324,
                      stats: const {
                        5: 0.68,
                        4: 0.20,
                        3: 0.08,
                        2: 0.03,
                        1: 0.01,
                      },
                    ),

                    SizedBox(height: 20.h),

                    // feedbacks
                    Text(
                      "Customer Feedbacks",
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10.h),

                    const ReviewCard(),
                    const ReviewCard(),
                    const ReviewCard(),

                    SizedBox(height: 20.h),

                    //submit review
                    const SubmitReview(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
