import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:country_picker/country_picker.dart';

import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';
import 'package:rahhala_app/core/utils/app_notifications.dart';
import 'package:rahhala_app/core/utils/app_validators.dart';

import 'package:rahhala_app/features/auth/presentation/widgets/custom_button.dart';
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
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _dobController;
  late final TextEditingController _genderController;
  late final TextEditingController _countryController;

  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _phone = TextEditingController();
    _dobController = TextEditingController();
    _genderController = TextEditingController();
    _countryController = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _dobController.dispose();
    _genderController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = '${picked.toLocal()}'.split(' ')[0];
      });
    }
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
                  message: state.model.message,
                );
                Navigator.pop(context);
              } else if (state is EditProfileFailure) {
                HapticFeedback.mediumImpact();
                showAppNotification(
                  context: context,
                  title: 'Error',
                  message: state.message,
                  isError: true,
                );
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
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        prefixIcon: Icons.phone_outlined,
                        validator: AppValidators.validatePhone,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.telephoneNumber],
                      ),
                      SizedBox(height: 12.h),

                      GestureDetector(
                        onTap: () {
                          showCountryPicker(
                            context: context,
                            showPhoneCode: false,
                            onSelect: (Country country) {
                              setState(() {
                                _countryController.text = country.name;
                              });
                            },
                          );
                        },
                        child: AbsorbPointer(
                          child: CustomFormTextField(
                            controller: _countryController,
                            labelText: 'Country',
                            hintText: 'Select your country',
                            prefixIcon: Icons.public,
                            validator: (v) =>
                                AppValidators.validateDropdown(v, 'country'),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),

                      GestureDetector(
                        onTap: () => _selectDateOfBirth(context),
                        child: AbsorbPointer(
                          child: CustomFormTextField(
                            controller: _dobController,
                            labelText: 'Date of Birth',
                            hintText: 'Select your birth date',
                            prefixIcon: Icons.calendar_today_outlined,
                            validator: (v) => v == null || v.isEmpty
                                ? 'Please select your birth date'
                                : null,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // ✅ إصلاح الجزء الخاص بالـ Gender
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedGender = newValue;
                            _genderController.text = newValue ?? '';
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Gender',
                          hintText: 'Select your gender',
                          prefixIcon: const Icon(Icons.transgender_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Please select your gender'
                            : null,
                        items: ['Male', 'Female', 'Other']
                            .map((gender) => DropdownMenuItem<String>(
                                  value: gender,
                                  child: Text(gender),
                                ))
                            .toList(),
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
                                        country: _countryController.text,
                                        dob: _dobController.text,
                                        gender: _selectedGender ?? '',
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
