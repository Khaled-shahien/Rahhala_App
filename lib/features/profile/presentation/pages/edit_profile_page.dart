import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:country_picker/country_picker.dart';
import 'package:image_picker/image_picker.dart';

import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';
import 'package:rahhala_app/core/utils/app_notifications.dart';
import 'package:rahhala_app/core/utils/app_validators.dart';
import 'package:rahhala_app/core/utils/token_storage.dart';

import 'package:rahhala_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:rahhala_app/features/auth/presentation/widgets/custom_form_text_field.dart';

import 'package:rahhala_app/features/profile/logic/edit_profile/edit_profile_cubit.dart';
import 'package:rahhala_app/features/profile/logic/edit_profile/edit_profile_state.dart';
import 'package:rahhala_app/features/profile/data/repositories/user_repository.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _dobController;
  late final TextEditingController _genderController;
  late final TextEditingController _countryController;

  String? _selectedGender;
  String? _profileImageUrl;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _email = TextEditingController();
    _phone = TextEditingController();
    _dobController = TextEditingController();
    _genderController = TextEditingController();
    _countryController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillUserData();
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _dobController.dispose();
    _genderController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ThemeColor.charcoalColor,
              onPrimary: Colors.white,
              onSurface: ThemeColor.charcoalColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = '${picked.toLocal()}'.split(' ')[0];
      });
    }
  }

  Future<void> _prefillUserData() async {
    final storage = sl<TokenStorage>();
    if (mounted && (storage.fullName?.trim().isNotEmpty ?? false)) {
      _name.text = storage.fullName!.trim();
    }
    if (mounted && (storage.email?.trim().isNotEmpty ?? false)) {
      _email.text = storage.email!.trim();
    }
    if (mounted &&
        (storage.profileImageUrl != null &&
            storage.profileImageUrl!.trim().isNotEmpty)) {
      setState(() {
        _profileImageUrl = storage.profileImageUrl!.trim();
      });
    }

    try {
      final repo = sl<UserRepo>();
      final res = await repo.getDetails();
      if (!mounted) return;
      res.fold((_) {}, (details) {
        if (_name.text.trim().isEmpty && details.fullName.trim().isNotEmpty) {
          _name.text = details.fullName.trim();
        }
        if (_email.text.trim().isEmpty && details.email.trim().isNotEmpty) {
          _email.text = details.email.trim();
        }
        if (_phone.text.trim().isEmpty &&
            (details.phoneNumber?.trim().isNotEmpty ?? false)) {
          _phone.text = details.phoneNumber!.trim();
        }
        if (_countryController.text.trim().isEmpty &&
            (details.countryName?.trim().isNotEmpty ?? false)) {
          _countryController.text = details.countryName!.trim();
        }
        if (details.profileImageUrl != null &&
            details.profileImageUrl!.trim().isNotEmpty) {
          setState(() {
            _profileImageUrl = details.profileImageUrl!.trim();
          });
        }
      });
    } catch (_) {}
  }

  Future<void> _pickAndUploadPhoto() async {
    if (_isUploadingPhoto) return;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take a photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
    if (source == null) return;

    final picked =
        await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    if (!mounted) return;

    setState(() => _isUploadingPhoto = true);
    try {
      final repo = sl<UserRepo>();
      final res = await repo.uploadPhoto(filePath: picked.path);
      if (!mounted) return;

      await res.fold(
        (f) async {
          setState(() => _isUploadingPhoto = false);
          HapticFeedback.mediumImpact();
          showAppNotification(
            context: context,
            title: 'Error',
            message: f.message,
            isError: true,
          );
        },
        (ok) async {
          showAppNotification(
            context: context,
            title: 'Updated',
            message: ok.message,
          );

          final detailsRes = await repo.getDetails();
          detailsRes.fold((_) {}, (details) async {
            if (details.profileImageUrl != null &&
                details.profileImageUrl!.trim().isNotEmpty) {
              await sl<TokenStorage>()
                  .setProfileImageUrl(details.profileImageUrl!.trim());
              if (mounted) {
                setState(() {
                  _profileImageUrl = details.profileImageUrl!.trim();
                });
              }
            }
          });

          if (mounted) setState(() => _isUploadingPhoto = false);
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingPhoto = false);
      HapticFeedback.mediumImpact();
      showAppNotification(
        context: context,
        title: 'Error',
        message: 'Failed to upload photo',
        isError: true,
      );
    }
  }

  void _showGenderPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 8.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    Text(
                      'Select Gender',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: ThemeColor.charcoalColor,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    ...[
                      {'icon': Icons.male, 'label': 'Male'},
                      {'icon': Icons.female, 'label': 'Female'},
                      {'icon': Icons.transgender, 'label': 'Other'},
                    ].map((item) => _buildGenderOption(
                          icon: item['icon'] as IconData,
                          label: item['label'] as String,
                          isSelected: _selectedGender == item['label'],
                          onTap: () {
                            setState(() {
                              _selectedGender = item['label'] as String;
                              _genderController.text = item['label'] as String;
                            });
                            Navigator.of(context).pop();
                          },
                        )),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGenderOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: isSelected
                ? ThemeColor.charcoalColor.withOpacity(0.08)
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? ThemeColor.charcoalColor : Colors.grey[200]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color:
                      isSelected ? ThemeColor.charcoalColor : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.grey[600],
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color:
                      isSelected ? ThemeColor.charcoalColor : Colors.grey[700],
                ),
              ),
              const Spacer(),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: ThemeColor.charcoalColor,
                  size: 22.sp,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EditProfileCubit>(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
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
              return Column(
                children: [
                  // Custom App Bar
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
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
                            color: ThemeColor.charcoalColor,
                            size: 20.sp,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey[100],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: ThemeColor.charcoalColor,
                              ),
                            ),
                            Text(
                              'Update your personal information',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Form Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20.w),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Profile Avatar Section
                            Center(
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  GestureDetector(
                                    onTap: _isUploadingPhoto
                                        ? null
                                        : _pickAndUploadPhoto,
                                    child: Container(
                                      width: 110.w,
                                      height: 110.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: ThemeColor.charcoalColor
                                                .withOpacity(0.12),
                                            blurRadius: 14,
                                            spreadRadius: 3,
                                          ),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        radius: 55.r,
                                        backgroundColor: ThemeColor.charcoalColor
                                            .withOpacity(0.1),
                                        backgroundImage:
                                            (_profileImageUrl != null &&
                                                    _profileImageUrl!.isNotEmpty)
                                                ? NetworkImage(_profileImageUrl!)
                                                    as ImageProvider
                                                : null,
                                        child: (_profileImageUrl == null ||
                                                _profileImageUrl!.isEmpty)
                                            ? Icon(
                                                Icons.person,
                                                size: 50.sp,
                                                color: ThemeColor.charcoalColor
                                                    .withOpacity(0.6),
                                              )
                                            : null,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: _isUploadingPhoto
                                          ? null
                                          : _pickAndUploadPhoto,
                                      child: Container(
                                        padding: EdgeInsets.all(8.w),
                                        decoration: BoxDecoration(
                                          color: ThemeColor.charcoalColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 3,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.camera_alt,
                                          size: 16.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_isUploadingPhoto)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.black26,
                                        ),
                                        child: const Center(
                                          child: SizedBox(
                                            width: 28,
                                            height: 28,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(height: 32.h),

                            // Personal Information Section
                            _buildSectionTitle('Personal Information'),
                            SizedBox(height: 16.h),

                            CustomFormTextField(
                              controller: _name,
                              labelText: 'Full Name',
                              hintText: 'Enter your full name',
                              prefixIcon: Icons.person_outline_rounded,
                              validator: AppValidators.validateName,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.name],
                            ),
                            SizedBox(height: 16.h),

                            AbsorbPointer(
                              child: CustomFormTextField(
                                controller: _email,
                                labelText: 'Email',
                                hintText: 'Your email',
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: Icons.email_outlined,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
                              ),
                            ),
                            SizedBox(height: 16.h),

                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _selectDateOfBirth(context),
                                    child: AbsorbPointer(
                                      child: CustomFormTextField(
                                        controller: _dobController,
                                        labelText: 'Birth Date',
                                        hintText: 'Select date',
                                        prefixIcon: Icons.cake_outlined,
                                        validator: (v) =>
                                            v!.isEmpty ? 'Required' : null,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _showGenderPicker(context),
                                    child: AbsorbPointer(
                                      child: CustomFormTextField(
                                        controller: _genderController,
                                        labelText: 'Gender',
                                        hintText: 'Select',
                                        prefixIcon: Icons.transgender_outlined,
                                        validator: (v) =>
                                            v!.isEmpty ? 'Required' : null,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 28.h),

                            // Contact Information Section
                            _buildSectionTitle('Contact Information'),
                            SizedBox(height: 16.h),

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
                              textInputAction: TextInputAction.next,
                              autofillHints: const [
                                AutofillHints.telephoneNumber
                              ],
                            ),
                            SizedBox(height: 16.h),

                            GestureDetector(
                              onTap: () {
                                showCountryPicker(
                                  context: context,
                                  showPhoneCode: false,
                                  countryListTheme: CountryListThemeData(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20.r),
                                      topRight: Radius.circular(20.r),
                                    ),
                                    inputDecoration: InputDecoration(
                                      hintText: 'Search country',
                                      prefixIcon: const Icon(Icons.search),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                      ),
                                    ),
                                  ),
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
                                  prefixIcon: Icons.public_rounded,
                                  validator: (v) =>
                                      AppValidators.validateDropdown(
                                          v, 'country'),
                                ),
                              ),
                            ),

                            SizedBox(height: 32.h),

                            // Save Button
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

                            SizedBox(height: 20.h),
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

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 20.h,
          decoration: BoxDecoration(
            color: ThemeColor.charcoalColor,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: ThemeColor.charcoalColor,
          ),
        ),
      ],
    );
  }
}
