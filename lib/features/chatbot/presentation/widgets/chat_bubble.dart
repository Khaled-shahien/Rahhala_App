import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final DateTime? timestamp;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final botBubbleColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final botTextColor =
        isDark ? Colors.white.withValues(alpha: 0.9) : ThemeColor.charcoalColor;
    const userBubbleColor = ThemeColor.primaryColor;
    final iconBgColor = ThemeColor.primaryColor.withValues(alpha: isDark ? 0.2 : 0.1);

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(
                Icons.smart_toy_outlined,
                size: 20.sp,
                color: ThemeColor.primaryColor,
              ),
            ),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: 0.7.sw),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? userBubbleColor : botBubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: isUser ? Colors.white : botTextColor,
                      height: 1.4,
                    ),
                  ),
                ),
                if (timestamp != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    DateFormat('h:mm a').format(timestamp!),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color:
                          isDark ? Colors.white38 : ThemeColor.neutralGrayColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isUser) ...[
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(
                Icons.person_outline,
                size: 20.sp,
                color: ThemeColor.primaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
