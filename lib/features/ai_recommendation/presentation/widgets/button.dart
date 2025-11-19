import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color color;
  final double height;

  const NextButton({super.key, required this.onPressed, this.text = 'Next',this.color=const Color(0xFFA88866),this.height=50});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height:height.h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
