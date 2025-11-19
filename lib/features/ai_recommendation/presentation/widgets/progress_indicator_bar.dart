import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProgressIndicatorBar extends StatelessWidget {
  final int currentStep;

  const ProgressIndicatorBar({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Row(
          children: [
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index <= currentStep
                    ? const Color(0xFFA88866)
                    : Colors.white,
                border: Border.all(
                  color: const Color(0xFFA88866),
                  width: 2.w,
                ),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: index <= currentStep
                        ? Colors.white
                        : const Color(0xFFA88866),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (index < 3) ...[
              Container(
                width: 40.w,
                height: 2.h,
                color: index < currentStep
                    ? const Color(0xFFA88866)
                    : Colors.grey.shade300,
              ),
            ],
          ],
        );
      }),
    );
  }
}
