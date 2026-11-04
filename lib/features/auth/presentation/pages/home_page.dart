import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:rahhala_app/features/home/presentation/pages/home_screen.dart';
import 'package:rahhala_app/features/home/presentation/pages/favourites_screen.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/localization/app_localization_extensions.dart';
import 'package:rahhala_app/core/utils/token_storage.dart';
import 'package:rahhala_app/core/widgets/anis_avatar.dart';
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
  static const int _tabCount = 5;

  late int _currentIndex;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  /// Tabs are built the first time they're opened and then kept alive by the
  /// IndexedStack. This avoids firing every tab's network calls at startup
  /// (DECISIONS D-10).
  late final Set<int> _builtTabs;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, _tabCount - 1);
    _builtTabs = {_currentIndex};
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _builtTabs.add(index);
    });
    HapticFeedback.mediumImpact();
  }

  Widget _buildTab(int index) {
    switch (index) {
      case 0:
        final storage = sl<TokenStorage>();
        return _HomeMainSection(
          isGuest: widget.isGuest,
          displayName: widget.isGuest ? null : storage.displayName,
          email: widget.isGuest ? '' : storage.email ?? '',
          profileImageUrl: widget.isGuest ? null : storage.profileImageUrl,
        );
      case 1:
        return const FavouritesScreen();
      case 2:
        return NearbyScreen(isGuest: widget.isGuest);
      case 3:
        return const TripTypeSelectionScreen();
      default:
        return const ProfilePage(embedded: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    final List<Widget> pages = List<Widget>.generate(
      _tabCount,
      (index) => _builtTabs.contains(index)
          ? _buildTab(index)
          : const SizedBox.shrink(),
    );
    final navLabels = <String>[
      l10n.a11yNavHome,
      l10n.a11yNavFavourites,
      l10n.a11yNavNearby,
      l10n.a11yNavTrips,
      l10n.a11yNavProfile,
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
            _buildNavIcon(Icons.home_outlined, 0, navLabels[0]),
            _buildNavIcon(Icons.favorite_border, 1, navLabels[1]),
            _buildNavIcon(Icons.search, 2, navLabels[2]),
            _buildNavIcon(Icons.auto_awesome, 3, navLabels[3]),
            _buildNavIcon(Icons.person_outline, 4, navLabels[4]),
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
              PositionedDirectional(
                end: 20.w,
                bottom: 100.h,
                child: Semantics(
                  button: true,
                  label: l10n.a11yOpenAssistant,
                  excludeSemantics: true,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChatBotScreen()),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: AnisAvatar(size: 76),
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

  Widget _buildNavIcon(IconData icon, int index, String label) {
    final selected = _currentIndex == index;
    return Semantics(
      label: label,
      selected: selected,
      button: true,
      child: Icon(
        icon,
        size: 30.sp,
        color: selected ? Colors.white : Colors.white.withValues(alpha: 0.7),
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
                            ? CachedNetworkImageProvider(
                                profileImageUrl!,
                                maxWidth: 180,
                                maxHeight: 180,
                              )
                            : null,
                    onBackgroundImageError:
                        (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                            ? (_, __) {}
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
