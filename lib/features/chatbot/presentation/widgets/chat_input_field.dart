import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSend;
  final bool isLoading;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSend,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final inputFillColor =
        isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF9F9F9);
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.white38 : Colors.grey.shade400;
    const borderColor = Color(0xFFD1B89A);

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: 5,
                minLines: 1,
                style: TextStyle(fontSize: 15.sp, color: textColor),
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(fontSize: 14.sp, color: hintColor),
                  filled: true,
                  fillColor: inputFillColor,

                  // الحواف
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.r),
                    borderSide: BorderSide(color: borderColor, width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.r),
                    borderSide: BorderSide(color: borderColor, width: 1.8),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),

                  suffixIcon: Padding(
                    padding: EdgeInsets.only(right: 4.w),
                    child: IconButton(
                      icon: Icon(
                        Icons.attach_file_outlined,
                        color: isDark ? Colors.white54 : Colors.grey.shade500,
                        size: 20.sp,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            _buildSendButton(borderColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton(Color color) {
    return Container(
      height: 48.h,
      width: 48.h,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: isLoading
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.send_rounded, color: Colors.white, size: 22),
        onPressed: isLoading
            ? null
            : () {
                if (controller.text.isNotEmpty) {
                  onSend(controller.text);
                  controller.clear();
                  HapticFeedback.lightImpact();
                }
              },
      ),
    );
  }
}
