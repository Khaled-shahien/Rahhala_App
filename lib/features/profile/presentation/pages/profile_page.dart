import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/localization/app_localization_extensions.dart';

import 'package:rahhala_app/core/theme/app_theme.dart';
import 'package:rahhala_app/core/theme/theme_controller.dart';
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

  void _showComingSoon(String featureName) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Theme.of(context).cardColor,
        child: Padding(
          padding: EdgeInsets.all(28.w),
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
                child: Icon(Icons.schedule_rounded,
                    size: 40.sp, color: ThemeColor.primaryColor),
              ),
              SizedBox(height: 20.h),
              Text(
                l10n.commonComingSoon,
                style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface),
              ),
              SizedBox(height: 12.h),
              Text(
                l10n.routerFeatureUnderDevelopment(featureName),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15.sp, color: Colors.grey[500]),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColor.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(l10n.commonGotIt),
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
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18.sp)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.commonCancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: okColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () => Navigator.pop(context, true),
            child: Text(okLabel),
          ),
        ],
      ),
    );
  }

  Future<void> logout() async {
    final confirm = await _confirm(
      title: context.l10n.profileLogoutConfirm,
      okLabel: context.l10n.profileLogoutAction,
      okColor: ThemeColor.primaryColor,
    );
    if (confirm == true) {
      await sl<TokenStorage>().clearAll();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomePage()),
        (_) => false,
      );
    }
  }

  Future<void> deleteAccount() async {
    final confirm = await _confirm(
      title: context.l10n.profileDeleteAccountConfirm,
      okLabel: context.l10n.profileDeleteAction,
      okColor: Colors.red,
    );
    if (confirm == true) _profileCubit.deleteAccount();
  }

  Widget buildContent(ProfileState state) {
    final l10n = context.l10n;
    final themeController = sl<AppThemeController>();
    final storage = sl<TokenStorage>();

    String displayName = storage.displayName;
    String displayEmail = storage.email ?? l10n.profileNoEmail;
    String? profileImageUrl = storage.profileImageUrl;

    if (state is ProfileLoaded) {
      if (state.details.fullName.isNotEmpty)
        displayName = state.details.fullName;
      if (state.details.email.isNotEmpty) displayEmail = state.details.email;
      profileImageUrl = state.details.profileImageUrl;
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!widget.embedded) ...[
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context).cardColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Text(l10n.profileTitle,
                          style: TextStyle(
                              fontSize: 20.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 20.h),
                ],

                // Profile Header Card
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        ThemeColor.primaryColor.withOpacity(0.15),
                        Theme.of(context).colorScheme.surface,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28.r),
                    border: Border.all(
                        color: Theme.of(context).dividerColor.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                            themeController.isDarkMode ? 0.2 : 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Hero(
                        tag: 'profile_avatar_main',
                        child: CircleAvatar(
                          radius: 55.r,
                          backgroundColor:
                              ThemeColor.primaryColor.withOpacity(0.1),
                          backgroundImage: (profileImageUrl != null &&
                                  profileImageUrl.isNotEmpty)
                              ? NetworkImage(profileImageUrl)
                              : null,
                          child: (profileImageUrl == null ||
                                  profileImageUrl.isEmpty)
                              ? Icon(Icons.person,
                                  size: 50.sp, color: ThemeColor.primaryColor)
                              : null,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(displayName,
                          style: TextStyle(
                              fontSize: 22.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(displayEmail,
                            style: TextStyle(
                                fontSize: 13.sp,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Settings Sections
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _sectionTitle(context, l10n.profileAccount),
              SizedBox(height: 10.h),
              _sectionCard(context, [
                ProfileListTile(
                  icon: Icons.edit_outlined,
                  title: l10n.profileEdit,
                  onTap: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EditProfilePage()));
                    _profileCubit.fetch();
                  },
                ),
                _customDivider(context),
                ProfileListTile(
                  icon: Icons.history_rounded,
                  title: l10n.profilePlanHistory,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const TripHistoryScreen())),
                ),
              ]),
              SizedBox(height: 20.h),
              _sectionTitle(context, l10n.profilePreferences),
              SizedBox(height: 10.h),
              _sectionCard(context, [
                ProfileListTile(
                  icon: Icons.language_outlined,
                  title: l10n.profileLanguage,
                  onTap: () => showModalBottomSheet(
                    context: context,
                    backgroundColor: Theme.of(context).cardColor,
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(24))),
                    builder: (_) => const LanguagePickerBottomSheet(),
                  ),
                ),
                _customDivider(context),
                ListenableBuilder(
                  listenable: themeController,
                  builder: (context, _) => ListTile(
                    leading: Icon(
                        themeController.isDarkMode
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: themeController.isDarkMode
                            ? Colors.amber
                            : Theme.of(context).colorScheme.onSurfaceVariant),
                    title: Text(l10n.profileAppearance,
                        style: TextStyle(
                            fontSize: 15.sp, fontWeight: FontWeight.w500)),
                    trailing: Switch(
                      value: themeController.isDarkMode,
                      onChanged: (v) => themeController.toggleTheme(v),
                      activeColor: ThemeColor.primaryColor,
                    ),
                  ),
                ),
              ]),
              SizedBox(height: 20.h),
              _sectionTitle(context, l10n.profileDangerZone),
              SizedBox(height: 10.h),
              _sectionCard(context, [
                ProfileListTile(
                    icon: Icons.logout_rounded,
                    title: l10n.profileLogout,
                    tint: ThemeColor.primaryColor,
                    onTap: logout),
                _customDivider(context),
                ProfileListTile(
                    icon: Icons.delete_outline_rounded,
                    title: l10n.profileDeleteAccount,
                    tint: Colors.red,
                    onTap: deleteAccount),
              ]),
              SizedBox(height: 100.h),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
      ),
    );
  }

  Widget _sectionCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border:
            Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
      ),
      child: Column(children: children),
    );
  }

  Widget _customDivider(BuildContext context) {
    return Divider(
        height: 1,
        indent: 50.w,
        color: Theme.of(context).dividerColor.withOpacity(0.1));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _profileCubit,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        extendBody: true,
        bottomNavigationBar: widget.embedded
            ? null
            : BottomAppBar(
                shape: const SoftArcNotchedShape(arcWidth: 120, arcHeight: 22),
                color: Theme.of(context).cardColor,
                child: RahhalaBottomBar(
                  currentIndex: 2,
                  onTap: (i) => i == 2 ? null : Navigator.pop(context),
                ),
              ),
        floatingActionButton: widget.embedded
            ? null
            : FloatingActionButton(
                onPressed: () => _showComingSoon(context.l10n.homeSearch),
                backgroundColor: ThemeColor.primaryColor,
                child: const Icon(Icons.search, color: Colors.white),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: SafeArea(
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) => buildContent(state),
          ),
        ),
      ),
    );
  }
}
