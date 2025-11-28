import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'package:rahhala_app/core/theme/app_theme.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/utils/token_storage.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/ai_recommendation_tab_flow.dart';
import 'package:rahhala_app/features/profile/presentation/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  final bool isGuest;

  const HomePage({
    super.key,
    this.isGuest = false,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

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
        margin: EdgeInsets.only(
          bottom: 60.h,
          right: 20.w,
          left: 20.w,
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);

    if (index == 1) {
      _notifyComingSoon('Wishlist page - Coming soon!');
    } else if (index == 2) {
      HapticFeedback.mediumImpact();
      _notifyComingSoon('Search - Coming soon!');
    } else if (index == 3) {
      _notifyComingSoon('Trip Planner page - Coming soon!');
    }
  }

  @override
  Widget build(BuildContext context) {
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
      const _SoonPage(title: 'Wishlist'),
      const _SoonPage(title: 'Search'),
      const _SoonPage(title: 'Trip Planner'),
      const AIRecommendationTabFlow(),
      const ProfilePage(embedded: true),
    ];

    return Scaffold(
      backgroundColor: ThemeColor.bgColor,
      extendBody: true,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ThemeColor.primaryColor.withOpacity(0.1),
              ThemeColor.primaryColor.withOpacity(0.15),
              ThemeColor.primaryColor.withOpacity(0.18),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: ThemeColor.primaryColor.withOpacity(0.2),
              blurRadius: 22,
              offset: const Offset(0, -4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: CurvedNavigationBar(
          key: _bottomNavigationKey,
          index: _currentIndex,
          height: 70.0,
          items: <Widget>[
            Icon(
              Icons.home_outlined,
              size: 34,
              color: _currentIndex == 0
                  ? Colors.white
                  : ThemeColor.charcoalColor.withOpacity(0.9),
            ),
            Icon(
              Icons.favorite_border,
              size: 34,
              color: _currentIndex == 1
                  ? Colors.white
                  : ThemeColor.charcoalColor.withOpacity(0.9),
            ),
            Icon(
              Icons.search,
              size: 34,
              color: _currentIndex == 2
                  ? Colors.white
                  : ThemeColor.charcoalColor.withOpacity(0.9),
            ),
            Icon(
              Icons.event_note_outlined,
              size: 34,
              color: _currentIndex == 3
                  ? Colors.white
                  : ThemeColor.charcoalColor.withOpacity(0.9),
            ),
            Icon(
              Icons.auto_awesome,
              size: 34,
              color: _currentIndex == 4
                  ? Colors.white
                  : ThemeColor.charcoalColor.withOpacity(0.9),
            ),
            Icon(
              Icons.person_outline,
              size: 34,
              color: _currentIndex == 5
                  ? Colors.white
                  : ThemeColor.charcoalColor.withOpacity(0.9),
            ),
          ],
          color: ThemeColor.primaryColor,
          buttonBackgroundColor: ThemeColor.charcoalColor,
          backgroundColor: Colors.transparent,
          animationCurve: Curves.easeInOutCubic,
          animationDuration: const Duration(milliseconds: 400),
          onTap: _onTabTapped,
          letIndexChange: (index) => true,
        ),
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: SafeArea(
          child: IndexedStack(
            index: _currentIndex,
            children: pages,
          ),
        ),
      ),
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
                          ? 'Welcome, Guest! 👋'
                          : 'Hi, ${displayName ?? (email.isNotEmpty ? email.split('@').first : 'there')}! 👋',
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
                      'Explore amazing destinations',
                      style: TextStyle(
                        fontSize: 17.sp,
                        color: ThemeColor.neutralGrayColor,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Hero(
                tag: 'profile_avatar',
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ThemeColor.primaryColor.withOpacity(0.25),
                        blurRadius: 10,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 30.r,
                    backgroundColor: ThemeColor.primaryColor.withOpacity(0.15),
                    backgroundImage:
                        (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                            ? NetworkImage(profileImageUrl!)
                            : null,
                    child: (profileImageUrl == null || profileImageUrl!.isEmpty)
                        ? Icon(
                            Icons.person,
                            size: 30.sp,
                            color: ThemeColor.primaryColor,
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 36.h),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 130.w,
                    height: 130.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ThemeColor.primaryColor.withOpacity(0.2),
                          ThemeColor.primaryColor.withOpacity(0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.explore_outlined,
                      size: 65.sp,
                      color: ThemeColor.primaryColor.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 28.h),
                  Text(
                    'Home Page Content',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w600,
                      color: ThemeColor.charcoalColor,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Coming Soon...',
                    style: TextStyle(
                      fontSize: 17.sp,
                      color: ThemeColor.neutralGrayColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
    return Center(
      child: Text(
        '$title — Coming soon',
        style: TextStyle(
          fontSize: 17.sp,
          color: ThemeColor.neutralGrayColor,
        ),
      ),
    );
  }
}
