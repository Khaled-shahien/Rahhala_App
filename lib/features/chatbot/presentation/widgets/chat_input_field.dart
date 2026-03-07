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
    return Container(
      padding: EdgeInsets.fromLTRB(
          16.w, 8.h, 16.w, 24.h), // مساحة أسفل SafeArea لراحة الإبهام
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
                style: TextStyle(fontSize: 15.sp, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle:
                      TextStyle(fontSize: 14.sp, color: Colors.grey.shade400),
                  filled: true,
                  fillColor:
                      const Color(0xFFF9F9F9), // خلفية خفيفة جداً لتمييز الحقل

                  // الحواف هنا هي السر في الشكل النظيف
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.r),
                    borderSide:
                        const BorderSide(color: Color(0xFFD1B89A), width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.r),
                    borderSide: const BorderSide(
                        color: Color(0xFFD1B89A), width: 1.8), // تبرز عند الضغط
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),

                  // أيقونة المرفقات بداخل الحافة تماماً
                  suffixIcon: Padding(
                    padding: EdgeInsets.only(right: 4.w),
                    child: IconButton(
                      icon: Icon(Icons.attach_file_outlined,
                          color: Colors.grey.shade500, size: 20.sp),
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return Container(
      height: 48.h,
      width: 48.h,
      decoration: const BoxDecoration(
        color: Color(0xFFD1B89A),
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
