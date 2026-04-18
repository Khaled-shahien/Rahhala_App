import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rahhala_app/core/constants/app_colors.dart';
import 'package:rahhala_app/core/constants/app_text_styles.dart';
import 'package:rahhala_app/features/nearby/data/models/nearby_place_model.dart';
import 'package:rahhala_app/features/nearby/domain/cubit/nearby_cubit.dart';
import 'package:rahhala_app/features/nearby/domain/cubit/nearby_state.dart';
import 'package:rahhala_app/features/nearby/presentation/widgets/nearby_place_card.dart';

class NearbyPlacesPage extends StatefulWidget {
  final double latitude;
  final double longitude;
  final NearbyPlacesLoaded state;

  const NearbyPlacesPage({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.state,
  });

  @override
  State<NearbyPlacesPage> createState() => _NearbyPlacesPageState();
}

class _NearbyPlacesPageState extends State<NearbyPlacesPage> {
  final MapController _mapController = MapController();
  final ScrollController _scrollController = ScrollController();
  NearbyPlaceModel? _selectedPlace;
  String? _focusedPlaceId;

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Restaurant':
        return const Color(0xFFA1887F);
      case 'Cafe':
        return const Color(0xFF8B5E3C);
      case 'Shopping':
        return const Color(0xFF1976D2);
      case 'Emergency':
        return const Color(0xFFD32F2F);
      case 'Supermarket':
        return const Color.fromARGB(255, 6, 103, 10);
      default:
        return AppColors.primary;
    }
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Restaurant':
        return Icons.restaurant;
      case 'Cafe':
        return Icons.local_cafe;
      case 'Shopping':
        return Icons.shopping_bag_outlined;
      case 'Emergency':
        return Icons.local_hospital_outlined;
      case 'Supermarket':
        return Icons.local_grocery_store_outlined;
      default:
        return Icons.place_outlined;
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onPlaceTapped(NearbyPlaceModel place, List<NearbyPlaceModel> places) {
    setState(() {
      if (_focusedPlaceId == place.id) {
        _selectedPlace = null;
        _focusedPlaceId = null;
        _mapController.move(LatLng(widget.latitude, widget.longitude), 15);
      } else {
        _selectedPlace = place;
        _focusedPlaceId = place.id;
        _mapController.move(LatLng(place.latitude, place.longitude), 17);
        final index = places.indexOf(place);
        if (index != -1) {
          _scrollController.animateTo(
            index * 135.h,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  void _clearFocus() {
    setState(() {
      _selectedPlace = null;
      _focusedPlaceId = null;
      _mapController.move(LatLng(widget.latitude, widget.longitude), 15);
    });
  }

  Future<void> _openMaps(NearbyPlaceModel place) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${place.latitude},${place.longitude}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<NearbyCubit, NearbyState>(
      builder: (context, state) {
        final loaded = state is NearbyPlacesLoaded ? state : widget.state;
        final categories = [
          'All',
          ...loaded.response.sections.entries
              .where((e) => e.value.isNotEmpty)
              .map((e) => e.key)
              .toList(),
        ];

        return Scaffold(
          backgroundColor:
              isDark ? colorScheme.surface : const Color(0xFFF8F6F3),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, isDark, colorScheme),
                _buildMap(loaded, isDark),
                SizedBox(height: 12.h),
                _buildCategoryChips(
                    context, categories, loaded.selectedCategory, isDark),
                SizedBox(height: 4.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Text(
                        '${loaded.filteredPlaces.length} places found',
                        style: AppTextStyles.cairoMedium(
                            fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
                Expanded(
                  child: loaded.filteredPlaces.isEmpty
                      ? _buildEmpty(isDark)
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: loaded.filteredPlaces.length,
                          padding: EdgeInsets.only(bottom: 100.h),
                          itemBuilder: (context, index) {
                            final place = loaded.filteredPlaces[index];
                            final isFocused = _focusedPlaceId == place.id;
                            return GestureDetector(
                              onTap: () =>
                                  _onPlaceTapped(place, loaded.filteredPlaces),
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 250),
                                opacity: _focusedPlaceId == null || isFocused
                                    ? 1.0
                                    : 0.45,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  transform: Matrix4.identity()
                                    ..scale(isFocused ? 1.02 : 1.0),
                                  transformAlignment: Alignment.center,
                                  child: NearbyPlaceCard(place: place),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
      BuildContext context, bool isDark, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            child: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: isDark ? colorScheme.surface : const Color(0xFFF8F6F3),
                //color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.07),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.explore_outlined,
                size: 25.sp,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nearby Places',
                style: AppTextStyles.cairoBold(
                  fontSize: 23,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                'Around your location',
                style: AppTextStyles.cairoRegular(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => context.read<NearbyCubit>().requestLocationAndLoad(),
            child: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color:
                    AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.15),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.refresh,
                  size: 20.sp, color: AppColors.primaryDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(NearbyPlacesLoaded loaded, bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      height: 210.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.1 : 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(widget.latitude, widget.longitude),
              initialZoom: 15,
              onTap: (_, __) => _clearFocus(),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.rahhala.app',
              ),
              MarkerLayer(
                markers: [
                  // User marker
                  Marker(
                    point: LatLng(widget.latitude, widget.longitude),
                    width: 50,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            blurRadius: 10,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child:
                          Icon(Icons.person, color: Colors.white, size: 22.sp),
                    ),
                  ),
                  // Place markers
                  ...loaded.filteredPlaces.map((place) {
                    final isFocused = _focusedPlaceId == place.id;
                    final isAnyFocused = _focusedPlaceId != null;
                    return Marker(
                      point: LatLng(place.latitude, place.longitude),
                      width: isFocused ? 52 : 44,
                      height: isFocused ? 52 : 44,
                      child: GestureDetector(
                        onTap: () =>
                            _onPlaceTapped(place, loaded.filteredPlaces),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 250),
                          opacity: !isAnyFocused || isFocused ? 1.0 : 0.3,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            decoration: BoxDecoration(
                              color: isFocused
                                  ? _categoryColor(place.primaryCategory)
                                  : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _categoryColor(place.primaryCategory),
                                width: isFocused ? 3 : 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _categoryColor(place.primaryCategory)
                                      .withValues(alpha: isFocused ? 0.6 : 0.3),
                                  blurRadius: isFocused ? 14 : 8,
                                  spreadRadius: isFocused ? 3 : 1,
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(isFocused ? 7.r : 6.r),
                            child: Icon(
                              _categoryIcon(place.primaryCategory),
                              color: isFocused
                                  ? Colors.white
                                  : _categoryColor(place.primaryCategory),
                              size: isFocused ? 22.sp : 18.sp,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          // Popup
          if (_selectedPlace != null)
            Positioned(
              bottom: 10.h,
              left: 10.w,
              right: 10.w,
              child: Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: _selectedPlace!.photoUrl != null
                          ? CachedNetworkImage(
                              imageUrl: _selectedPlace!.photoUrl!,
                              width: 50.w,
                              height: 50.h,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 50.w,
                              height: 50.h,
                              color: _categoryColor(
                                      _selectedPlace!.primaryCategory)
                                  .withValues(alpha: isDark ? 0.2 : 0.1),
                              child: Icon(
                                _categoryIcon(_selectedPlace!.primaryCategory),
                                color: _categoryColor(
                                    _selectedPlace!.primaryCategory),
                              ),
                            ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedPlace!.name,
                            style: AppTextStyles.cairoSemiBold(
                              fontSize: 13,
                              color:
                                  isDark ? Colors.white : AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _selectedPlace!.formattedDistance,
                            style: AppTextStyles.cairoRegular(
                                fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _openMaps(_selectedPlace!),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.directions,
                                color: Colors.white, size: 14.sp),
                            SizedBox(width: 4.w),
                            Text(
                              'Go',
                              style: AppTextStyles.cairoBold(
                                  fontSize: 12, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    GestureDetector(
                      onTap: _clearFocus,
                      child: Icon(
                        Icons.close,
                        size: 18.sp,
                        color: isDark ? Colors.white54 : AppColors.neutralGray,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Count badge
          Positioned(
            top: 10.h,
            right: 10.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on,
                      size: 12.sp, color: AppColors.primary),
                  SizedBox(width: 4.w),
                  Text(
                    '${loaded.response.count} nearby',
                    style: AppTextStyles.cairoMedium(
                      fontSize: 11,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context, List<String> categories,
      String selected, bool isDark) {
    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == selected;
          final color =
              cat == 'All' ? AppColors.primaryDark : _categoryColor(cat);

          return GestureDetector(
            onTap: () {
              _clearFocus();
              context.read<NearbyCubit>().filterByCategory(cat);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? color
                    : (isDark ? const Color(0xFF2C2C2C) : Colors.white),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected
                      ? color
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : AppColors.borderLight),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                cat,
                style: AppTextStyles.cairoMedium(
                  fontSize: 14,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : AppColors.textSecondary),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 60.sp,
            color: isDark ? Colors.white30 : AppColors.neutralGray,
          ),
          SizedBox(height: 12.h),
          Text(
            'No places found in this category',
            style: AppTextStyles.cairoMedium(
                fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
