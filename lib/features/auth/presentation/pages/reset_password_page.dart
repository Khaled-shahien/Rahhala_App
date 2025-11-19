import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';
import 'package:rahhala_app/core/utils/app_notifications.dart';
import 'package:rahhala_app/core/utils/app_validators.dart';
import 'package:rahhala_app/features/auth/presentation/pages/login_page.dart';
import 'package:rahhala_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:rahhala_app/features/auth/presentation/widgets/custom_form_text_field.dart';
import 'package:rahhala_app/features/auth/logic/reset_password/reset_password_cubit.dart';
import 'package:rahhala_app/features/auth/logic/reset_password/reset_password_state.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  final String otp;
  const ResetPasswordPage({super.key, required this.email, required this.otp});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  int _pwScore(String p) {
    int s = 0;
    if (p.length >= 8) s++;
    if (RegExp(r'[A-Z]').hasMatch(p)) s++;
    if (RegExp(r'[a-z]').hasMatch(p)) s++;
    if (RegExp(r'\d').hasMatch(p)) s++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) s++;
    return s;
  }

  Widget _rule({required bool ok, required String text}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          Icon(ok ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 16, color: ok ? Colors.green : Colors.grey),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ResetPasswordCubit>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
            listener: (context, state) {
              if (state is ResetPasswordSuccess) {
                showAppNotification(
                    context: context,
                    title: 'Success',
                    message: state.model.message);
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (r) => false);
              } else if (state is ResetPasswordFailure) {
                HapticFeedback.mediumImpact();
                showAppNotification(
                    context: context,
                    title: 'Error',
                    message: state.errorMessage,
                    isError: true);
              }
            },
            builder: (context, state) {
              final isLoading = state is ResetPasswordLoading;
              final pw = _passwordController.text;
              final score = _pwScore(pw);
              final strength = score / 5;

              return GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 20.h),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            SizedBox(height: 40.h),
                            const Text('Reset Password',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeColor.primaryColor)),
                            SizedBox(height: 12.h),
                            const Text(
                                'Use 8+ chars with upper/lowercase, number & symbol',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey)),
                            SizedBox(height: 28.h),

                            CustomFormTextField(
                              controller: _passwordController,
                              labelText: 'New Password',
                              hintText: 'Enter new password',
                              obscureText: _obscurePassword,
                              prefixIcon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                              validator: AppValidators.validatePassword,
                              textInputAction: TextInputAction.next,
                              onChanged: (_) => setState(() {}),
                              autofillHints: const [AutofillHints.newPassword],
                            ),
                            SizedBox(height: 12.h),

                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: pw.isEmpty ? 0 : max(0.2, strength),
                                minHeight: 8,
                                backgroundColor: Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  strength < 0.4
                                      ? Colors.redAccent
                                      : (strength < 0.8
                                          ? Colors.amber
                                          : Colors.green),
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),

                            _rule(
                                ok: pw.length >= 8,
                                text: '8 or more characters'),
                            _rule(
                                ok: RegExp(r'[A-Z]').hasMatch(pw),
                                text: 'At least 1 uppercase letter'),
                            _rule(
                                ok: RegExp(r'[a-z]').hasMatch(pw),
                                text: 'At least 1 lowercase letter'),
                            _rule(
                                ok: RegExp(r'\d').hasMatch(pw),
                                text: 'At least 1 number'),
                            _rule(
                                ok: RegExp(r'[^A-Za-z0-9]').hasMatch(pw),
                                text: 'At least 1 special character'),
                            SizedBox(height: 16.h),

                            CustomFormTextField(
                              controller: _confirmPasswordController,
                              labelText: 'Confirm Password',
                              hintText: 'Re-enter new password',
                              obscureText: _obscureConfirmPassword,
                              prefixIcon: Icons.lock_reset_outlined,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () => setState(() =>
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword),
                              ),
                              validator: (v) =>
                                  AppValidators.validateConfirmPassword(
                                      v ?? '', _passwordController.text),
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.newPassword],
                            ),
                            SizedBox(height: 32.h),

                            CustomButton(
                              onTap: isLoading
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        context
                                            .read<ResetPasswordCubit>()
                                            .resetPassword(
                                              email: widget.email,
                                              otp: widget.otp,
                                              password:
                                                  _passwordController.text,
                                              confirmPassword:
                                                  _confirmPasswordController
                                                      .text,
                                            );
                                      } else {
                                        HapticFeedback.selectionClick();
                                      }
                                    },
                              text:
                                  isLoading ? 'Resetting...' : 'Reset Password',
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isLoading)
                      Container(
                        color: Colors.black45,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(
                            color: ThemeColor.primaryColor),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
