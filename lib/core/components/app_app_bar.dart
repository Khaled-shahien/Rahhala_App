import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A reusable app bar component following Material 3 design principles
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final Widget? bottom;

  const AppAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedForegroundColor =
        foregroundColor ?? Theme.of(context).appBarTheme.foregroundColor;
    return AppBar(
      title: Text(
        title,
        style: Theme.of(context)
            .appBarTheme
            .titleTextStyle
            ?.copyWith(color: resolvedForegroundColor),
      ),
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      backgroundColor:
          backgroundColor ?? Theme.of(context).appBarTheme.backgroundColor,
      foregroundColor: resolvedForegroundColor,
      elevation: elevation ?? Theme.of(context).appBarTheme.elevation,
      bottom: bottom as PreferredSizeWidget?,
    );
  }

  @override
  Size get preferredSize {
    if (bottom is PreferredSizeWidget) {
      return Size.fromHeight(kToolbarHeight +
          (bottom as PreferredSizeWidget).preferredSize.height);
    }
    return const Size.fromHeight(kToolbarHeight);
  }
}

/// Pre-styled app bar variants
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;

  const HomeAppBar({
    super.key,
    required this.title,
    this.onProfileTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppAppBar(
      title: title,
      actions: [
        if (onNotificationTap != null)
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: onNotificationTap,
          ),
        if (onProfileTap != null)
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: onProfileTap,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final String? hintText;
  final void Function(String)? onSearchChanged;
  final VoidCallback? onSearchSubmitted;

  const SearchAppBar({
    super.key,
    required this.title,
    this.hintText,
    this.onSearchChanged,
    this.onSearchSubmitted,
  });

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 56);
}

class _SearchAppBarState extends State<SearchAppBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppAppBar(
      title: widget.title,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: widget.hintText ?? 'Search...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                        });
                        widget.onSearchChanged?.call('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            onChanged: widget.onSearchChanged,
            onSubmitted: widget.onSearchSubmitted != null
                ? (_) => widget.onSearchSubmitted!()
                : null,
          ),
        ),
      ),
    );
  }
}
