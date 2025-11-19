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
import 'package:rahhala_app/features/auth/logic/forgot_password/forgot_password_cubit.dart';
import 'package:rahhala_app/features/auth/logic/forgot_password/forgot_password_state.dart';

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
    return BlocProvider(
      create: (_) => sl<ForgotPasswordCubit>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
            listener: (context, state) {
              if (state is ForgotPasswordSuccess) {
                showAppNotification(
                    context: context,
                    title: 'Success',
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
                    title: 'Error',
                    message: state.errorMessage,
                    isError: true);
              }
            },
            builder: (context, state) {
              final isLoading = state is ForgotPasswordLoading;
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
                                child: SvgPicture.asset(AppAssets.imagesLogo,
                                    width: 200.w, height: 200.h)),
                            const Text('Forgot Password',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeColor.primaryColor)),
                            SizedBox(height: 12.h),
                            const Text(
                              "Enter your email address below and we’ll send you a verification code to reset your password.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  height: 1.5),
                            ),
                            SizedBox(height: 40.h),
                            CustomFormTextField(
                              controller: _emailController,
                              labelText: 'Email Address',
                              hintText: 'Enter your email',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.email_outlined,
                              validator: AppValidators.validateEmail,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.email],
                              onFieldSubmitted: (_) {
                                if (_formKey.currentState!.validate() &&
                                    !isLoading) {
                                  context
                                      .read<ForgotPasswordCubit>()
                                      .forgotPassword(
                                          email: _emailController.text);
                                }
                              },
                              onChanged: (_) {},
                            ),
                            SizedBox(height: 40.h),
                            CustomButton(
                              onTap: isLoading
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        context
                                            .read<ForgotPasswordCubit>()
                                            .forgotPassword(
                                                email: _emailController.text);
                                      } else {
                                        HapticFeedback.selectionClick();
                                      }
                                    },
                              text: isLoading ? 'Sending...' : 'Send Code',
                            ),
                            SizedBox(height: 30.h),
                            Center(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Back to Login",
                                    style: TextStyle(
                                        color: ThemeColor.primaryColor,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
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
}
