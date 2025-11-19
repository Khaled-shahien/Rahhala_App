import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/core/constants/app_assets.dart';

import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';
import 'package:rahhala_app/core/utils/app_notifications.dart';
import 'package:rahhala_app/core/utils/app_validators.dart';
import 'package:rahhala_app/core/utils/user_session.dart';
import 'package:rahhala_app/core/utils/token_storage.dart';

import 'package:rahhala_app/features/auth/presentation/pages/login_page.dart';
import 'package:rahhala_app/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:rahhala_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:rahhala_app/features/auth/presentation/widgets/custom_country_dropdown.dart';
import 'package:rahhala_app/features/auth/presentation/widgets/custom_form_text_field.dart';
import 'package:rahhala_app/features/auth/presentation/widgets/or_divider.dart';
import 'package:rahhala_app/features/auth/logic/register/register_cubit.dart';
import 'package:rahhala_app/features/auth/logic/register/register_state.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _selectedCountry;

  final List<String> _countries = const [
    'Egypt',
    'Saudi Arabia',
    'United Arab Emirates',
    'Kuwait',
    'Qatar',
    'Jordan',
    'Lebanon',
    'Morocco',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  String _deriveUsername({required String fullName, required String email}) {
    String cleaned = fullName
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    if (cleaned.isNotEmpty && cleaned.length >= 3) {
      return cleaned;
    }
    final local = email.trim().toLowerCase().split('@').first;
    final localClean = local
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    return localClean.isEmpty
        ? 'user_${DateTime.now().millisecondsSinceEpoch}'
        : localClean;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RegisterCubit>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocConsumer<RegisterCubit, RegisterState>(
            listener: (context, state) async {
              if (state is RegisterSuccess) {
                final fullName = _nameController.text.trim();
                final email = _emailController.text.trim().toLowerCase();

                await sl<TokenStorage>().setFullName(fullName);
                await sl<TokenStorage>().setEmail(email);

                sl<UserSession>().setFromRegister(
                  fullName: fullName,
                  email: email,
                );

                print('✅ Saved after Register:');
                print('   - FullName: ${sl<TokenStorage>().fullName}');
                print('   - Email: ${sl<TokenStorage>().email}');

                showAppNotification(
                  context: context,
                  title: 'Success',
                  message: state.model.message,
                );

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OtpVerificationPage(
                      email: email,
                      flow: VerifyFlow.signUp,
                    ),
                  ),
                );
              } else if (state is RegisterFailure) {
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
              final isLoading = state is RegisterLoading;

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
                            Center(
                              child: SvgPicture.asset(
                                AppAssets.imagesLogo,
                                width: 120.w,
                              ),
                            ),
                            const Text(
                              'Create Account',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: ThemeColor.primaryColor,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            const Text(
                              'Fill in your information below to sign up',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            SizedBox(height: 30.h),
                            CustomFormTextField(
                              labelText: 'Full Name',
                              hintText: 'Enter your full name',
                              controller: _nameController,
                              prefixIcon: Icons.person_outline,
                              validator: AppValidators.validateName,
                              textInputAction: TextInputAction.next,
                            ),
                            SizedBox(height: 20.h),
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
                              labelText: 'Phone Number',
                              hintText: 'Enter your phone number',
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              prefixIcon: Icons.phone_outlined,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              validator: AppValidators.validatePhone,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [
                                AutofillHints.telephoneNumber
                              ],
                            ),
                            SizedBox(height: 20.h),
                            CustomFormTextField(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              controller: _passwordController,
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
                              autofillHints: const [AutofillHints.newPassword],
                            ),
                            SizedBox(height: 20.h),
                            CustomFormTextField(
                              labelText: 'Confirm Password',
                              hintText: 'Re-enter your password',
                              controller: _confirmPasswordController,
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
                                      v, _passwordController.text),
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.newPassword],
                            ),
                            SizedBox(height: 20.h),
                            CustomCountryDropdown(
                              label: 'Country',
                              hint: 'Select your country',
                              value: _selectedCountry,
                              items: _countries,
                              prefixIcon: Icons.public,
                              onChanged: (v) =>
                                  setState(() => _selectedCountry = v),
                              validator: (v) =>
                                  AppValidators.validateDropdown(v, 'country'),
                            ),
                            SizedBox(height: 30.h),
                            CustomButton(
                              onTap: isLoading
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        final fullName =
                                            _nameController.text.trim();
                                        final email = _emailController.text
                                            .trim()
                                            .toLowerCase();
                                        final username = _deriveUsername(
                                            fullName: fullName, email: email);
                                        context
                                            .read<RegisterCubit>()
                                            .registerUser(
                                              fullName: fullName,
                                              username: username,
                                              email: email,
                                              password:
                                                  _passwordController.text,
                                              confirmPassword:
                                                  _confirmPasswordController
                                                      .text,
                                              phoneNumber:
                                                  _phoneController.text,
                                              country: _selectedCountry!,
                                            );
                                      } else {
                                        HapticFeedback.selectionClick();
                                      }
                                    },
                              text:
                                  isLoading ? 'Creating...' : 'Create Account',
                            ),
                            SizedBox(height: 30.h),
                            const OrDivider(text: "Or"),
                            SizedBox(height: 30.h),
                            _buildSocialLoginSection(),
                            SizedBox(height: 20.h),
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

  Widget _buildSocialLoginSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Already have an account?',
              style: TextStyle(fontSize: 14),
            ),
            TextButton(
              onPressed: _navigateToLogin,
              child: const Text(
                'Log In',
                style: TextStyle(
                  color: ThemeColor.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
