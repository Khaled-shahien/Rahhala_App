import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';

import 'package:rahhala_app/core/utils/app_notifications.dart';
import 'package:rahhala_app/core/utils/app_validators.dart';
import 'package:rahhala_app/core/utils/user_session.dart';
import 'package:rahhala_app/core/utils/token_storage.dart';
import 'package:rahhala_app/features/auth/domain/login/login_cubit.dart';
import 'package:rahhala_app/features/auth/domain/login/login_state.dart';
import 'package:rahhala_app/features/auth/presentation/constants/auth_strings.dart';
import 'package:rahhala_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:rahhala_app/features/auth/presentation/pages/home_page.dart';
import 'package:rahhala_app/features/auth/presentation/pages/signup_page.dart';
import 'package:rahhala_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:rahhala_app/features/auth/presentation/widgets/custom_form_text_field.dart';
import 'package:rahhala_app/features/auth/presentation/widgets/or_divider.dart';
import 'package:rahhala_app/features/auth/presentation/widgets/social_login_section.dart';
import 'package:rahhala_app/features/profile/data/repositories/user_repository.dart';
import 'package:rahhala_app/core/widgets/background_decorator.dart';

class LoginPage extends StatefulWidget {
  final String? initialEmail;

  const LoginPage({super.key, this.initialEmail});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    final prefill = widget.initialEmail;
    if (prefill != null && prefill.isNotEmpty) {
      _emailController.text = prefill;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignUpPage()),
    );
  }

  void _navigateToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
    );
  }

  void _submit(BuildContext context, LoginState state) {
    if (state is LoginLoading) return;

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      HapticFeedback.selectionClick();
      return;
    }

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    ScaffoldMessenger.of(context).clearSnackBars();
    context.read<LoginCubit>().loginUser(email: email, password: password);
  }

  Future<void> _handleLoginSuccess(
    BuildContext listenerContext,
    LoginSuccess state,
  ) async {
    final token = state.loginModel.token;
    final displayFromLogin = state.loginModel.username;
    final email = _emailController.text.trim().toLowerCase();

    if (token != null && token.isNotEmpty) {
      await sl<TokenStorage>().setToken(token);
    }
    await sl<TokenStorage>().setEmail(email);

    if (displayFromLogin != null && displayFromLogin.trim().isNotEmpty) {
      await sl<TokenStorage>().setFullName(displayFromLogin.trim());
    }

    try {
      final userRepo = sl<UserRepo>();
      final detailsEither = await userRepo.getDetails();
      await detailsEither.fold((f) async {
        final stored = sl<TokenStorage>().fullName;
        sl<UserSession>().setFromLogin(
          email: email,
          displayName: stored ?? '',
        );
      }, (details) async {
        if (details.fullName.trim().isNotEmpty) {
          await sl<TokenStorage>().setFullName(details.fullName.trim());
        }
        if (details.email.trim().isNotEmpty) {
          await sl<TokenStorage>().setEmail(details.email.trim().toLowerCase());
        }
        sl<UserSession>().setFromLogin(
          email: details.email.isNotEmpty
              ? details.email.trim().toLowerCase()
              : email,
          displayName: details.fullName.trim().isNotEmpty
              ? details.fullName.trim()
              : (sl<TokenStorage>().fullName ?? ''),
        );
      });
    } catch (_) {
      sl<UserSession>().setFromLogin(
        email: email,
        displayName: sl<TokenStorage>().fullName ?? '',
      );
    }

    final storedName = sl<TokenStorage>().fullName;
    if (storedName == null || storedName.trim().isEmpty) {
      final local = email.split('@').first;
      final cap = local.isNotEmpty
          ? local[0].toUpperCase() + local.substring(1)
          : 'User';
      await sl<TokenStorage>().setFullName(cap);
      sl<UserSession>().setFromLogin(email: email, displayName: cap);
    }

    if (!mounted || !listenerContext.mounted) return;

    showAppNotification(
      context: listenerContext,
      title: AuthStrings.welcomeBackNotificationTitle,
      message: AuthStrings.welcomeBackNotificationMessage,
    );

    if (!mounted || !listenerContext.mounted) return;
    Navigator.pushAndRemoveUntil(
      listenerContext,
      MaterialPageRoute(builder: (_) => const HomePage(isGuest: false)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LoginCubit>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocConsumer<LoginCubit, LoginState>(
            listener: (context, state) async {
              if (state is LoginSuccess) {
                final listenerContext = context;
                await _handleLoginSuccess(listenerContext, state);
              } else if (state is LoginFailure) {
                HapticFeedback.mediumImpact();
                showAppNotification(
                  context: context,
                  title: AuthStrings.errorTitle,
                  message: state.errorMessage,
                  isError: true,
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is LoginLoading;

              return GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: BackgroundDecorator(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 20.h,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 560.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(height: 12.h),
                                // Row(
                                //   children: [
                                //     Container(
                                //       padding: EdgeInsets.symmetric(
                                //         horizontal: 12.w,
                                //         vertical: 8.h,
                                //       ),
                                //       decoration: BoxDecoration(
                                //         color: Colors.white,
                                //         borderRadius:
                                //             BorderRadius.circular(14.r),
                                //         boxShadow: [
                                //           BoxShadow(
                                //             color:
                                //                 Colors.black.withOpacity(0.05),
                                //             blurRadius: 12,
                                //             offset: const Offset(0, 6),
                                //           ),
                                //         ],
                                //         border: Border.all(
                                //           color: ThemeColor.primaryColor
                                //               .withOpacity(0.16),
                                //         ),
                                //       ),
                                //       child: Row(
                                //         children: [
                                //           Icon(
                                //             Icons.flight_takeoff_rounded,
                                //             color: ThemeColor.primaryColor,
                                //             size: 18.sp,
                                //           ),
                                //           SizedBox(width: 8.w),
                                //           Text(
                                //             'Rahhala',
                                //             style: TextStyle(
                                //               fontSize: 15.sp,
                                //               fontWeight: FontWeight.w700,
                                //               color: ThemeColor.charcoalColor,
                                //             ),
                                //           ),
                                //         ],
                                //       ),
                                //     ),
                                //     const Spacer(),
                                //     TextButton(
                                //       onPressed: _navigateToSignUp,
                                //       child: Text(
                                //         'Create Account',
                                //         style: TextStyle(
                                //           color: ThemeColor.charcoalColor,
                                //           fontWeight: FontWeight.w600,
                                //           fontSize: 14.sp,
                                //         ),
                                //       ),
                                //     ),
                                //   ],
                                // ),
                                SizedBox(height: 24.h),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                    vertical: 22.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(28.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.06),
                                        blurRadius: 22,
                                        offset: const Offset(0, 12),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: ThemeColor.primaryColor
                                          .withValues(alpha: 0.08),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      SizedBox(height: 6.h),
                                      Center(
                                        child: SvgPicture.asset(
                                          'assets/images/logo.svg',
                                          width: 140.w,
                                          height: 140.h,
                                        ),
                                      ),
                                      SizedBox(height: 10.h),
                                      Text(
                                        AuthStrings.welcomeBackTitle,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 24.sp,
                                          fontWeight: FontWeight.w800,
                                          color: ThemeColor.charcoalColor,
                                        ),
                                      ),
                                      SizedBox(height: 6.h),
                                      Text(
                                        AuthStrings.welcomeBackSubtitle,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey[600],
                                          height: 1.4,
                                        ),
                                      ),
                                      SizedBox(height: 24.h),
                                      Form(
                                        key: _formKey,
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            CustomFormTextField(
                                              labelText: AuthStrings.emailLabel,
                                              hintText: AuthStrings.emailHint,
                                              controller: _emailController,
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              prefixIcon: Icons.email_outlined,
                                              validator:
                                                  AppValidators.validateEmail,
                                              textInputAction:
                                                  TextInputAction.next,
                                              autofillHints: const [
                                                AutofillHints.email
                                              ],
                                            ),
                                            SizedBox(height: 16.h),
                                            CustomFormTextField(
                                              labelText:
                                                  AuthStrings.passwordLabel,
                                              hintText:
                                                  AuthStrings.passwordHint,
                                              controller: _passwordController,
                                              obscureText: !_isPasswordVisible,
                                              prefixIcon: Icons.lock_outline,
                                              suffixIcon: IconButton(
                                                onPressed: () => setState(
                                                  () => _isPasswordVisible =
                                                      !_isPasswordVisible,
                                                ),
                                                icon: Icon(
                                                  _isPasswordVisible
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                ),
                                                color: ThemeColor.primaryColor,
                                                tooltip: _isPasswordVisible
                                                    ? AuthStrings
                                                        .hidePasswordTooltip
                                                    : AuthStrings
                                                        .showPasswordTooltip,
                                              ),
                                              validator: AppValidators
                                                  .validateLoginPassword,
                                              textInputAction:
                                                  TextInputAction.done,
                                              onFieldSubmitted: (_) =>
                                                  _submit(context, state),
                                              autofillHints: const [
                                                AutofillHints.password
                                              ],
                                            ),
                                            SizedBox(height: 10.h),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    'Secure sign-in to continue your journey.',
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color: Colors.grey[600],
                                                      height: 1.4,
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed:
                                                      _navigateToForgotPassword,
                                                  child: const Text(
                                                    AuthStrings.forgotPassword,
                                                    style: TextStyle(
                                                      color: ThemeColor
                                                          .primaryColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 6.h),
                                            CustomButton(
                                              onTap: isLoading
                                                  ? null
                                                  : () =>
                                                      _submit(context, state),
                                              text: isLoading
                                                  ? AuthStrings.loggingIn
                                                  : AuthStrings.logIn,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 22.h),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 18.w,
                                    vertical: 20.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(
                                      color: Colors.grey[100]!,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.04),
                                        blurRadius: 18,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      const OrDivider(
                                          text: AuthStrings.orDivider),
                                      SizedBox(height: 18.h),
                                      SocialLoginSection(
                                        promptText: AuthStrings.dontHaveAccount,
                                        actionText: AuthStrings.signUp,
                                        onActionTap: _navigateToSignUp,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 12.h),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (isLoading)
                        Container(
                          color: Colors.black26,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(
                            color: ThemeColor.primaryColor,
                          ),
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
