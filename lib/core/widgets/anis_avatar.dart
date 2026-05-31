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
    return SizedBox.square(
      dimension: size.r,
      child: ClipOval(
        child: Transform.scale(
          scale: scale,
          child: Image.asset(
            AppAssets.anis,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
