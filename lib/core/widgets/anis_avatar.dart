import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/constants/app_assets.dart';

class AnisAvatar extends StatelessWidget {
  const AnisAvatar({
    super.key,
    required this.size,
    this.scale = 1.38,
  });

  final double size;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final dimension = size.r;
    // The source PNG is large (≈1.6 MB). Decode it at display size instead
    // of full resolution to save memory and decode time.
    final cacheSize =
        (dimension * scale * MediaQuery.devicePixelRatioOf(context)).round();
    return SizedBox.square(
      dimension: dimension,
      child: ClipOval(
        child: Transform.scale(
          scale: scale,
          child: Image.asset(
            AppAssets.anis,
            fit: BoxFit.cover,
            cacheWidth: cacheSize,
            excludeFromSemantics: true,
          ),
        ),
      ),
    );
  }
}
