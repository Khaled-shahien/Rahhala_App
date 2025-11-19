

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rahhala_app/core/di/service_locator.dart';

import 'package:rahhala_app/core/theme/app_theme.dart';
import 'package:rahhala_app/core/utils/app_notifications.dart';
import 'package:rahhala_app/core/utils/token_storage.dart';

import 'package:rahhala_app/features/auth/presentation/pages/login_page.dart';
import 'package:rahhala_app/features/auth/presentation/pages/home_page.dart';
import 'package:rahhala_app/features/auth/presentation/pages/reset_password_logged_in_page.dart';
import 'package:rahhala_app/features/auth/presentation/pages/welcome_page.dart';
import 'package:rahhala_app/features/auth/presentation/widgets/profile_list_tile.dart';

import 'package:rahhala_app/features/profile/logic/profile/profile_cubit.dart';
import 'package:rahhala_app/features/profile/logic/profile/profile_state.dart';
import 'package:rahhala_app/features/profile/presentation/pages/edit_profile_page.dart';

import 'package:rahhala_app/core/widgets/rahhala_bottom_bar.dart';
import 'package:rahhala_app/core/widgets/soft_arc_notch.dart';

class ProfilePage extends StatefulWidget {
  
  final bool embedded;

  const ProfilePage({super.key, this.embedded = false});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  late ProfileCubit _profileCubit;

  @override
  void initState() {
    super.initState();
    _profileCubit = sl<ProfileCubit>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _profileCubit.fetch();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showComingSoon(String featureName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: ThemeColor.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.schedule_rounded,
                  size: 40.sp,
                  color: ThemeColor.primaryColor,
                ),
              ),
              SizedBox(height: 20.h),

              Text(
                'Coming Soon!',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 12.h),

              Text(
                '$featureName feature is under development.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24.h),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColor.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Got it',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirm({
    required String title,
    required String okLabel,
    required Color okColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: okColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(okLabel),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadPhoto() async {
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

    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked == null) return;

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: ThemeColor.primaryColor),
        ),
      );

