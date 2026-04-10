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

import 'package:rahhala_app/features/profile/domain/edit_profile/edit_profile_cubit.dart';
import 'package:rahhala_app/features/profile/domain/edit_profile/edit_profile_state.dart';
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
    final DateTime defaultDate = _dobController.text.trim().isNotEmpty
        ? DateTime.parse(_dobController.text.trim())
        : DateTime.now().subtract(const Duration(days: 6570));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: defaultDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).brightness == Brightness.dark
                ? ColorScheme.dark(
                    primary: ThemeColor.primaryColor,
                    onPrimary: Colors.white,
                    surface: Theme.of(context).cardColor,
                    onSurface: Theme.of(context).colorScheme.onSurface,
                  )
                : const ColorScheme.light(
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
        _dobController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
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
        if (_dobController.text.trim().isEmpty && (details.birthDate != null)) {
          _dobController.text =
              "${details.birthDate!.year}-${details.birthDate!.month.toString().padLeft(2, '0')}-${details.birthDate!.day.toString().padLeft(2, '0')}";
        }
        if (_genderController.text.trim().isEmpty &&
            (details.gender?.trim().isNotEmpty ?? false)) {
          setState(() {
            _selectedGender = details.gender!.trim();
            _genderController.text = details.gender!.trim();
          });
        }
        if (_dobController.text.trim().isEmpty) {
          final defaultDate =
              DateTime.now().subtract(const Duration(days: 6570));
          _dobController.text =
              "${defaultDate.year}-${defaultDate.month.toString().padLeft(2, '0')}-${defaultDate.day.toString().padLeft(2, '0')}";
        }
        if (_genderController.text.trim().isEmpty) {
          setState(() {
            _selectedGender = "Prefer not to say";
            _genderController.text = "Prefer not to say";
          });
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 12.h),
                Container(
                  width: 45.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
                SizedBox(height: 16.h),
                ListTile(
                  leading: Icon(Icons.photo_library_outlined,
                      color: isDark ? Colors.white : null),
                  title: Text('Choose from gallery',
                      style: TextStyle(color: isDark ? Colors.white : null)),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                ListTile(
                  leading: Icon(Icons.photo_camera_outlined,
                      color: isDark ? Colors.white : null),
                  title: Text('Take a photo',
                      style: TextStyle(color: isDark ? Colors.white : null)),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                SizedBox(height: 12.h),
              ],
            ),
          ),
        );
      },
    );
    if (source == null) return;

    final picked = await _picker.pickImage(source: source, imageQuality: 85);
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
              isError: true);
        },
        (ok) async {
          showAppNotification(
              context: context, title: 'Updated', message: ok.message);
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
          isError: true);
    }
  }

  void _showGenderPicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 45.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  children: [
                    Text(
                      'Select Gender',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    ...[
                      {'icon': Icons.male, 'label': 'Male'},
                      {'icon': Icons.female, 'label': 'Female'},
                      {'icon': Icons.transgender, 'label': 'Other'},
                    ].map((item) => _buildGenderOption(
                          context: context,
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
                    SizedBox(height: 16.h),
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
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryCol = ThemeColor.primaryColor;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryCol.withOpacity(0.1)
                : isDark
                    ? const Color(0xFF2C2C2C)
                    : Colors.grey[50],
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isSelected
                  ? primaryCol
                  : isDark
                      ? Colors.grey[700]!
                      : Colors.grey[200]!,
              width: isSelected ? 2.5 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryCol
                      : isDark
                          ? Colors.grey[700]
                          : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? Colors.white
                      : isDark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 18.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? primaryCol
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              if (isSelected)
                Icon(Icons.check_circle, color: primaryCol, size: 24.sp),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final scaffoldBg = isDark ? const Color(0xFF121212) : Colors.grey[50]!;
    final primaryCol = ThemeColor.primaryColor;

    return BlocProvider(
      create: (_) => sl<EditProfileCubit>(),
      child: Scaffold(
        backgroundColor: scaffoldBg,
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
                  // ─── App Bar ──────────────────────────────────────────────
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      color: cardBg,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                          blurRadius: 12,
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
                            color: Theme.of(context).colorScheme.onSurface,
                            size: 22.sp,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: isDark
                                ? const Color(0xFF2C2C2C)
                                : Colors.grey[100],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'Update your personal information',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ─── Form ─────────────────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(24.w),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Avatar
                            Center(
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  GestureDetector(
                                    onTap: _isUploadingPhoto
                                        ? null
                                        : _pickAndUploadPhoto,
                                    child: Container(
                                      width: 120.w,
                                      height: 120.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: primaryCol.withOpacity(0.2),
                                            blurRadius: 16,
                                            spreadRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        radius: 60.r,
                                        backgroundColor:
                                            primaryCol.withOpacity(0.12),
                                        backgroundImage: (_profileImageUrl !=
                                                    null &&
                                                _profileImageUrl!.isNotEmpty)
                                            ? NetworkImage(_profileImageUrl!)
                                                as ImageProvider
                                            : null,
                                        child: (_profileImageUrl == null ||
                                                _profileImageUrl!.isEmpty)
                                            ? Icon(
                                                Icons.person,
                                                size: 55.sp,
                                                color:
                                                    primaryCol.withOpacity(0.7),
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
                                        padding: EdgeInsets.all(10.w),
                                        decoration: BoxDecoration(
                                          color: primaryCol,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: cardBg,
                                            width: 3.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Icon(Icons.camera_alt,
                                            size: 18.sp, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  if (_isUploadingPhoto)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.black38,
                                        ),
                                        child: const Center(
                                          child: SizedBox(
                                            width: 32,
                                            height: 32,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3.5,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(height: 36.h),

                            _buildSectionTitle(context, 'Personal Information'),
                            SizedBox(height: 18.h),

                            CustomFormTextField(
                              controller: _name,
                              labelText: 'Full Name',
                              hintText: 'Enter your full name',
                              prefixIcon: Icons.person_outline_rounded,
                              validator: AppValidators.validateName,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.name],
                            ),
                            SizedBox(height: 18.h),

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
                            SizedBox(height: 18.h),

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
                                        validator: (v) => null,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _showGenderPicker(context),
                                    child: AbsorbPointer(
                                      child: CustomFormTextField(
                                        controller: _genderController,
                                        labelText: 'Gender',
                                        hintText: 'Select',
                                        prefixIcon: Icons.transgender_outlined,
                                        validator: (v) => null,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 32.h),

                            _buildSectionTitle(context, 'Contact Information'),
                            SizedBox(height: 18.h),

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
                            SizedBox(height: 18.h),

                            GestureDetector(
                              onTap: () {
                                showCountryPicker(
                                  context: context,
                                  showPhoneCode: false,
                                  countryListTheme: CountryListThemeData(
                                    backgroundColor: cardBg,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(22.r),
                                      topRight: Radius.circular(22.r),
                                    ),
                                    inputDecoration: InputDecoration(
                                      hintText: 'Search country',
                                      prefixIcon: const Icon(Icons.search),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(14.r),
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

                            SizedBox(height: 36.h),

                            CustomButton(
                              onTap: isLoading
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        String? formattedDob;
                                        if (_dobController.text
                                            .trim()
                                            .isNotEmpty) {
                                          try {
                                            final date = DateTime.parse(
                                                _dobController.text.trim());
                                            formattedDob =
                                                "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                                          } catch (e) {
                                            formattedDob =
                                                _dobController.text.trim();
                                          }
                                        }
                                        context.read<EditProfileCubit>().save(
                                              fullName: _name.text.trim(),
                                              phoneNumber: _phone.text.trim(),
                                              country: _countryController.text
                                                  .trim(),
                                              dob: formattedDob ?? '',
                                              gender: _selectedGender ?? '',
                                            );
                                      } else {
                                        HapticFeedback.selectionClick();
                                      }
                                    },
                              text: isLoading ? 'Saving...' : 'Save Changes',
                            ),

                            SizedBox(height: 24.h),
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

  Widget _buildSectionTitle(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 5.w,
          height: 24.h,
          decoration: BoxDecoration(
            color: ThemeColor.primaryColor,
            borderRadius: BorderRadius.circular(3.r),
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : ThemeColor.charcoalColor,
          ),
        ),
      ],
    );
  }
}
