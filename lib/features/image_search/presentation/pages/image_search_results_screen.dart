import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/features/auth/presentation/pages/login_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';
import 'package:rahhala_app/features/image_search/domain/image_search_cubit.dart';
import 'package:rahhala_app/features/image_search/domain/image_search_state.dart';
import 'package:rahhala_app/features/image_search/presentation/pages/pinterest_camera_screen.dart';
import 'package:rahhala_app/features/image_search/presentation/widgets/place_card.dart';

class ImageSearchResultsScreen extends StatelessWidget {
  const ImageSearchResultsScreen({super.key});

  void _openCamera(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ImageSearchCubit>(),
          child: const PinterestCameraScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImageSearchCubit, ImageSearchState>(
      builder: (context, state) {
        if (state is ImageSearchLoading) {
          return _buildLoading(context);
        } else if (state is ImageSearchSuccess) {
          return _buildResults(context, state);
        } else if (state is ImageSearchFailure) {
          return _buildError(context, state.message);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoading(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        elevation: 0,
        title: Text(
          'Searching...',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: 3,
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: isDark ? Colors.grey[800]! : Colors.grey.shade300,
          highlightColor: isDark ? Colors.grey[700]! : Colors.grey.shade100,
          child: Container(
            margin: EdgeInsets.only(bottom: 16.h),
            height: 260.h,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context, ImageSearchSuccess state) {
    final places = state.result.places;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            context.read<ImageSearchCubit>().reset();
            Navigator.of(context).pop();
          },
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        title: Row(
          children: [
            Icon(Icons.location_on_outlined, color: Colors.white, size: 20.sp),
            SizedBox(width: 6.w),
            Text(
              'Matching Places',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.camera_alt_outlined,
                color: Colors.white, size: 24.sp),
            onPressed: () => _openCamera(context),
          ),
        ],
      ),
      body: places.isEmpty
          ? _buildEmpty(context)
          : ListView.builder(
              padding: EdgeInsets.all(16.w),
              physics: const BouncingScrollPhysics(),
              itemCount: places.length,
              itemBuilder: (_, i) => PlaceCard(place: places[i]),
            ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            context.read<ImageSearchCubit>().reset();
            Navigator.of(context).pop();
          },
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sentiment_dissatisfied_outlined,
                  size: 60.sp,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
              SizedBox(height: 16.h),
              Text(
                'Join us! Log in to unlock more features and search by image',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16.sp, color: colorScheme.onSurfaceVariant),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () {
                  context.read<ImageSearchCubit>().reset();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColor.primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
                ),
                child: Text('Login Now',
                    style: TextStyle(color: Colors.white, fontSize: 16.sp)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_outlined,
              size: 60.sp,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
          SizedBox(height: 16.h),
          Text(
            'No matching places found',
            style:
                TextStyle(fontSize: 16.sp, color: colorScheme.onSurfaceVariant),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => _openCamera(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColor.primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Text('Try Another Image',
                style: TextStyle(color: Colors.white, fontSize: 16.sp)),
          ),
        ],
      ),
    );
  }
}
