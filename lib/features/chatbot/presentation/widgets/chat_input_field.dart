import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';

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
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: ThemeColor.bgColor,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: ThemeColor.neutralGrayColor.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: TextStyle(
                            fontSize: 15.sp,
                            color: ThemeColor.neutralGrayColor,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 14.h,
                          ),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty && !isLoading) {
                            onSend(value);
                            HapticFeedback.lightImpact();
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.attach_file_outlined,
                        size: 22.sp,
                        color: ThemeColor.neutralGrayColor,
                      ),
                      onPressed: () {
                        // TODO: Implement attachment feature
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: isLoading
                  ? null
                  : () {
                      if (controller.text.trim().isNotEmpty) {
                        onSend(controller.text);
                        controller.clear();
                        HapticFeedback.lightImpact();
                      }
                    },
              child: Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isLoading
                        ? [Colors.grey.shade300, Colors.grey.shade400]
                        : [
                            ThemeColor.primaryColor,
                            ThemeColor.primaryColor.withOpacity(0.8)
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ThemeColor.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isLoading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 22.sp,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
