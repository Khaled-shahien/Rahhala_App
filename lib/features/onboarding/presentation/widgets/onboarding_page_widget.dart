

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rahhala_app/features/onboarding/data/models/onboarding_model.dart';

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingModel page;

  const OnboardingPageWidget({
    super.key,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            children: [
              SizedBox(height: 30.h), 

              _buildImagesLayout(),

              SizedBox(height: 24.h), 

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  page.title,
                  style: TextStyle(
                    fontSize: 32.sp, 
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    height: 1.1,
                  ),
                ),
              ),

              SizedBox(height: 3.h), 

              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w, 
                    vertical: 5.h, 
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC19A6B),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(25.r),
                      bottomRight: Radius.circular(25.r),
                    ),
                  ),
                  child: Text(
                    page.subtitle,
                    style: TextStyle(
                      fontSize: 32.sp, 
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.h), 

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  page.description,
                  style: TextStyle(
                    fontSize: 14.sp, 
                    color: Colors.black,
                    height: 1.3, 
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              const Spacer(), 
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagesLayout() {
    return SizedBox(
      height: 250.h, 
      child: Stack(
        children: [
          
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Row(
              children: [
                Expanded(
                  child: _buildImageWithShadow(
                    page.images[0],
                    height: 145.h, 
                  ),
                ),
                SizedBox(width: 14.w), 
                Expanded(
                  child: _buildImageWithShadow(
                    page.images[1],
                    height: 145.h, 
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 100.h, 
            left: 30.w,
            right: 30.w,
            child: _buildImageWithShadow(
              page.images[2],
              height: 150.h, 
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWithShadow(String imagePath, {required double height}) {
    final isSvg = imagePath.toLowerCase().endsWith('.svg');

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 18, 
            offset: const Offset(0, 8), 
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.r), 
        child: isSvg ? _buildSvgImage(imagePath) : _buildRasterImage(imagePath),
      ),
    );
  }

  Widget _buildSvgImage(String imagePath) {
    return SvgPicture.asset(
      imagePath,
      fit: BoxFit.cover,
      placeholderBuilder: (context) => _buildPlaceholder(),
    );
  }

  Widget _buildRasterImage(String imagePath) {
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFC19A6B).withOpacity(0.6),
            const Color(0xFF8B7355).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 30.sp, 
          color: Colors.white.withOpacity(0.7),
        ),
      ),
    );
  }
}
