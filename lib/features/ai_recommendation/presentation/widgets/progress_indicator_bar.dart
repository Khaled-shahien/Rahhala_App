import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// تأكدي من المسار ده للألوان الثابتة

class ProgressIndicatorBar extends StatelessWidget {
  final int currentStep;

  const ProgressIndicatorBar({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    // تحديد هل إحنا في الدارك مود ولا لا
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // الألوان بناءً على المود
    const activeColor = Color(0xFFA88866); // اللون البني بتاعنا
    final inactiveCircleBg = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final inactiveLineColor = isDark ? Colors.white10 : Colors.grey.shade300;
    final inactiveTextColor = isDark ? Colors.white54 : const Color(0xFFA88866);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        bool isCompletedOrCurrent = index <= currentStep;
        bool isLineCompleted = index < currentStep;

        return Row(
          children: [
            // الدائرة (الرقم)
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompletedOrCurrent ? activeColor : inactiveCircleBg,
                border: Border.all(
                  color: activeColor,
                  width: 2.w,
                ),
                boxShadow: isDark && isCompletedOrCurrent
                    ? [
                        BoxShadow(
                            color: activeColor.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color:
                        isCompletedOrCurrent ? Colors.white : inactiveTextColor,
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
                color: isLineCompleted ? activeColor : inactiveLineColor,
              ),
            ],
          ],
        );
      }),
    );
  }
}
