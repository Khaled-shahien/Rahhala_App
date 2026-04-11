import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/core/di/service_locator.dart';

import 'package:rahhala_app/core/theme/app_theme.dart';
import 'package:rahhala_app/core/utils/app_notifications.dart';
import 'package:rahhala_app/core/utils/app_validators.dart';

import 'package:rahhala_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:rahhala_app/features/auth/presentation/widgets/custom_form_text_field.dart';

import 'package:rahhala_app/features/profile/domain/profile/profile_cubit.dart';
import 'package:rahhala_app/features/profile/domain/profile/profile_state.dart';
import 'package:rahhala_app/core/widgets/background_decorator.dart';

class ResetPasswordLoggedInPage extends StatefulWidget {
  const ResetPasswordLoggedInPage({super.key});

  @override
  State<ResetPasswordLoggedInPage> createState() =>
      _ResetPasswordLoggedInPageState();
}

class _ResetPasswordLoggedInPageState extends State<ResetPasswordLoggedInPage> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();

  bool _currentVisible = false;
  bool _newVisible = false;
  bool _confirmVisible = false;

  int _score(String p) {
    int s = 0;
    if (p.length >= 8) s++;
    if (RegExp(r'[A-Z]').hasMatch(p)) s++;
    if (RegExp(r'[a-z]').hasMatch(p)) s++;
    if (RegExp(r'\d').hasMatch(p)) s++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) s++;
    return s;
  }

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Widget _rule({
    required bool ok,
    required String text,
    required Color textColor,
    required Color inactiveIconColor,
  }) {
    return Row(
      children: [
        Icon(ok ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18, color: ok ? Colors.green : inactiveIconColor),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12.sp, color: textColor),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryCol = ThemeColor.primaryColor;
    final pw = _new.text;
    final s = _score(pw);
    final strength = s / 5;

    return BlocProvider(
      create: (_) => sl<ProfileCubit>(),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: BlocConsumer<ProfileCubit, ProfileState>(
            listener: (context, state) {
              if (state is ProfileActionSuccess) {
                showAppNotification(
                    context: context,
                    title: 'Success',
                    message: state.model.message);
                Navigator.pop(context);
              } else if (state is ProfileFailure) {
                HapticFeedback.mediumImpact();
                showAppNotification(
                    context: context,
                    title: 'Error',
                    message: state.message,
                    isError: true);
              }
            },
            builder: (context, state) {
              final isLoading = state is ProfileActionLoading;

              return Column(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      color: primaryCol,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.3 : 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 22.sp,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reset Password',
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Update your account password',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.white.withValues(alpha: 0.85),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        SizedBox(height: 12.h),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 18.w,
                                            vertical: 18.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: colorScheme.surface,
                                            borderRadius:
                                                BorderRadius.circular(22),
                                            border: Border.all(
                                              color: colorScheme.outline
                                                  .withValues(
                                                      alpha:
                                                          isDark ? 0.35 : 0.2),
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
                                              Text(
                                                'Your new password must be different from previous used password',
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: colorScheme
                                                      .onSurfaceVariant,
                                                  height: 1.4,
                                                ),
                                              ),
                                              SizedBox(height: 16.h),
                                              CustomFormTextField(
                                                controller: _current,
                                                labelText: 'Current password',
                                                hintText:
                                                    'Enter current password',
                                                obscureText: !_currentVisible,
                                                prefixIcon: Icons.lock_outline,
                                                suffixIcon: IconButton(
                                                  icon: Icon(
                                                    _currentVisible
                                                        ? Icons.visibility
                                                        : Icons.visibility_off,
                                                    color: colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                                  onPressed: () => setState(
                                                      () => _currentVisible =
                                                          !_currentVisible),
                                                ),
                                                validator: (v) =>
                                                    (v == null || v.isEmpty)
                                                        ? 'Password is required'
                                                        : null,
                                                textInputAction:
                                                    TextInputAction.next,
                                                autofillHints: const [
                                                  AutofillHints.password
                                                ],
                                              ),
                                              SizedBox(height: 14.h),
                                              CustomFormTextField(
                                                controller: _new,
                                                labelText: 'New password',
                                                hintText: 'Enter new password',
                                                obscureText: !_newVisible,
                                                prefixIcon:
                                                    Icons.lock_reset_outlined,
                                                suffixIcon: IconButton(
                                                  icon: Icon(
                                                    _newVisible
                                                        ? Icons.visibility
                                                        : Icons.visibility_off,
                                                    color: colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                                  onPressed: () => setState(
                                                      () => _newVisible =
                                                          !_newVisible),
                                                ),
                                                validator: AppValidators
                                                    .validatePassword,
                                                textInputAction:
                                                    TextInputAction.next,
                                                autofillHints: const [
                                                  AutofillHints.newPassword
                                                ],
                                                onChanged: (_) =>
                                                    setState(() {}),
                                              ),
                                              SizedBox(height: 10.h),
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
                                                            alpha: isDark
                                                                ? 0.35
                                                                : 0.2),
                                                  ),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 12.w,
                                                  vertical: 10.h,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      child:
                                                          LinearProgressIndicator(
                                                        value: pw.isEmpty
                                                            ? 0
                                                            : max(
                                                                0.2, strength),
                                                        minHeight: 8,
                                                        backgroundColor:
                                                            colorScheme
                                                                .outline
                                                                .withValues(
                                                                    alpha: 0.3),
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                Color>(
                                                          strength < 0.4
                                                              ? Colors.redAccent
                                                              : (strength < 0.8
                                                                  ? Colors.amber
                                                                  : Colors
                                                                      .green),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 10.h),
                                                    _rule(
                                                        ok: pw.length >= 8,
                                                        text:
                                                            '8 or more characters',
                                                        textColor: colorScheme
                                                            .onSurfaceVariant,
                                                        inactiveIconColor:
                                                            colorScheme
                                                                .onSurfaceVariant),
                                                    _rule(
                                                        ok: RegExp(r'[A-Z]')
                                                            .hasMatch(pw),
                                                        text:
                                                            'At least 1 uppercase letter',
                                                        textColor: colorScheme
                                                            .onSurfaceVariant,
                                                        inactiveIconColor:
                                                            colorScheme
                                                                .onSurfaceVariant),
                                                    _rule(
                                                        ok: RegExp(r'[a-z]')
                                                            .hasMatch(pw),
                                                        text:
                                                            'At least 1 lowercase letter',
                                                        textColor: colorScheme
                                                            .onSurfaceVariant,
                                                        inactiveIconColor:
                                                            colorScheme
                                                                .onSurfaceVariant),
                                                    _rule(
                                                        ok: RegExp(r'\d')
                                                            .hasMatch(pw),
                                                        text:
                                                            'At least 1 number',
                                                        textColor: colorScheme
                                                            .onSurfaceVariant,
                                                        inactiveIconColor:
                                                            colorScheme
                                                                .onSurfaceVariant),
                                                    _rule(
                                                        ok: RegExp(
                                                                r'[^A-Za-z0-9]')
                                                            .hasMatch(pw),
                                                        text:
                                                            'At least 1 special character',
                                                        textColor: colorScheme
                                                            .onSurfaceVariant,
                                                        inactiveIconColor:
                                                            colorScheme
                                                                .onSurfaceVariant),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 14.h),
                                              CustomFormTextField(
                                                controller: _confirm,
                                                labelText:
                                                    'Confirm new password',
                                                hintText:
                                                    'Re-enter new password',
                                                obscureText: !_confirmVisible,
                                                prefixIcon: Icons
                                                    .enhanced_encryption_outlined,
                                                suffixIcon: IconButton(
                                                  icon: Icon(
                                                    _confirmVisible
                                                        ? Icons.visibility
                                                        : Icons.visibility_off,
                                                    color: colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                                  onPressed: () => setState(
                                                      () => _confirmVisible =
                                                          !_confirmVisible),
                                                ),
                                                validator: (v) => AppValidators
                                                    .validateConfirmPassword(
                                                        v ?? '', _new.text),
                                                textInputAction:
                                                    TextInputAction.done,
                                                autofillHints: const [
                                                  AutofillHints.newPassword
                                                ],
                                              ),
                                              SizedBox(height: 20.h),
                                              CustomButton(
                                                onTap: isLoading
                                                    ? null
                                                    : () {
                                                        if (!_formKey
                                                            .currentState!
                                                            .validate()) {
                                                          HapticFeedback
                                                              .selectionClick();
                                                          return;
                                                        }
                                                        context
                                                            .read<
                                                                ProfileCubit>()
                                                            .changePassword(
                                                              oldPassword:
                                                                  _current.text,
                                                              newPassword:
                                                                  _new.text,
                                                              confirmPassword:
                                                                  _confirm.text,
                                                            );
                                                      },
                                                text: isLoading
                                                    ? 'Updating...'
                                                    : 'Reset password',
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
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
