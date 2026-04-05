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
import 'package:rahhala_app/features/auth/presentation/constants/auth_strings.dart';
import 'package:rahhala_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:rahhala_app/features/auth/presentation/widgets/custom_form_text_field.dart';
import 'package:rahhala_app/features/auth/presentation/widgets/or_divider.dart';
import 'package:rahhala_app/features/auth/domain/register/register_cubit.dart';
import 'package:rahhala_app/features/auth/domain/register/register_state.dart';
import 'package:country_picker/country_picker.dart';
import 'package:rahhala_app/core/widgets/background_decorator.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final TextEditingController _countryController; // 1. ? ŝ^" ""^"

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _countryController = TextEditingController(); // 2. Sݝ ŝ^" "^"
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _countryController.dispose(); // 3. "" . ŝ "^
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  Future<void> _handleRegisterSuccess(
    BuildContext listenerContext,
    RegisterSuccess state,
  ) async {
    final fullName = _nameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();

    await sl<TokenStorage>().setFullName(fullName);
    await sl<TokenStorage>().setEmail(email);

    sl<UserSession>().setFromRegister(
      fullName: fullName,
      email: email,
    );

    if (!mounted || !listenerContext.mounted) return;

    showAppNotification(
      context: listenerContext,
      title: AuthStrings.successTitle,
      message: state.model.message,
    );

    if (!mounted || !listenerContext.mounted) return;
    Navigator.pushReplacement(
      listenerContext,
      MaterialPageRoute(
        builder: (_) => OtpVerificationPage(
          email: email,
          flow: VerifyFlow.signUp,
        ),
      ),
    );
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
                final listenerContext = context;
                await _handleRegisterSuccess(listenerContext, state);
              } else if (state is RegisterFailure) {
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
              final isLoading = state is RegisterLoading;

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
                                          backgroundColor: Colors.grey[100],
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        icon: const Icon(
                                            Icons.arrow_back_ios_new),
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
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.04),
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
                                            width: 120.w,
                                          ),
                                        ),
                                        SizedBox(height: 10.h),
                                        const Text(
                                          AuthStrings.createAccountTitle,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: ThemeColor.primaryColor,
                                          ),
                                        ),
                                        SizedBox(height: 6.h),
                                        const Text(
                                          AuthStrings.createAccountSubtitle,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        SizedBox(height: 24.h),
                                        CustomFormTextField(
                                          labelText: AuthStrings.fullNameLabel,
                                          hintText: AuthStrings.fullNameHint,
                                          controller: _nameController,
                                          prefixIcon: Icons.person_outline,
                                          validator: AppValidators.validateName,
                                          textInputAction: TextInputAction.next,
                                        ),
                                        SizedBox(height: 16.h),
                                        CustomFormTextField(
                                          labelText: AuthStrings.emailLabel,
                                          hintText: AuthStrings.emailHint,
                                          controller: _emailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          prefixIcon: Icons.email_outlined,
                                          validator:
                                              AppValidators.validateEmail,
                                          textInputAction: TextInputAction.next,
                                          autofillHints: const [
                                            AutofillHints.email
                                          ],
                                        ),
                                        SizedBox(height: 16.h),
                                        CustomFormTextField(
                                          labelText:
                                              AuthStrings.phoneNumberLabel,
                                          hintText: AuthStrings.phoneNumberHint,
                                          controller: _phoneController,
                                          keyboardType: TextInputType.phone,
                                          prefixIcon: Icons.phone_outlined,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          validator:
                                              AppValidators.validatePhone,
                                          textInputAction: TextInputAction.next,
                                          autofillHints: const [
                                            AutofillHints.telephoneNumber
                                          ],
                                        ),
                                        SizedBox(height: 16.h),
                                        CustomFormTextField(
                                          labelText: AuthStrings.passwordLabel,
                                          hintText: AuthStrings.passwordHint,
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
                                            onPressed: () => setState(() =>
                                                _obscurePassword =
                                                    !_obscurePassword),
                                          ),
                                          validator:
                                              AppValidators.validatePassword,
                                          textInputAction: TextInputAction.next,
                                          autofillHints: const [
                                            AutofillHints.newPassword
                                          ],
                                        ),
                                        SizedBox(height: 16.h),
                                        CustomFormTextField(
                                          labelText:
                                              AuthStrings.confirmPasswordLabel,
                                          hintText:
                                              AuthStrings.confirmPasswordHint,
                                          controller:
                                              _confirmPasswordController,
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
                                          validator: (v) => AppValidators
                                              .validateConfirmPassword(
                                                  v, _passwordController.text),
                                          textInputAction: TextInputAction.next,
                                          autofillHints: const [
                                            AutofillHints.newPassword
                                          ],
                                        ),
                                        SizedBox(height: 16.h),
                                        GestureDetector(
                                          onTap: () {
                                            showCountryPicker(
                                              context: context,
                                              showPhoneCode: false,
                                              onSelect: (Country country) {
                                                setState(() {
                                                  // 4. S "ŝ " "ŝ^" ŝ "S
                                                  _countryController.text =
                                                      country.name;
                                                });
                                              },
                                            );
                                          },
                                          child: AbsorbPointer(
                                            child: CustomFormTextField(
                                              labelText:
                                                  AuthStrings.countryLabel,
                                              hintText: AuthStrings.countryHint,
                                              controller:
                                                  _countryController, // 5. . "ŝ^" "S
                                              prefixIcon: Icons.public,
                                              validator: (v) => AppValidators
                                                  .validateDropdown(
                                                      v, 'country'),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 22.h),
                                        CustomButton(
                                          onTap: isLoading
                                              ? null
                                              : () {
                                                  if (_formKey.currentState!
                                                      .validate()) {
                                                    final fullName =
                                                        _nameController.text
                                                            .trim();
                                                    final email =
                                                        _emailController.text
                                                            .trim()
                                                            .toLowerCase();
                                                    final username =
                                                        _deriveUsername(
                                                            fullName: fullName,
                                                            email: email);
                                                    context
                                                        .read<RegisterCubit>()
                                                        .registerUser(
                                                          fullName: fullName,
                                                          username: username,
                                                          email: email,
                                                          password:
                                                              _passwordController
                                                                  .text,
                                                          confirmPassword:
                                                              _confirmPasswordController
                                                                  .text,
                                                          phoneNumber:
                                                              _phoneController
                                                                  .text,
                                                          country:
                                                              _countryController
                                                                  .text, // 6. " "'S. . "ŝ^" ". Ν
                                                        );
                                                  } else {
                                                    HapticFeedback
                                                        .selectionClick();
                                                  }
                                                },
                                          text: isLoading
                                              ? AuthStrings.createAccountLoading
                                              : AuthStrings.createAccount,
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
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.03),
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
                                        _buildSocialLoginSection(),
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
                          color: Colors.black45,
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

  Widget _buildSocialLoginSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              AuthStrings.alreadyHaveAccount,
              style: TextStyle(fontSize: 14),
            ),
            TextButton(
              onPressed: _navigateToLogin,
              child: const Text(
                AuthStrings.logIn,
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
