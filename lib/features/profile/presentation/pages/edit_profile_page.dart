import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/localization/app_localization_extensions.dart';
import 'package:rahhala_app/core/services/image_picker_service.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';
import 'package:rahhala_app/core/utils/app_notifications.dart';
import 'package:rahhala_app/core/utils/app_validators.dart';
import 'package:rahhala_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:rahhala_app/features/auth/presentation/widgets/custom_form_text_field.dart';
import 'package:rahhala_app/features/profile/domain/edit_profile/edit_profile_cubit.dart';
import 'package:rahhala_app/features/profile/domain/edit_profile/edit_profile_state.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _dobController = TextEditingController();
  final _genderController = TextEditingController();
  final _countryController = TextEditingController();

  String? _selectedGender;
  String? _profileImageUrl;
  bool _initialDataApplied = false;

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF121212) : Colors.grey[50]!;

    return BlocProvider(
      create: (_) => sl<EditProfileCubit>()..loadInitialProfile(),
      child: Scaffold(
        backgroundColor: scaffoldBg,
        body: SafeArea(
          child: BlocConsumer<EditProfileCubit, EditProfileState>(
            listener: _onStateChanged,
            builder: (context, state) {
              final isInitialLoading =
                  state is EditProfileLoading && !_initialDataApplied;
              if (isInitialLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final isSaving = state is EditProfileLoading;
              final isUploading = state is EditProfileUploading;

              return Column(
                children: [
                  _Header(title: context.l10n.editProfileTitle),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(24.w),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _AvatarPicker(
                              imageUrl: _profileImageUrl,
                              isUploading: isUploading,
                              onTap: () => _showPhotoSourceSheet(context),
                            ),
                            SizedBox(height: 36.h),
                            _SectionTitle(
                              title: context.l10n.editProfilePersonalInfo,
                            ),
                            SizedBox(height: 18.h),
                            CustomFormTextField(
                              controller: _name,
                              labelText: context.l10n.editProfileFullName,
                              hintText: context.l10n.editProfileFullNameHint,
                              prefixIcon: Icons.person_outline_rounded,
                              validator: AppValidators.validateName,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.name],
                            ),
                            SizedBox(height: 18.h),
                            AbsorbPointer(
                              child: CustomFormTextField(
                                controller: _email,
                                labelText: context.l10n.editProfileEmail,
                                hintText: context.l10n.editProfileEmailHint,
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
                                  child: _ReadonlyField(
                                    onTap: () => _selectDateOfBirth(context),
                                    child: CustomFormTextField(
                                      controller: _dobController,
                                      labelText:
                                          context.l10n.editProfileBirthDate,
                                      hintText:
                                          context.l10n.editProfileBirthDateHint,
                                      prefixIcon: Icons.cake_outlined,
                                      validator: (_) => null,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: _ReadonlyField(
                                    onTap: () => _showGenderPicker(context),
                                    child: CustomFormTextField(
                                      controller: _genderController,
                                      labelText: context.l10n.editProfileGender,
                                      hintText:
                                          context.l10n.editProfileGenderHint,
                                      prefixIcon: Icons.transgender_outlined,
                                      validator: (_) => null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 32.h),
                            _SectionTitle(
                              title: context.l10n.editProfileContactInfo,
                            ),
                            SizedBox(height: 18.h),
                            CustomFormTextField(
                              controller: _phone,
                              labelText: context.l10n.editProfilePhone,
                              hintText: context.l10n.editProfilePhoneHint,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              prefixIcon: Icons.phone_outlined,
                              validator: AppValidators.validatePhone,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [
                                AutofillHints.telephoneNumber,
                              ],
                            ),
                            SizedBox(height: 18.h),
                            _ReadonlyField(
                              onTap: () => _showCountrySelector(context),
                              child: CustomFormTextField(
                                controller: _countryController,
                                labelText: context.l10n.editProfileCountry,
                                hintText: context.l10n.editProfileCountryHint,
                                prefixIcon: Icons.public_rounded,
                                validator: (value) =>
                                    AppValidators.validateDropdown(
                                  value,
                                  'country',
                                ),
                              ),
                            ),
                            SizedBox(height: 36.h),
                            CustomButton(
                              onTap: isSaving ? null : () => _save(context),
                              text: isSaving
                                  ? context.l10n.editProfileSaving
                                  : context.l10n.editProfileSaveChanges,
                              isLoading: isSaving,
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

  void _onStateChanged(BuildContext context, EditProfileState state) {
    if (state is EditProfileInitial && state.formData != null) {
      _applyInitialData(state.formData!);
    } else if (state is EditProfileSuccess) {
      final imageUrl = state.formData?.profileImageUrl;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        setState(() => _profileImageUrl = imageUrl);
      }
      showAppNotification(
        context: context,
        title: state.shouldClose
            ? context.l10n.editProfileSaved
            : context.l10n.editProfileUpdated,
        message: state.model.message,
      );
      if (state.shouldClose) Navigator.pop(context);
    } else if (state is EditProfileError) {
      HapticFeedback.mediumImpact();
      showAppNotification(
        context: context,
        title: context.l10n.commonError,
        message: state.message,
        isError: true,
      );
    }
  }

  void _applyInitialData(EditProfileFormData data) {
    if (_initialDataApplied) return;

    setState(() {
      _initialDataApplied = true;
      _name.text = data.fullName;
      _email.text = data.email;
      _phone.text = data.phoneNumber;
      _countryController.text = data.country;
      _dobController.text = data.birthDate;
      _selectedGender = data.gender;
      _genderController.text = _genderLabel(data.gender);
      _profileImageUrl = data.profileImageUrl;
    });
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _currentBirthDate(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
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
      ),
    );
    if (picked == null) return;

    setState(() => _dobController.text = _formatDate(picked));
  }

  Future<void> _showPhotoSourceSheet(BuildContext context) async {
    final source = await showModalBottomSheet<AppImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _PhotoSourceSheet(
        onSelected: (source) => Navigator.pop(sheetContext, source),
      ),
    );
    if (!context.mounted || source == null) return;

    context.read<EditProfileCubit>().pickAndUploadPhoto(source);
  }

  void _showGenderPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _GenderSheet(
        selectedGender: _selectedGender,
        onSelected: (value, label) {
          setState(() {
            _selectedGender = value;
            _genderController.text = label;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showCountrySelector(BuildContext context) {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      countryListTheme: CountryListThemeData(
        backgroundColor: Theme.of(context).cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
        inputDecoration: InputDecoration(
          hintText: context.l10n.editProfileSearchCountry,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
      onSelect: (country) => setState(() {
        _countryController.text = country.name;
      }),
    );
  }

  void _save(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.selectionClick();
      return;
    }

    context.read<EditProfileCubit>().save(
          fullName: _name.text.trim(),
          phoneNumber: _phone.text.trim(),
          country: _countryController.text.trim(),
          dob: _dobController.text.trim(),
          gender: _selectedGender ?? '',
        );
  }

  DateTime _currentBirthDate() {
    try {
      return DateTime.parse(_dobController.text.trim());
    } catch (_) {
      return DateTime.now().subtract(const Duration(days: 6570));
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _genderLabel(String value) {
    return switch (value) {
      'Male' => context.l10n.editProfileGenderMale,
      'Female' => context.l10n.editProfileGenderFemale,
      'Other' => context.l10n.editProfileGenderOther,
      _ => value,
    };
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      color: ThemeColor.primaryColor,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.imageUrl,
    required this.isUploading,
    required this.onTap,
  });

  final String? imageUrl;
  final bool isUploading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: isUploading ? null : onTap,
            child: CircleAvatar(
              radius: 60.r,
              backgroundColor: ThemeColor.primaryColor.withValues(alpha: 0.12),
              backgroundImage:
                  hasImage ? CachedNetworkImageProvider(imageUrl!) : null,
              child: hasImage
                  ? null
                  : Icon(
                      Icons.person,
                      size: 55.sp,
                      color: ThemeColor.primaryColor.withValues(alpha: 0.7),
                    ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton.filled(
              onPressed: isUploading ? null : onTap,
              icon: Icon(Icons.camera_alt, size: 18.sp),
              style: IconButton.styleFrom(
                backgroundColor: ThemeColor.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          if (isUploading)
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black38,
                ),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReadonlyField extends StatelessWidget {
  const _ReadonlyField({
    required this.onTap,
    required this.child,
  });

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(child: child),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
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
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _PhotoSourceSheet extends StatelessWidget {
  const _PhotoSourceSheet({required this.onSelected});

  final ValueChanged<AppImageSource> onSelected;

  @override
  Widget build(BuildContext context) {
    return _BottomSheetFrame(
      children: [
        ListTile(
          leading: const Icon(Icons.photo_library_outlined),
          title: Text(context.l10n.editProfileChooseGallery),
          onTap: () => onSelected(AppImageSource.gallery),
        ),
        ListTile(
          leading: const Icon(Icons.photo_camera_outlined),
          title: Text(context.l10n.editProfileTakePhoto),
          onTap: () => onSelected(AppImageSource.camera),
        ),
      ],
    );
  }
}

class _GenderSheet extends StatelessWidget {
  const _GenderSheet({
    required this.selectedGender,
    required this.onSelected,
  });

  final String? selectedGender;
  final void Function(String value, String label) onSelected;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.male, 'Male', context.l10n.editProfileGenderMale),
      (Icons.female, 'Female', context.l10n.editProfileGenderFemale),
      (Icons.transgender, 'Other', context.l10n.editProfileGenderOther),
    ];

    return _BottomSheetFrame(
      children: [
        Text(
          context.l10n.editProfileSelectGender,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 16.h),
        for (final item in items)
          ListTile(
            leading: Icon(item.$1),
            title: Text(item.$3),
            trailing: selectedGender == item.$2
                ? const Icon(Icons.check_circle)
                : null,
            onTap: () => onSelected(item.$2, item.$3),
          ),
      ],
    );
  }
}

class _BottomSheetFrame extends StatelessWidget {
  const _BottomSheetFrame({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
              SizedBox(height: 16.h),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
