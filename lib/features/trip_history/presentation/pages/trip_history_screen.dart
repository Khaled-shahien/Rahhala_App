import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/constants/app_assets.dart';
import 'package:rahhala_app/core/constants/app_colors.dart';
import 'package:rahhala_app/features/auth/presentation/pages/home_page.dart';
import 'package:rahhala_app/features/auth/presentation/pages/login_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/features/trip_history/data/models/trip_history_model.dart';
import 'package:rahhala_app/features/trip_history/domain/cubits/trip_history_cubit.dart';
import 'package:rahhala_app/features/trip_history/domain/cubits/trip_history_state.dart';
import 'package:rahhala_app/features/trip_history/presentation/pages/trip_history_detail_screen.dart';

class TripHistoryScreen extends StatelessWidget {
  const TripHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TripHistoryCubit(repository: sl())..loadTrips(),
      child: const _TripHistoryView(),
    );
  }
}

class _TripHistoryView extends StatelessWidget {
  const _TripHistoryView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF8F4F0),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: BlocBuilder<TripHistoryCubit, TripHistoryState>(
              builder: (context, state) {
                if (state is TripHistoryLoading) {
                  return _buildShimmer(isDark);
                } else if (state is TripHistoryLoaded) {
                  final trips = state.response.trips;
                  if (trips.isEmpty) return _buildEmpty(context, isDark);
                  return _buildList(context, trips);
                } else if (state is TripHistoryFailure) {
                  return _buildError(context, state.message, isDark);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16.h,
        bottom: 20.h,
        left: 20.w,
        right: 20.w,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.lightBrown,
            Color(0xFF96785A),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50.r),
          bottomRight: Radius.circular(50.r),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8.r),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20.sp),
            ),
          ),
          SizedBox(width: 14.w),
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child:
                Icon(Icons.history_rounded, color: Colors.white, size: 24.sp),
          ),
          SizedBox(width: 14.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Plan History',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              BlocBuilder<TripHistoryCubit, TripHistoryState>(
                builder: (context, state) {
                  final count = state is TripHistoryLoaded
                      ? state.response.totalTrips
                      : 0;
                  return Text(
                    '$count saved plans',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13.sp,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<TripHistoryItem> trips) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      physics: const BouncingScrollPhysics(),
      itemCount: trips.length,
      itemBuilder: (_, i) => _TripHistoryCard(
        trip: trips[i],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TripHistoryDetailScreen(tripId: trips[i].tripId),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppAssets.noplans,
              width: 180.w,
              errorBuilder: (_, __, ___) => Icon(
                Icons.map_outlined,
                size: 80.sp,
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'No Plans Yet',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF3E3431),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              "You haven't created any travel plans yet. Generate your first trip and start exploring amazing destinations.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                height: 1.6,
              ),
            ),
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) =>
                        const HomePage(isGuest: false, initialIndex: 3),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightBrown,
                padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              icon: const Icon(Icons.auto_awesome, color: Colors.white),
              label: Text(
                'Generate Your First Trip',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message, bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_dissatisfied_outlined,
                size: 60.sp,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
            SizedBox(height: 16.h),
            Text(
              'Join us! Log in to unlock more features and view your trips!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15.sp,
                  color: isDark ? Colors.white70 : Colors.grey.shade600),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightBrown,
                elevation: 8,
                shadowColor: isDark ? Colors.black : Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
              ),
              child: Text(
                'Login Now',
                style: TextStyle(color: Colors.white, fontSize: 15.sp),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer(bool isDark) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      itemCount: 4,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
        highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
        child: Container(
          margin: EdgeInsets.only(bottom: 14.h),
          height: 100.h,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }
}

class _TripHistoryCard extends StatelessWidget {
  final TripHistoryItem trip;
  final VoidCallback onTap;

  const _TripHistoryCard({required this.trip, required this.onTap});

  String _timeAgo(String createdAt) {
    try {
      final date = DateTime.parse(createdAt);
      final diff = DateTime.now().difference(date);
      if (diff.inDays >= 30) return '${(diff.inDays / 30).floor()} months ago';
      if (diff.inDays >= 7) return '${(diff.inDays / 7).floor()} weeks ago';
      if (diff.inDays > 0) return '${diff.inDays} days ago';
      return 'Today';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black45
                  : Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                bottomLeft: Radius.circular(16.r),
              ),
              child: trip.countryImage != null && trip.countryImage!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: trip.countryImage!,
                      width: 100.w,
                      height: 100.h,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 100.w,
                        height: 100.h,
                        color: isDark
                            ? Colors.grey.shade900
                            : Colors.grey.shade200,
                      ),
                      errorWidget: (_, __, ___) => _placeholderImage(isDark),
                    )
                  : _placeholderImage(isDark),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.destination,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.primaryDark,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 13.sp,
                            color: isDark ? Colors.grey.shade400 : Colors.grey),
                        SizedBox(width: 4.w),
                        Text(
                          trip.country,
                          style: TextStyle(
                              fontSize: 12.sp,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        _infoChip(
                          Icons.calendar_today_outlined,
                          '${trip.numberOfDays} days',
                          isDark
                              ? const Color(0xFF422D00)
                              : const Color(0xFFFFF3E0),
                          isDark
                              ? const Color(0xFFFFB74D)
                              : const Color(0xFFE65100),
                        ),
                        SizedBox(width: 8.w),
                        _infoChip(
                          Icons.attach_money_rounded,
                          trip.totalEstimatedCost,
                          isDark
                              ? const Color(0xFF003300)
                              : const Color(0xFFE8F5E9),
                          isDark
                              ? const Color(0xFF81C784)
                              : const Color(0xFF2E7D32),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Created ${_timeAgo(trip.createdAt)}',
                      style: TextStyle(
                          fontSize: 11.sp,
                          color: isDark
                              ? Colors.grey.shade600
                              : Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: Icon(Icons.chevron_right_rounded,
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  size: 20.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage(bool isDark) {
    return Container(
      width: 100.w,
      height: 100.h,
      color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF2E7D5),
      child: Icon(Icons.landscape_outlined,
          color: isDark ? Colors.grey.shade700 : const Color(0xFF6A4D3B),
          size: 32.sp),
    );
  }

  Widget _infoChip(
      IconData icon, String label, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.sp, color: textColor),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
