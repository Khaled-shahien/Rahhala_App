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
import 'package:rahhala_app/features/auth/domain/reset_password/reset_password_cubit.dart';
import 'package:rahhala_app/features/auth/domain/reset_password/reset_password_state.dart';
import 'package:rahhala_app/core/widgets/background_decorator.dart';

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

  Widget _rule({
    required bool ok,
    required String text,
    required Color textColor,
    required Color inactiveIconColor,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          Icon(ok ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 16, color: ok ? Colors.green : inactiveIconColor),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12.sp, color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (_) => sl<ResetPasswordCubit>(),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
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
                child: BackgroundDecorator(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 18.h,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 520.w),
                            child: Form(
                              key: _formKey,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(height: 12.h),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        style: IconButton.styleFrom(
                                          backgroundColor: colorScheme
                                              .surfaceContainerHighest
                                              .withValues(alpha: 0.5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        icon: Icon(
                                          Icons.arrow_back_ios_new,
                                          color: colorScheme.onSurface,
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                      const SizedBox.shrink(),
                                      const SizedBox.shrink(),
                                    ],
                                  ),
                                  SizedBox(height: 14.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 18.w,
                                      vertical: 18.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surface,
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(
                                        color: colorScheme.outline.withValues(
                                            alpha: isDark ? 0.35 : 0.2),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                              alpha: isDark ? 0.2 : 0.04),
                                          blurRadius: 22,
                                          offset: const Offset(0, 12),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        const Text(
                                          'Reset Password',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: ThemeColor.primaryColor,
                                          ),
                                        ),
                                        SizedBox(height: 10.h),
                                        Text(
                                          'Use 8+ chars with upper/lowercase, number & symbol',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        SizedBox(height: 24.h),
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
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                            onPressed: () => setState(() =>
                                                _obscurePassword =
                                                    !_obscurePassword),
                                          ),
                                          validator:
                                              AppValidators.validatePassword,
                                          textInputAction: TextInputAction.next,
                                          onChanged: (_) => setState(() {}),
                                          autofillHints: const [
                                            AutofillHints.newPassword
                                          ],
                                        ),
                                        SizedBox(height: 12.h),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: colorScheme
                                                .surfaceContainerHighest
                                                .withValues(alpha: 0.2),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: colorScheme.outline
                                                  .withValues(
                                                      alpha:
                                                          isDark ? 0.35 : 0.2),
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12.w,
                                            vertical: 10.h,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                child: LinearProgressIndicator(
                                                  value: pw.isEmpty
                                                      ? 0
                                                      : max(0.2, strength),
                                                  minHeight: 8,
                                                  backgroundColor: colorScheme
                                                      .outline
                                                      .withValues(alpha: 0.3),
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
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
                                                  text: '8 or more characters',
                                                  textColor: colorScheme
                                                      .onSurfaceVariant,
                                                  inactiveIconColor: colorScheme
                                                      .onSurfaceVariant),
                                              _rule(
                                                  ok: RegExp(r'[A-Z]')
                                                      .hasMatch(pw),
                                                  text:
                                                      'At least 1 uppercase letter',
                                                  textColor: colorScheme
                                                      .onSurfaceVariant,
                                                  inactiveIconColor: colorScheme
                                                      .onSurfaceVariant),
                                              _rule(
                                                  ok: RegExp(r'[a-z]')
                                                      .hasMatch(pw),
                                                  text:
                                                      'At least 1 lowercase letter',
                                                  textColor: colorScheme
                                                      .onSurfaceVariant,
                                                  inactiveIconColor: colorScheme
                                                      .onSurfaceVariant),
                                              _rule(
                                                  ok: RegExp(r'\d')
                                                      .hasMatch(pw),
                                                  text: 'At least 1 number',
                                                  textColor: colorScheme
                                                      .onSurfaceVariant,
                                                  inactiveIconColor: colorScheme
                                                      .onSurfaceVariant),
                                              _rule(
                                                  ok: RegExp(r'[^A-Za-z0-9]')
                                                      .hasMatch(pw),
                                                  text:
                                                      'At least 1 special character',
                                                  textColor: colorScheme
                                                      .onSurfaceVariant,
                                                  inactiveIconColor: colorScheme
                                                      .onSurfaceVariant),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 16.h),
                                        CustomFormTextField(
                                          controller:
                                              _confirmPasswordController,
                                          labelText: 'Confirm Password',
                                          hintText: 'Re-enter new password',
                                          obscureText: _obscureConfirmPassword,
                                          prefixIcon: Icons.lock_reset_outlined,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscureConfirmPassword
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                            onPressed: () => setState(() =>
                                                _obscureConfirmPassword =
                                                    !_obscureConfirmPassword),
                                          ),
                                          validator: (v) => AppValidators
                                              .validateConfirmPassword(v ?? '',
                                                  _passwordController.text),
                                          textInputAction: TextInputAction.done,
                                          autofillHints: const [
                                            AutofillHints.newPassword
                                          ],
                                        ),
                                        SizedBox(height: 22.h),
                                        CustomButton(
                                          onTap: isLoading
                                              ? null
                                              : () {
                                                  if (_formKey.currentState!
                                                      .validate()) {
                                                    context
                                                        .read<
                                                            ResetPasswordCubit>()
                                                        .resetPassword(
                                                          email: widget.email,
                                                          otp: widget.otp,
                                                          password:
                                                              _passwordController
                                                                  .text,
                                                          confirmPassword:
                                                              _confirmPasswordController
                                                                  .text,
                                                        );
                                                  } else {
                                                    HapticFeedback
                                                        .selectionClick();
                                                  }
                                                },
                                          text: isLoading
                                              ? 'Resetting...'
                                              : 'Reset Password',
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20.h),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (isLoading)
                        Container(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.5 : 0.28),
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(
                              color: ThemeColor.primaryColor),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
