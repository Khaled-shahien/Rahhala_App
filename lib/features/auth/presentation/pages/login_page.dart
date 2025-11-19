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
import 'package:rahhala_app/features/auth/logic/login/login_cubit.dart';
import 'package:rahhala_app/features/auth/logic/login/login_state.dart';
import 'package:rahhala_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:rahhala_app/features/auth/presentation/pages/home_page.dart';
import 'package:rahhala_app/features/auth/presentation/pages/signup_page.dart';
import 'package:rahhala_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:rahhala_app/features/auth/presentation/widgets/custom_form_text_field.dart';
import 'package:rahhala_app/features/auth/presentation/widgets/or_divider.dart';
import 'package:rahhala_app/features/auth/presentation/widgets/social_login_section.dart';
import 'package:rahhala_app/features/profile/data/repositories/user_repository.dart';

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
                final token = state.loginModel.token;
                final displayFromLogin = state.loginModel.username;
                final email = _emailController.text.trim().toLowerCase();

                if (token != null && token.isNotEmpty) {
                  await sl<TokenStorage>().setToken(token);
                }
                await sl<TokenStorage>().setEmail(email);

                if (displayFromLogin != null &&
                    displayFromLogin.trim().isNotEmpty) {
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
                      await sl<TokenStorage>()
                          .setFullName(details.fullName.trim());
                    }
                    if (details.email.trim().isNotEmpty) {
                      await sl<TokenStorage>()
                          .setEmail(details.email.trim().toLowerCase());
                    }
                    sl<UserSession>().setFromLogin(
                      email: (details.email.isNotEmpty
                          ? details.email.trim().toLowerCase()
                          : email),
                      displayName: (details.fullName.trim().isNotEmpty
                          ? details.fullName.trim()
                          : (sl<TokenStorage>().fullName ?? '')),
                    );
                  });
                } catch (_) {
                  sl<UserSession>().setFromLogin(
                    email: email,
                    displayName: sl<TokenStorage>().fullName ?? '',
                  );
                }

                var storedName = sl<TokenStorage>().fullName;
                if (storedName == null || storedName.trim().isEmpty) {
                  final local = email.split('@').first;
                  final cap = local.isNotEmpty
                      ? local[0].toUpperCase() + local.substring(1)
                      : 'User';
                  await sl<TokenStorage>().setFullName(cap);
                  sl<UserSession>()
                      .setFromLogin(email: email, displayName: cap);
                }

                showAppNotification(
                  context: context,
                  title: 'Welcome Back',
                  message: 'You have been successfully logged in.',
                );

                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const HomePage(isGuest: false)),
                  (route) => false,
                );
              } else if (state is LoginFailure) {
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
              final isLoading = state is LoginLoading;

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
                            SizedBox(height: 12.h),
                            Center(
                              child: SvgPicture.asset(
                                'assets/images/logo.svg',
                                width: 180.w,
                                height: 180.h,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 20.h),
                            const Text(
                              'Welcome Back',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: ThemeColor.primaryColor,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            const Text(
                              'Log in to your Rahhala account',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            SizedBox(height: 40.h),

                            CustomFormTextField(
                              labelText: 'Email',
                              hintText: 'Enter your email',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.email_outlined,
                              validator: AppValidators.validateEmail,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                            ),
                            SizedBox(height: 20.h),

                            CustomFormTextField(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible, 
                              prefixIcon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                  () =>
                                      _isPasswordVisible = !_isPasswordVisible,
                                ),
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                color: ThemeColor.primaryColor,
                                tooltip: _isPasswordVisible
                                    ? 'Hide password'
                                    : 'Show password',
                              ),
                              validator: AppValidators.validateLoginPassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(context, state),
                              autofillHints: const [AutofillHints.password],
                            ),

                            SizedBox(height: 12.h),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _navigateToForgotPassword,
                                child: const Text(
                                  'Forgot Password?',
                                  style:
                                      TextStyle(color: ThemeColor.primaryColor),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),

                            CustomButton(
                              onTap: isLoading
                                  ? null
                                  : () => _submit(context, state),
                              text: isLoading ? 'Logging In...' : 'Log In',
                            ),
                            SizedBox(height: 30.h),

                            const OrDivider(text: "Or"),
                            SizedBox(height: 30.h),

                            SocialLoginSection(
                              promptText: "Don't have an account?",
                              actionText: "Sign Up",
                              onActionTap: _navigateToSignUp,
                            ),
                            SizedBox(height: 30.h),
                          ],
                        ),
                      ),
                    ),

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
          ),
        ),
      ),
    );
  }
}
