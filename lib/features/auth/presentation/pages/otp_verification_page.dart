import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';
import 'package:rahhala_app/core/utils/app_notifications.dart';
import 'package:rahhala_app/features/auth/presentation/pages/login_page.dart';
import 'package:rahhala_app/features/auth/presentation/pages/reset_password_page.dart';
import 'package:rahhala_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:rahhala_app/features/auth/logic/verify_otp/verify_otp_cubit.dart';
import 'package:rahhala_app/features/auth/logic/verify_otp/verify_otp_state.dart';
import 'package:rahhala_app/core/widgets/background_decorator.dart';

enum VerifyFlow { signUp, resetPassword }

class OtpVerificationPage extends StatefulWidget {
  final String email;
  final VerifyFlow flow;

  const OtpVerificationPage({
    super.key,
    required this.email,
    this.flow = VerifyFlow.resetPassword,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());

  @override
  void dispose() {
    for (final c in _otpControllers) {
      c.dispose();
    }
    super.dispose();
  }

  String _collectOtp() {
    final buff = StringBuffer();
    for (final c in _otpControllers) {
      if (c.text.isNotEmpty) buff.write(c.text[0]);
    }
    return buff.toString();
  }

  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 45.w, // Reduced width to prevent overflow
      child: TextFormField(
        controller: _otpControllers[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp(r'[0-9\u0660-\u0669\u06F0-\u06F9]'),
          ),
        ],
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: ThemeColor.primaryColor,
        ),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: ThemeColor.primaryColor),
          ),
        ),
        onChanged: (value) {
          if (value.length > 1) {
            final matches = RegExp(r'[0-9\u0660-\u0669\u06F0-\u06F9]')
                .allMatches(value)
                .map((m) => m.group(0)!)
                .toList();
            for (int i = 0; i < 6 && i < matches.length; i++) {
              _otpControllers[i].text = matches[i];
            }
            FocusScope.of(context).unfocus();
            return;
          }

          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VerifyOtpCubit>(),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return BlocConsumer<VerifyOtpCubit, VerifyOtpState>(
                  listener: (context, state) {
                    if (state is VerifyOtpSuccess) {
                      showAppNotification(
                        context: context,
                        title: 'Verified',
                        message: state.model.message,
                        isError: false,
                      );
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoginPage(
                            initialEmail: widget.email.trim().toLowerCase(),
                          ),
                        ),
                        (route) => false,
                      );
                    } else if (state is VerifyOtpFailure) {
                      HapticFeedback.mediumImpact();
                      showAppNotification(
                        context: context,
                        title: 'Error',
                        message: state.errorMessage,
                        isError: true,
                      );
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state is VerifyOtpLoading;

                    void onVerifyTap() {
                      final otp = _collectOtp();
                      if (otp.length != 6) {
                        HapticFeedback.mediumImpact();
                        showAppNotification(
                          context: context,
                          title: 'Error',
                          message: 'Please enter the 6-digit code.',
                          isError: true,
                        );
                        return;
                      }

                      if (widget.flow == VerifyFlow.resetPassword) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ResetPasswordPage(
                              email: widget.email.trim().toLowerCase(),
                              otp: otp,
                            ),
                          ),
                        );
                      } else {
                        context
                            .read<VerifyOtpCubit>()
                            .verifyOtp(email: widget.email, otp: otp);
                      }
                    }

                    final content = SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w, // Reduced padding
                        vertical: 16.h, // Reduced padding
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 520.w),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(height: 10.h), // Reduced height
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.grey[100],
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      icon:
                                          const Icon(Icons.arrow_back_ios_new),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    const SizedBox.shrink(),
                                    const SizedBox.shrink(),
                                  ],
                                ),
                                SizedBox(height: 12.h), // Reduced height
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w, // Reduced padding
                                    vertical: 16.h, // Reduced padding
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                        20), // Reduced radius
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 20, // Reduced blur
                                        offset: const Offset(
                                            0, 10), // Reduced offset
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const Text(
                                        'Verify Code',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize:
                                              26, // Slightly reduced font size
                                          fontWeight: FontWeight.bold,
                                          color: ThemeColor.primaryColor,
                                        ),
                                      ),
                                      SizedBox(height: 8.h), // Reduced height
                                      Text(
                                        widget.flow == VerifyFlow.signUp
                                            ? "Enter the 6-digit verification code sent to your email to activate your account."
                                            : "Enter the 6-digit verification code sent to your email to reset your password.",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize:
                                              15, // Slightly reduced font size
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(height: 22.h), // Reduced height
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w, // Reduced padding
                                          vertical: 12.h, // Reduced padding
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(
                                              14), // Reduced radius
                                          border: Border.all(
                                            color: Colors.grey[200]!,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: List.generate(6,
                                              (index) => _buildOtpField(index)),
                                        ),
                                      ),
                                      SizedBox(height: 20.h), // Reduced height
                                      CustomButton(
                                        onTap: isLoading ? null : onVerifyTap,
                                        text: widget.flow == VerifyFlow.signUp
                                            ? 'Verify Code'
                                            : 'Continue',
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 16.h), // Reduced height
                              ],
                            ),
                          ),
                        ),
                      ),
                    );

                    return BackgroundDecorator(
                      child: Stack(
                        children: [
                          content,
                          if (isLoading)
                            Container(
                              color: Colors.black45,
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator(
                                color: ThemeColor.primaryColor,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
