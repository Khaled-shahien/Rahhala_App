import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:rahhala_app/core/constants/app_colors.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/utils/token_storage.dart';
import 'package:rahhala_app/features/home/domain/repositories/home_repository.dart';
import 'package:rahhala_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:rahhala_app/features/home/presentation/pages/place_details_screen.dart';
import 'package:rahhala_app/features/home/presentation/widgets/place_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent * 0.85;
    if (_scrollController.offset >= threshold) {
      context.read<HomeCubit>().loadMore();
    }
  }

  void _showLoginRequiredMessage(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Please log in to manage favourites.'),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(sl<HomeRepository>())..getHomeData(),
      child: Builder(
        builder: (context) {
          _scrollController.removeListener(_onScroll);
          _scrollController.addListener(() {
            if (!_scrollController.hasClients) return;
            final threshold = _scrollController.position.maxScrollExtent * 0.85;
            if (_scrollController.offset >= threshold) {
              context.read<HomeCubit>().loadMore();
            }
          });

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => context.read<HomeCubit>().getHomeData(),
            child: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                if (state is HomeLoading) {
                  return _buildShimmer(context);
                } else if (state is HomeError) {
                  return _buildError(context, state.message);
                } else if (state is HomeSuccess) {
                  return _buildList(context, state);
                }
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, HomeSuccess state) {
    return ListView.builder(
      controller: _scrollController,
      physics:
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      itemCount: state.places.length +
          (state.isLoadingMore ? 1 : 0) +
          (!state.hasMore && state.places.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        // ─── Loading More Indicator ─────────────────────────────────
        if (state.isLoadingMore && index == state.places.length) {
          return _buildLoadMoreIndicator(context);
        }

        // ─── End of List ────────────────────────────────────────────
        if (!state.hasMore && index == state.places.length) {
          return _buildEndOfList(context);
        }

        // ─── Place Card ─────────────────────────────────────────────
        final place = state.places[index];
        return PlaceCard(
          place: place,
          isFav: place.isFavourite,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlaceDetailsScreen(placeId: place.id),
            ),
          ),
          onFavTap: () {
            if (!sl<TokenStorage>().hasToken) {
              _showLoginRequiredMessage(context);
              return;
            }
            context
                .read<HomeCubit>()
                .toggleFavourite(place.id, place.isFavourite);
          },
        );
      },
    );
  }

  Widget _buildLoadMoreIndicator(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Column(
        children: [
          // Animated dots
          _DotsLoadingIndicator(),
          SizedBox(height: 8.h),
          Text(
            'Loading more places...',
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? Colors.grey[400] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndOfList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 20.w),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border:
                        Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.explore_outlined,
                          size: 14.sp, color: AppColors.primary),
                      SizedBox(width: 4.w),
                      Text(
                        "You've seen it all!",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: ListView.builder(
        itemCount: 4,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (_, __) => Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
          height: 180.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.35),
        Center(
          child: Column(
            children: [
              Icon(Icons.wifi_off_rounded,
                  size: 60.sp, color: Colors.grey.shade400),
              SizedBox(height: 16.h),
              Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
              ),
              SizedBox(height: 24.h),
              ElevatedButton.icon(
                onPressed: () => context.read<HomeCubit>().getHomeData(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                ),
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: Text('Try Again',
                    style: TextStyle(color: Colors.white, fontSize: 14.sp)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Dots Loading Indicator ───────────────────────────────────────────────────

class _DotsLoadingIndicator extends StatefulWidget {
  @override
  State<_DotsLoadingIndicator> createState() => _DotsLoadingIndicatorState();
}

class _DotsLoadingIndicatorState extends State<_DotsLoadingIndicator>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );
    _animations = _controllers.map((c) {
      return Tween<double>(begin: 0, end: -8).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut),
      );
    }).toList();

    for (var i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (_, __) => Transform.translate(
            offset: Offset(0, _animations[i].value),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.6 + i * 0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }
}
