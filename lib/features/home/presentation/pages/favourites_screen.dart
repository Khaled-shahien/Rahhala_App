import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/constants/app_colors.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/utils/token_storage.dart';
import 'package:rahhala_app/features/home/data/models/home_model.dart';
import 'package:rahhala_app/features/home/presentation/cubit/favourites_cubit.dart';
import 'package:rahhala_app/features/home/presentation/pages/place_details_screen.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  late final FavouritesCubit _favouritesCubit;

  @override
  void initState() {
    super.initState();
    _favouritesCubit = sl<FavouritesCubit>();
    if (sl<TokenStorage>().hasToken) {
      _favouritesCubit.getFavourites();
    }
  }

  @override
  void dispose() {
    _favouritesCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasToken = sl<TokenStorage>().hasToken;

    if (!hasToken) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(
            'Please log in to view and manage your favourites.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade700),
          ),
        ),
      );
    }

    return BlocProvider.value(
      value: _favouritesCubit,
      child: BlocConsumer<FavouritesCubit, FavouritesState>(
        listener: (context, state) {
          if (state is FavouritesSuccess && state.message != null) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message!)),
            );
          }
        },
        builder: (context, state) {
          if (state is FavouritesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FavouritesError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  SizedBox(height: 10.h),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<FavouritesCubit>().getFavourites(),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          final favourites = state is FavouritesSuccess
              ? state.favourites
              : <FavouriteModel>[];

          return RefreshIndicator(
            onRefresh: () => context.read<FavouritesCubit>().getFavourites(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.r),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFA38261),
                        Color(0xFF8E6E4E),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Your Favorites',
                        style: TextStyle(
                          fontSize: 34.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'All your saved journeys in one place',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                if (favourites.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 30.h),
                    child: Center(
                      child: Text(
                        'No favourites yet.',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  )
                else
                  ...favourites.map(
                    (item) => _FavouritePlaceCard(
                      item: item,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PlaceDetailsScreen(placeId: item.id),
                          ),
                        );
                      },
                      onRemove: () {
                        context
                            .read<FavouritesCubit>()
                            .removeFavourite(item.id);
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FavouritePlaceCard extends StatelessWidget {
  final FavouriteModel item;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavouritePlaceCard({
    required this.item,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
              child: Stack(
                children: [
                  Image.network(
                    item.imageUrl,
                    width: double.infinity,
                    height: 140.h,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: double.infinity,
                      height: 140.h,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  Positioned(
                    top: 10.h,
                    right: 10.w,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        width: 34.w,
                        height: 34.w,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.name}, ${item.country}',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.charcoal,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Saved on ${item.createdAt.length >= 10 ? item.createdAt.substring(0, 10) : item.createdAt}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star,
                            color: Color(0xFF9A7B56), size: 14),
                        SizedBox(width: 4.w),
                        Text(
                          '4.7',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF6F563D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
