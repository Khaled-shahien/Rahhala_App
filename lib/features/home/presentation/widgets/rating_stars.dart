import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;

  const RatingStars({super.key, required this.rating, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (rating >= index + 1) {
          return Icon(Icons.star, color: const Color(0xFFB08968), size: size);
        } else if (rating >= index + 0.1) {
          return Icon(Icons.star_half,
              color: const Color(0xFFB08968), size: size);
        } else {
          return Icon(Icons.star_border,
              color: const Color(0xFFB08968), size: size);
        }
      }),
    );
  }
}
