import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/localization/app_localization_extensions.dart';

import 'package:rahhala_app/core/theme/app_theme.dart';
import 'package:rahhala_app/core/utils/app_notifications.dart';
import 'package:rahhala_app/core/utils/token_storage.dart';

import 'package:rahhala_app/features/auth/presentation/pages/login_page.dart';
import 'package:rahhala_app/features/auth/presentation/pages/home_page.dart';
import 'package:rahhala_app/features/auth/presentation/pages/reset_password_logged_in_page.dart';
import 'package:rahhala_app/features/auth/presentation/pages/welcome_page.dart';
import 'package:rahhala_app/features/auth/presentation/widgets/profile_list_tile.dart';

import 'package:rahhala_app/features/profile/domain/profile/profile_cubit.dart';
import 'package:rahhala_app/features/profile/domain/profile/profile_state.dart';
import 'package:rahhala_app/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:rahhala_app/features/profile/presentation/widgets/language_picker_bottom_sheet.dart';

import 'package:rahhala_app/core/widgets/rahhala_bottom_bar.dart';
import 'package:rahhala_app/core/widgets/soft_arc_notch.dart';
import 'package:rahhala_app/features/trip_history/presentation/pages/trip_history_screen.dart';

class ProfilePage extends StatefulWidget {
  final bool embedded;

  const ProfilePage({super.key, this.embedded = false});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: EdgeInsets.all(28.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90.w,
                height: 90.w,
                decoration: BoxDecoration(
                  color: ThemeColor.primaryColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.schedule_rounded,
                  size: 45.sp,
                  color: ThemeColor.primaryColor,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                l10n.commonComingSoon,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                l10n.routerFeatureUnderDevelopment(featureName),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              SizedBox(height: 28.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColor.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    l10n.commonGotIt,
                    style: TextStyle(
                      fontSize: 17.sp,
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
    final l10n = context.l10n;
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.commonCancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: okColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(okLabel),
          ),
        ],
      ),
    );
  }

  Future<void> deleteAccount() async {
    final l10n = context.l10n;
    final confirm = await _confirm(
      title: l10n.profileDeleteAccountConfirm,
      okLabel: l10n.profileDeleteAction,
      okColor: Colors.red,
    );
    if (confirm != true) return;
    if (!mounted) return;
    _profileCubit.deleteAccount();
  }

  Future<void> logout() async {
    final l10n = context.l10n;
    final confirm = await _confirm(
      title: l10n.profileLogoutConfirm,
      okLabel: l10n.profileLogoutAction,
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

  Future<void> _showLanguagePicker() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const LanguagePickerBottomSheet(),
    );
  }

  Widget buildContent(ProfileState state) {
    final l10n = context.l10n;
    final storage = sl<TokenStorage>();

    String displayName = storage.displayName;
    String displayEmail = storage.email ?? l10n.profileNoEmail;
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
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          size: 24.sp,
                          color: Colors.black87,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Text(
                        l10n.profileTitle,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                if (!widget.embedded) SizedBox(height: 20.h),

                // Profile header with improved styling
                Container(
                  padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 24.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        ThemeColor.primaryColor.withValues(alpha: 0.08),
                        Colors.white,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: ThemeColor.primaryColor.withValues(alpha: 0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Hero(
                        tag: 'profile_avatar_main',
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: ThemeColor.primaryColor
                                    .withValues(alpha: 0.2),
                                blurRadius: 20,
                                spreadRadius: 6,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 60.r,
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
                                    size: 52.sp,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      SizedBox(height: 18.h),
                      Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.mail_outline_rounded,
                              size: 18.sp,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 10.w),
                            Flexible(
                              child: Text(
                                displayEmail,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[700],
                                  height: 1.3,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: 16.h),
              _sectionTitle(l10n.profileAccount),
              SizedBox(height: 12.h),
              _sectionCard([
                ProfileListTile(
                  icon: Icons.edit_outlined,
                  title: l10n.profileEdit,
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
                Divider(height: 1, color: Colors.grey[200]),
                ProfileListTile(
                  icon: Icons.history_rounded,
                  title: l10n.profilePlanHistory,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const TripHistoryScreen()),
                  ),
                ),
                Divider(height: 1, color: Colors.grey[200]),
                ProfileListTile(
                  icon: Icons.lock_outline,
                  title: l10n.profileChangePassword,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ResetPasswordLoggedInPage(),
                      ),
                    );
                  },
                ),
              ]),
              SizedBox(height: 22.h),
              _sectionTitle(l10n.profilePreferences),
              SizedBox(height: 12.h),
              _sectionCard([
                ProfileListTile(
                  icon: Icons.notifications_outlined,
                  title: l10n.profileNotification,
                  onTap: () => _showComingSoon(l10n.profileNotification),
                ),
                Divider(height: 1, color: Colors.grey[200]),
                ProfileListTile(
                  icon: Icons.language_outlined,
                  title: l10n.profileLanguage,
                  onTap: _showLanguagePicker,
                ),
                Divider(height: 1, color: Colors.grey[200]),
                ProfileListTile(
                  icon: Icons.card_membership_outlined,
                  title: l10n.profilePlans,
                  onTap: () => _showComingSoon(l10n.profilePlans),
                ),
                Divider(height: 1, color: Colors.grey[200]),
                ProfileListTile(
                  icon: Icons.palette_outlined,
                  title: l10n.profileAppearance,
                  onTap: () => _showComingSoon(l10n.profileAppearance),
                ),
              ]),
              SizedBox(height: 22.h),
              _sectionTitle(l10n.profileSupport),
              SizedBox(height: 12.h),
              _sectionCard([
                ProfileListTile(
                  icon: Icons.help_outline_rounded,
                  title: l10n.profileHelpSupport,
                  onTap: () => _showComingSoon(l10n.profileHelpSupport),
                ),
              ]),
              SizedBox(height: 22.h),
              _sectionTitle(l10n.profileDangerZone),
              SizedBox(height: 12.h),
              _sectionCard([
                ProfileListTile(
                  icon: Icons.logout_rounded,
                  title: l10n.profileLogout,
                  tint: ThemeColor.primaryColor,
                  onTap: logout,
                ),
                Divider(height: 1, color: Colors.grey[200]),
                ProfileListTile(
                  icon: Icons.delete_outline_rounded,
                  title: l10n.profileDeleteAccount,
                  tint: Colors.red,
                  onTap: deleteAccount,
                ),
              ]),
              SizedBox(height: 36.h),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _sectionCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(children: children),
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
              title: context.l10n.commonError,
              message: state.message,
              isError: true,
            );
          } else if (state is ProfileActionSuccess) {
            showAppNotification(
              context: context,
              title: context.l10n.commonSuccess,
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
        builder: (context, state) => buildContent(state),
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
              color: const Color(0xFF3377FF).withValues(alpha: 0.18),
              blurRadius: 30,
              spreadRadius: 6,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            HapticFeedback.selectionClick();
            _showComingSoon(context.l10n.homeSearch);
          },
          backgroundColor: ThemeColor.primaryColor,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.search, color: Colors.white, size: 28),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const SoftArcNotchedShape(arcWidth: 120, arcHeight: 22),
        notchMargin: 6,
        elevation: 0,
        color: Colors.transparent,
        child: RahhalaBottomBar(
          currentIndex: 2,
          onTap: (i) {
            if (i == 2) {
              return;
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: content,
      ),
    );
  }
}
