import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/features/home/data/models/home_model.dart';

class PlaceCard extends StatelessWidget {
  final PlaceModel place;
  final bool isFav;
  final VoidCallback onTap;
  final VoidCallback onFavTap;

  const PlaceCard({
    super.key,
    required this.place,
    required this.isFav,
    required this.onTap,
    required this.onFavTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(12.w),
        height: 180.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          image: DecorationImage(
            image: NetworkImage(place.imageUrl),
            // image: NetworkImage(place.image),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 16,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(place.name,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold)),
                  Text(place.country,
                      style: TextStyle(color: Colors.white, fontSize: 18.sp)),
                ],
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: onFavTap,
                child: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
