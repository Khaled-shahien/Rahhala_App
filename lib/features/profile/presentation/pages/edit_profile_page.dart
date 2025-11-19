import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/core/di/service_locator.dart';

import 'package:rahhala_app/core/theme/app_theme.dart';
import 'package:rahhala_app/core/utils/app_notifications.dart';
import 'package:rahhala_app/core/utils/app_validators.dart';

import 'package:rahhala_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:rahhala_app/features/auth/presentation/widgets/custom_country_dropdown.dart';
import 'package:rahhala_app/features/auth/presentation/widgets/custom_form_text_field.dart';

import 'package:rahhala_app/features/profile/logic/edit_profile/edit_profile_cubit.dart';
import 'package:rahhala_app/features/profile/logic/edit_profile/edit_profile_state.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  String? _country;

  final _countries = const [
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
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EditProfileCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          backgroundColor: Colors.white,
          foregroundColor: ThemeColor.charcoalColor,
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocConsumer<EditProfileCubit, EditProfileState>(
            listener: (context, state) {
              if (state is EditProfileSuccess) {
                showAppNotification(
                    context: context,
                    title: 'Saved',
                    message: state.model.message);
                Navigator.pop(context);
              } else if (state is EditProfileFailure) {
                HapticFeedback.mediumImpact();
                showAppNotification(
                    context: context,
                    title: 'Error',
                    message: state.message,
                    isError: true);
              }
            },
            builder: (context, state) {
              final isLoading = state is EditProfileLoading;
              return SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 8.h),

                      CustomFormTextField(
                        controller: _name,
                        labelText: 'Full Name',
                        hintText: 'Enter your full name',
                        prefixIcon: Icons.person_outline,
                        validator: AppValidators.validateName,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                      ),
                      SizedBox(height: 12.h),

                      CustomFormTextField(
                        controller: _phone,
                        labelText: 'Phone Number',
                        hintText: 'Enter your phone number',
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        prefixIcon: Icons.phone_outlined,
                        validator: AppValidators.validatePhone,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.telephoneNumber],
                      ),
                      SizedBox(height: 12.h),

                      CustomCountryDropdown(
                        label: 'Country',
                        hint: 'Select your country',
                        value: _country,
                        items: _countries,
                        prefixIcon: Icons.public,
                        onChanged: (v) => setState(() => _country = v),
                        validator: (v) =>
                            AppValidators.validateDropdown(v, 'country'),
                      ),
                      SizedBox(height: 24.h),

                      CustomButton(
                        onTap: isLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<EditProfileCubit>().save(
                                        fullName: _name.text,
                                        phoneNumber: _phone.text,
                                        country: _country!,
                                      );
                                } else {
                                  HapticFeedback.selectionClick();
                                }
                              },
                        text: isLoading ? 'Saving...' : 'Save Changes',
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