      _profileCubit.uploadPhoto(picked.path);
    } catch (e) {
      if (!mounted) return;
      showAppNotification(
        context: context,
        title: 'Error',
        message: 'Failed to pick image: $e',
        isError: true,
      );
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await _confirm(
      title: 'Delete your account permanently?',
      okLabel: 'DELETE',
      okColor: Colors.red,
    );
    if (confirm != true) return;
    if (!mounted) return;
    _profileCubit.deleteAccount();
  }

  Future<void> _logout() async {
    final confirm = await _confirm(
      title: 'Log out from your account?',
      okLabel: 'LOGOUT',
      okColor: ThemeColor.primaryColor,
    );
    if (confirm != true) return;

    await sl<TokenStorage>().clearAll();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomePage()),
      (_) => false,
    );
  }

  Widget _buildContent(ProfileState state) {
    final storage = sl<TokenStorage>();

    String displayName = storage.displayName;
    String displayEmail = storage.email ?? 'No email';
    String? profileImageUrl = storage.profileImageUrl;

    if (state is ProfileLoaded) {
      if (state.details.fullName.trim().isNotEmpty) {
        displayName = state.details.fullName.trim();
      }
      if (state.details.email.trim().isNotEmpty) {
        displayEmail = state.details.email.trim();
      }
      if (state.details.profileImageUrl != null &&
          state.details.profileImageUrl!.isNotEmpty) {
        profileImageUrl = state.details.profileImageUrl;
      }
    }

    return CustomScrollView(
      slivers: [
        
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            child: Column(
              children: [
                if (!widget.embedded)
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomePage(isGuest: false),
                            ),
                            (route) => false,
                          );
                        },
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 22.sp,
                          color: Colors.black87,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                if (!widget.embedded) SizedBox(height: 16.h),

                Hero(
                  tag: 'profile_avatar',
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        onTap: _pickAndUploadPhoto,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: ThemeColor.primaryColor.withOpacity(0.2),
                                blurRadius: 16,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 56.r,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: (profileImageUrl != null &&
                                    profileImageUrl.isNotEmpty)
                                ? NetworkImage(profileImageUrl) as ImageProvider
                                : null,
                            child: (profileImageUrl == null ||
                                    profileImageUrl.isEmpty)
                                ? Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 48.sp,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: _pickAndUploadPhoto,
                          child: Container(
                            width: 36.w,
                            height: 36.w,
                            decoration: BoxDecoration(
                              color: ThemeColor.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 18.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 6.h),

                Text(
                  displayEmail,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),

        if (state is ProfileLoading && state is! ProfileLoaded)
          const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(
                  color: ThemeColor.primaryColor,
                ),
              ),
            ),
          ),

        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: 8.h),

              ProfileListTile(
                icon: Icons.edit_outlined,
                title: 'Edit profile',
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfilePage(),
                    ),
                  );
                  _profileCubit.fetch();
                },
              ),

              ProfileListTile(
                icon: Icons.notifications_outlined,
                title: 'Notification',
                onTap: () => _showComingSoon('Notification'),
              ),

              ProfileListTile(
                icon: Icons.language_outlined,
                title: 'Language',
                onTap: () => _showComingSoon('Language'),
              ),

              ProfileListTile(
                icon: Icons.card_membership_outlined,
                title: 'Plans',
                onTap: () => _showComingSoon('Plans'),
              ),

              ProfileListTile(
                icon: Icons.palette_outlined,
                title: 'Appearance',
                onTap: () => _showComingSoon('Appearance'),
              ),

              ProfileListTile(
                icon: Icons.lock_outline,
                title: 'Change password',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ResetPasswordLoggedInPage(),
                    ),
                  );
                },
              ),

              ProfileListTile(
                icon: Icons.help_outline_rounded,
                title: 'Help and Support',
                onTap: () => _showComingSoon('Help and Support'),
              ),

              SizedBox(height: 16.h),

              Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey[200],
              ),

              SizedBox(height: 16.h),

              ProfileListTile(
                icon: Icons.logout_rounded,
                title: 'Logout',
                tint: ThemeColor.primaryColor,
                onTap: _logout,
              ),

              ProfileListTile(
                icon: Icons.delete_outline_rounded,
                title: 'Delete Account',
                tint: Colors.red,
                onTap: _deleteAccount,
              ),

              SizedBox(height: 32.h),
            ]),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = BlocProvider.value(
      value: _profileCubit,
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) async {
          
          if (state is! ProfileLoading && state is! ProfileActionLoading) {
            if (Navigator.canPop(context)) {
              final route = ModalRoute.of(context);
              if (route != null && !route.isCurrent) {
                Navigator.pop(context);
              }
            }
          }

          if (state is ProfileFailure) {
            HapticFeedback.mediumImpact();
            showAppNotification(
              context: context,
              title: 'Error',
              message: state.message,
              isError: true,
            );
          } else if (state is ProfileActionSuccess) {
            showAppNotification(
              context: context,
              title: 'Success',
              message: state.model.message,
            );

            final msg = state.model.message.toLowerCase();
            if (msg.contains('delete')) {
              await sl<TokenStorage>().clearAll();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (_) => false,
              );
            } else {
              if (mounted) setState(() {});
            }
          } else if (state is ProfileLoaded) {
            if (mounted) setState(() {});
          }
        },
        builder: (context, state) => _buildContent(state),
      ),
    );

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3377FF).withOpacity(0.15),
              blurRadius: 28,
              spreadRadius: 6,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            HapticFeedback.selectionClick();
            _showComingSoon('Search');
          },
          backgroundColor: ThemeColor.primaryColor,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.search, color: Colors.white, size: 26),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const SoftArcNotchedShape(arcWidth: 120, arcHeight: 22),
        notchMargin: 4,
        elevation: 0,
        color: Colors.transparent,
        child: RahhalaBottomBar(
          currentIndex: 3,
          onTap: (i) {
            if (i == 3) {
              return;
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(child: content),
    );
  }
}
