import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/constants/app_colors.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';
import 'package:rahhala_app/features/home/data/models/home_model.dart';
import 'package:rahhala_app/features/home/presentation/cubit/favourites_cubit.dart';
import 'package:rahhala_app/features/home/presentation/pages/place_details_screen.dart';
import 'package:rahhala_app/core/localization/app_localization_extensions.dart';

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
    _favouritesCubit.getFavourites();
  }

  @override
  void dispose() {
    _favouritesCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          Widget content;

          if (state is FavouritesLoading) {
            content = const Center(child: CircularProgressIndicator());
          } else if (state is FavouritesError) {
            content = Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  SizedBox(height: 10.h),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<FavouritesCubit>().getFavourites(),
                    child: Text(context.l10n.commonTryAgain),
                  ),
                ],
              ),
            );
          } else {
            final favourites = state is FavouritesSuccess
                ? state.favourites
                : <FavouriteModel>[];

            content = RefreshIndicator(
              onRefresh: () => context.read<FavouritesCubit>().getFavourites(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                children: [
                  if (favourites.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 30.h),
                      child: Center(
                        child: Text(
                          context.l10n.favouritesEmpty,
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
          }

          return Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: ThemeColor.primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 22.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.favouritesTitle,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          context.l10n.favouritesSubtitle,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(child: content),
            ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1A1816) : Colors.white;
    final cardBorderColor =
        isDark ? AppColors.primary.withValues(alpha: 0.16) : Colors.transparent;
    final titleColor = isDark ? const Color(0xFFF4EEE6) : AppColors.charcoal;
    final subtitleColor =
        isDark ? const Color(0xFFBEB4A8) : Colors.grey.shade600;
    final imagePlaceholderColor =
        isDark ? const Color(0xFF2A2622) : Colors.grey.shade300;
    final favouriteButtonColor =
        isDark ? const Color(0xFF29231E) : Colors.white;
    final ratingBadgeColor =
        isDark ? const Color(0xFF27221D) : Colors.grey.shade100;
    final ratingTextColor =
        isDark ? const Color(0xFFE5C59B) : const Color(0xFF6F563D);
    final ratingIconColor =
        isDark ? const Color(0xFFD7B98D) : const Color(0xFF9A7B56);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.12),
              blurRadius: isDark ? 18 : 10,
              offset: Offset(0, isDark ? 8 : 3),
            ),
          ],
          border: Border.all(color: cardBorderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    width: double.infinity,
                    height: 140.h,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: double.infinity,
                      height: 140.h,
                      color: imagePlaceholderColor,
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: double.infinity,
                      height: 140.h,
                      color: imagePlaceholderColor,
                    ),
                  ),
                  if (isDark)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.03),
                              Colors.black.withValues(alpha: 0.18),
                            ],
                          ),
                        ),
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
                        decoration: BoxDecoration(
                          color: favouriteButtonColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: isDark ? 0.28 : 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
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
              padding: EdgeInsetsDirectional.fromSTEB(12.w, 10.h, 12.w, 12.h),
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
                            color: titleColor,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          context.l10n.favouritesSavedOn(
                              item.createdAt.length >= 10
                                  ? item.createdAt.substring(0, 10)
                                  : item.createdAt),
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: ratingBadgeColor,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.2 : 0.08),
                          blurRadius: isDark ? 10 : 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: isDark
                            ? AppColors.primary.withValues(alpha: 0.14)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: ratingIconColor, size: 14),
                        SizedBox(width: 4.w),
                        Text(
                          item.rating.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: ratingTextColor,
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
