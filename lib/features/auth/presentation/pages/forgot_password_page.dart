import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/core/constants/app_assets.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';
import 'package:rahhala_app/core/utils/app_notifications.dart';
import 'package:rahhala_app/core/utils/app_validators.dart';
import 'package:rahhala_app/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:rahhala_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:rahhala_app/features/auth/presentation/widgets/custom_form_text_field.dart';
import 'package:rahhala_app/features/auth/domain/forgot_password/forgot_password_cubit.dart';
import 'package:rahhala_app/features/auth/domain/forgot_password/forgot_password_state.dart';
import 'package:rahhala_app/core/widgets/background_decorator.dart';
import 'package:rahhala_app/core/localization/app_localization_extensions.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (_) => sl<ForgotPasswordCubit>(),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
            listener: (context, state) {
              if (state is ForgotPasswordSuccess) {
                showAppNotification(
                    context: context,
                    title: context.l10n.commonSuccess,
                    message: state.model.message);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OtpVerificationPage(
                      email: _emailController.text.trim().toLowerCase(),
                      flow: VerifyFlow.resetPassword,
                    ),
                  ),
                );
              } else if (state is ForgotPasswordFailure) {
                HapticFeedback.mediumImpact();
                showAppNotification(
                    context: context,
                    title: context.l10n.commonError,
                    message: state.errorMessage,
                    isError: true);
              }
            },
            builder: (context, state) {
              final isLoading = state is ForgotPasswordLoading;
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
                                        Center(
                                          child: SvgPicture.asset(
                                            AppAssets.imagesLogo,
                                            width: 160.w,
                                            height: 160.h,
                                          ),
                                        ),
                                        SizedBox(height: 10.h),
                                        Text(
                                          context.l10n.authForgotPasswordTitle,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: ThemeColor.primaryColor,
                                          ),
                                        ),
                                        SizedBox(height: 8.h),
                                        Text(
                                          context.l10n.authForgotPasswordDesc,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: colorScheme.onSurfaceVariant,
                                            height: 1.5,
                                          ),
                                        ),
                                        SizedBox(height: 26.h),
                                        CustomFormTextField(
                                          controller: _emailController,
                                          labelText:
                                              context.l10n.authEmailAddress,
                                          hintText: context.l10n.authEmailHint,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          prefixIcon: Icons.email_outlined,
                                          validator:
                                              AppValidators.validateEmail,
                                          textInputAction: TextInputAction.done,
                                          autofillHints: const [
                                            AutofillHints.email
                                          ],
                                          onFieldSubmitted: (_) {
                                            if (_formKey.currentState!
                                                    .validate() &&
                                                !isLoading) {
                                              context
                                                  .read<ForgotPasswordCubit>()
                                                  .forgotPassword(
                                                      email: _emailController
                                                          .text);
                                            }
                                          },
                                          onChanged: (_) {},
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
                                                            ForgotPasswordCubit>()
                                                        .forgotPassword(
                                                            email:
                                                                _emailController
                                                                    .text);
                                                  } else {
                                                    HapticFeedback
                                                        .selectionClick();
                                                  }
                                                },
                                          text: isLoading
                                              ? context.l10n.authSendingCode
                                              : context.l10n.authSendCode,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 26.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14.w,
                                      vertical: 18.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surface,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: colorScheme.outline.withValues(
                                            alpha: isDark ? 0.35 : 0.2),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                              alpha: isDark ? 0.16 : 0.03),
                                          blurRadius: 18,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          context.l10n.authRememberedPassword,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        SizedBox(height: 10.h),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text(
                                            context.l10n.authBackToLogin,
                                            style: const TextStyle(
                                              color: ThemeColor.primaryColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
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
