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

import 'package:rahhala_app/features/profile/logic/profile/profile_cubit.dart';
import 'package:rahhala_app/features/profile/logic/profile/profile_state.dart';

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

  Widget _rule({required bool ok, required String text}) {
    return Row(
      children: [
        Icon(ok ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18, color: ok ? Colors.green : Colors.grey),
        SizedBox(width: 6.w),
        Expanded(child: Text(text, style: TextStyle(fontSize: 12.sp))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pw = _new.text;
    final s = _score(pw);
    final strength = s / 5;

    return BlocProvider(
      create: (_) => sl<ProfileCubit>(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: ThemeColor.charcoalColor,
          elevation: 0,
          title: const Text('Reset Password'),
        ),
        backgroundColor: Colors.white,
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

              return GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: EdgeInsets.all(16.w),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Your new password must be different from previous used password',
                              style: TextStyle(
                                  fontSize: 12.sp, color: Colors.grey),
                            ),
                            SizedBox(height: 16.h),

                            CustomFormTextField(
                              controller: _current,
                              labelText: 'Current password',
                              hintText: 'Enter current password',
                              obscureText: !_currentVisible,
                              prefixIcon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _currentVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () => setState(
                                    () => _currentVisible = !_currentVisible),
                              ),
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Password is required'
                                  : null,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.password],
                            ),
                            SizedBox(height: 14.h),

                            CustomFormTextField(
                              controller: _new,
                              labelText: 'New password',
                              hintText: 'Enter new password',
                              obscureText: !_newVisible,
                              prefixIcon: Icons.lock_reset_outlined,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _newVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () =>
                                    setState(() => _newVisible = !_newVisible),
                              ),
                              validator: AppValidators.validatePassword,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.newPassword],
                              onChanged: (_) => setState(() {}),
                            ),
                            SizedBox(height: 8.h),

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
                            SizedBox(height: 10.h),

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
                            SizedBox(height: 14.h),

                            CustomFormTextField(
                              controller: _confirm,
                              labelText: 'Confirm new password',
                              hintText: 'Re-enter new password',
                              obscureText: !_confirmVisible,
                              prefixIcon: Icons.enhanced_encryption_outlined,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _confirmVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () => setState(
                                    () => _confirmVisible = !_confirmVisible),
                              ),
                              validator: (v) =>
                                  AppValidators.validateConfirmPassword(
                                      v ?? '', _new.text),
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.newPassword],
                            ),
                            SizedBox(height: 24.h),

                            CustomButton(
                              onTap: isLoading
                                  ? null
                                  : () {
                                      if (!_formKey.currentState!.validate()) {
                                        HapticFeedback.selectionClick();
                                        return;
                                      }
                                      context
                                          .read<ProfileCubit>()
                                          .changePassword(
                                            oldPassword: _current.text,
                                            newPassword: _new.text,
                                            confirmPassword: _confirm.text,
                                          );
                                    },
                              text:
                                  isLoading ? 'Updating...' : 'Reset password',
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
