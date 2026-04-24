import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:rahhala_app/features/home/presentation/pages/home_screen.dart';
import 'package:rahhala_app/features/home/presentation/pages/favourites_screen.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/localization/app_localization_extensions.dart';
import 'package:rahhala_app/core/utils/token_storage.dart';
import 'package:rahhala_app/features/image_search/presentation/widgets/image_search_bar.dart';
import 'package:rahhala_app/features/nearby/presentation/pages/nearby_screen.dart';
import 'package:rahhala_app/features/profile/presentation/pages/profile_page.dart';
import 'package:rahhala_app/features/trip_type_selection/presentation/pages/trip_type_selection_screen.dart';
import 'package:rahhala_app/features/chatbot/presentation/pages/chat_bot_screen.dart';

class HomePage extends StatefulWidget {
  final bool isGuest;
  final int initialIndex;

  const HomePage({
    super.key,
    this.isGuest = false,
    this.initialIndex = 0,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _currentIndex;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _notifyComingSoon(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 1),
        backgroundColor: ThemeColor.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: EdgeInsetsDirectional.only(
          bottom: 90.h,
          end: 20.w,
          start: 20.w,
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    final l10n = context.l10n;

    setState(() => _currentIndex = index);

    ////////
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final storage = sl<TokenStorage>();
    final displayName = storage.displayName;
    final email = storage.email ?? '';
    final profileImageUrl = storage.profileImageUrl;

    final List<Widget> pages = [
      _HomeMainSection(
        isGuest: widget.isGuest,
        displayName: displayName,
        email: email,
        profileImageUrl: profileImageUrl,
      ),
      const FavouritesScreen(),
      const NearbyScreen(),
      const TripTypeSelectionScreen(),
      const ProfilePage(embedded: true),
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBody: true,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: ThemeColor.primaryColor
                  .withValues(alpha: isDark ? 0.3 : 0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: CurvedNavigationBar(
          key: _bottomNavigationKey,
          index: _currentIndex,
          height: 70.0,
          items: <Widget>[
            _buildNavIcon(Icons.home_outlined, 0),
            _buildNavIcon(Icons.favorite_border, 1),
            _buildNavIcon(Icons.search, 2),
            _buildNavIcon(Icons.auto_awesome, 3),
            _buildNavIcon(Icons.person_outline, 4),
          ],
          color: ThemeColor.primaryColor,
          buttonBackgroundColor:
              isDark ? colorScheme.secondary : ThemeColor.charcoalColor,
          backgroundColor: Colors.transparent,
          animationCurve: Curves.easeInOutCubic,
          animationDuration: const Duration(milliseconds: 400),
          onTap: _onTabTapped,
        ),
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              IndexedStack(
                index: _currentIndex,
                children: pages,
              ),
              Positioned(
                right: 20.w,
                bottom: 100.h,
                child: FloatingActionButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ChatBotScreen()),
                    );
                  },
                  backgroundColor: ThemeColor.primaryColor,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r)),
                  child: Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ThemeColor.primaryColor,
                          ThemeColor.primaryColor.withValues(alpha: 0.8)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: const Icon(Icons.smart_toy_outlined,
                        color: Colors.white, size: 28),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    return Icon(
      icon,
      size: 30.sp,
      color: _currentIndex == index
          ? Colors.white
          : Colors.white.withValues(alpha: 0.7),
    );
  }
}

class _HomeMainSection extends StatelessWidget {
  final bool isGuest;
  final String? displayName;
  final String email;
  final String? profileImageUrl;

  const _HomeMainSection({
    required this.isGuest,
    required this.displayName,
    required this.email,
    required this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGuest
                          ? '${l10n.homeWelcomeGuest} 👋'
                          : '${l10n.homeWelcomeUser(displayName ?? (email.isNotEmpty ? email.split('@').first : 'there'))} 👋',
                      style: TextStyle(
                        fontSize: 23.sp,
                        fontWeight: FontWeight.bold,
                        color: ThemeColor.primaryColor,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      l10n.homeExploreDestinations,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Hero(
                tag: 'profile_avatar_home',
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ThemeColor.primaryColor.withValues(alpha: 0.25),
                        blurRadius: 10,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 30.r,
                    backgroundColor:
                        ThemeColor.primaryColor.withValues(alpha: 0.15),
                    backgroundImage:
                        (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                            ? NetworkImage(profileImageUrl!)
                            : null,
                    child: (profileImageUrl == null || profileImageUrl!.isEmpty)
                        ? Icon(Icons.person,
                            size: 30.sp, color: ThemeColor.primaryColor)
                        : null,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          const ImageSearchBar(),
          SizedBox(height: 24.h),
          const Expanded(child: HomeScreen()),
        ],
      ),
    );
  }
}

class _SoonPage extends StatelessWidget {
  final String title;
  const _SoonPage({required this.title});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Text(
        l10n.homeComingSoonShort(title),
        style: TextStyle(
          fontSize: 17.sp,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
