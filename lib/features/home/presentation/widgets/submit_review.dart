import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/constants/app_colors.dart';
import 'package:rahhala_app/features/home/presentation/details_cubit/place_details_cubit.dart';
import 'package:rahhala_app/features/home/presentation/details_cubit/review_cubit.dart';

class SubmitReview extends StatefulWidget {
  final String placeId;

  const SubmitReview({super.key, required this.placeId});

  @override
  State<SubmitReview> createState() => _SubmitReviewState();
}

class _SubmitReviewState extends State<SubmitReview> {
  int selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReviewCubit, ReviewState>(
      listener: (context, state) {
        if (state is ReviewSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("your review has been submitted successfully!"),
                backgroundColor: Colors.green),
          );
          setState(() {
            selectedRating = 0;
            _commentController.clear();
          });
          context.read<PlaceDetailsCubit>().getPlaceDetails(widget.placeId);
        } else if (state is ReviewError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Submit your review",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.sp),
          ),
          SizedBox(height: 10.h),
          Text(
            "Your Rate",
            style: TextStyle(fontSize: 16.sp, color: Colors.grey),
          ),
          SizedBox(height: 6.h),
          Row(
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (selectedRating == index + 1) {
                      selectedRating = 0;
                    } else {
                      selectedRating = index + 1;
                    }
                  });
                },
                child: Icon(
                  index < selectedRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32.w,
                ),
              );
            }),
          ),
          SizedBox(height: 12.h),

          // حقل التعليق
          TextField(
            controller: _commentController,
            maxLines: 3,
            style: TextStyle(fontSize: 20.sp),
            decoration: InputDecoration(
              hintText: "Your review...",
              hintStyle: TextStyle(fontSize: 14.sp),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.blue, width: 1.w),
              ),
            ),
          ),
          SizedBox(height: 12.h),

          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: BlocBuilder<ReviewCubit, ReviewState>(
              builder: (context, state) {
                if (state is ReviewLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mediumBrown,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  onPressed: () {
                    if (selectedRating == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                "please select a rating before submitting your review!")),
                      );
                      return;
                    }
                    if (_commentController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("please enter your comment!")),
                      );
                      return;
                    }

                    context.read<ReviewCubit>().submitReview(
                          widget.placeId,
                          _commentController.text,
                          selectedRating,
                        );
                  },
                  child: Text(
                    "Submit",
                    style:
                        TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
