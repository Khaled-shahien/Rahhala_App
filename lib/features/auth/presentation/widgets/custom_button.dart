import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String text;
  final bool isLoading; 

  const CustomButton({
    super.key,
    required this.onTap,
    required this.text,
    this.isLoading = false, 
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: ThemeColor.primaryColor,
        disabledBackgroundColor: ThemeColor.primaryColor.withOpacity(0.7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        minimumSize: Size(double.infinity, 50.h),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
          : Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    );
  }
}
