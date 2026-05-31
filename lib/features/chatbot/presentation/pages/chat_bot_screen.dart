import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/widgets/anis_avatar.dart';
import 'package:rahhala_app/features/chatbot/presentation/cubit/chat_bot_cubit.dart';
import 'package:rahhala_app/features/chatbot/presentation/cubit/chat_bot_state.dart';
import 'package:rahhala_app/features/chatbot/presentation/widgets/chat_bubble.dart';

import 'package:rahhala_app/features/chatbot/presentation/widgets/typing_indicator.dart';
import 'package:rahhala_app/features/chatbot/presentation/widgets/chat_input_field.dart';
import 'package:rahhala_app/core/localization/app_localization_extensions.dart';

class ChatBotScreen extends StatelessWidget {
  const ChatBotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<ChatBotCubit>(),
      child: const _ChatBotScreenContent(),
    );
  }
}

class _ChatBotScreenContent extends StatefulWidget {
  const _ChatBotScreenContent();

  @override
  State<_ChatBotScreenContent> createState() => _ChatBotScreenContentState();
}

class _ChatBotScreenContentState extends State<_ChatBotScreenContent> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  List<_ChatSuggestion> _emptyStateSuggestions = const [];
  Locale? _suggestionLocale;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ChatBotCubit>().initializeContext();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (_suggestionLocale != locale || _emptyStateSuggestions.isEmpty) {
      _suggestionLocale = locale;
      _emptyStateSuggestions = _pickRandomSuggestions(context);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  // ─── Theme Helpers ────────────────────────────────────────────────────────
  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    final scaffoldBg = isDark ? const Color(0xFF121212) : Colors.grey[50];
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: _buildAppBar(context),
      body: BlocConsumer<ChatBotCubit, ChatBotState>(
        listener: (context, state) {
          if (state is ChatBotMessageSent || state is ChatBotMessageReceived) {
            _scrollToBottom();
          }
          if (state is ChatBotError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<ChatBotCubit>();
          final messages = cubit.conversationHistory;

          return Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? _buildEmptyState(context, cubit)
                    : ListView.builder(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 20.h),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: ChatBubble(
                              message: message.message,
                              isUser: message.role == 'user',
                              timestamp: message.timestamp,
                            ),
                          );
                        },
                      ),
              ),
              if (state is ChatBotLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TypingIndicator(),
                  ),
                ),
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: ChatInputField(
                      controller: _messageController,
                      isLoading: state is ChatBotLoading,
                      onSend: (message) {
                        if (message.trim().isNotEmpty) {
                          cubit.sendMessage(message);
                          _messageController.clear();
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: ThemeColor.primaryColor,
      surfaceTintColor: ThemeColor.primaryColor,
      elevation: 0,
      toolbarHeight: 88.h,
      leadingWidth: 56.w,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
        style: IconButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
      titleSpacing: 8.w,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.l10n.chatbotName,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            context.l10n.chatbotSubtitle,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.4,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: EdgeInsetsDirectional.only(end: 12.w),
          child: IconButton(
            icon: Icon(
              Icons.delete_sweep_outlined,
              color: Colors.white.withValues(alpha: 0.95),
            ),
            onPressed: _showClearConfirmation,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, ChatBotCubit cubit) {
    final isDark = _isDark(context);
    final suggestions = _emptyStateSuggestions.isEmpty
        ? _pickRandomSuggestions(context)
        : _emptyStateSuggestions;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 60.h, horizontal: 30.w),
        child: Column(
          children: [
            const AnisAvatar(size: 170),
            SizedBox(height: 24.h),
            Text(
              context.l10n.chatbotWelcome,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              context.l10n.chatbotHelp,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            SizedBox(height: 30.h),
            Column(
              children: [
                for (final suggestion in suggestions) ...[
                  _SuggestionPromptCard(
                    suggestion: suggestion,
                    isDark: isDark,
                    onTap: () => cubit.sendMessage(suggestion.text),
                  ),
                  SizedBox(height: 10.h),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<_ChatSuggestion> _pickRandomSuggestions(BuildContext context) {
    final suggestions = _buildSuggestionPool(context).toList()
      ..shuffle(Random());
    return List.unmodifiable(suggestions.take(3));
  }

  List<_ChatSuggestion> _buildSuggestionPool(BuildContext context) {
    final l10n = context.l10n;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (isArabic) {
      return [
        _ChatSuggestion(Icons.flight_takeoff_rounded, l10n.chatbotSuggestion1),
        _ChatSuggestion(Icons.hotel_rounded, l10n.chatbotSuggestion2),
        _ChatSuggestion(Icons.family_restroom_rounded, l10n.chatbotSuggestion3),
        const _ChatSuggestion(
          Icons.map_rounded,
          'خطط لي برنامج 5 أيام في القاهرة',
        ),
        const _ChatSuggestion(
          Icons.beach_access_rounded,
          'اقترح أفضل شواطئ قريبة من الغردقة',
        ),
        const _ChatSuggestion(
          Icons.museum_rounded,
          'اصنع لي جولة ثقافية في الأقصر',
        ),
        const _ChatSuggestion(
          Icons.restaurant_rounded,
          'رتب لي جولة أكل محلي في الإسكندرية',
        ),
        const _ChatSuggestion(
          Icons.savings_rounded,
          'خطط رحلة اقتصادية مناسبة لميزانية محدودة',
        ),
        const _ChatSuggestion(
          Icons.hiking_rounded,
          'ما أفضل أنشطة المغامرة في دهب؟',
        ),
        const _ChatSuggestion(
          Icons.wb_sunny_rounded,
          'ما أفضل وقت لزيارة سيوة؟',
        ),
        const _ChatSuggestion(
          Icons.shopping_bag_rounded,
          'خطط لي يوم تسوق في دبي',
        ),
        const _ChatSuggestion(
          Icons.child_care_rounded,
          'اقترح برنامج رحلة مناسب للأطفال',
        ),
        const _ChatSuggestion(
          Icons.favorite_rounded,
          'اصنع برنامج شهر عسل هادئ ومميز',
        ),
        const _ChatSuggestion(
          Icons.backpack_rounded,
          'ماذا أحزم لرحلة صحراوية؟',
        ),
        const _ChatSuggestion(
          Icons.route_rounded,
          'قارن لي بين دبي وأبوظبي للعائلات',
        ),
        const _ChatSuggestion(
          Icons.explore_rounded,
          'اقترح أماكن مخفية وغير مزدحمة',
        ),
        const _ChatSuggestion(
          Icons.account_balance_rounded,
          'اصنع مسار مشي في القاهرة التاريخية',
        ),
        const _ChatSuggestion(
          Icons.public_rounded,
          'ساعدني أختار وجهة مناسبة لعطلة قصيرة',
        ),
      ];
    }

    return [
      _ChatSuggestion(Icons.flight_takeoff_rounded, l10n.chatbotSuggestion1),
      _ChatSuggestion(Icons.hotel_rounded, l10n.chatbotSuggestion2),
      _ChatSuggestion(Icons.family_restroom_rounded, l10n.chatbotSuggestion3),
      const _ChatSuggestion(
        Icons.map_rounded,
        'Build a 5-day Cairo itinerary',
      ),
      const _ChatSuggestion(
        Icons.beach_access_rounded,
        'Suggest the best beaches near Hurghada',
      ),
      const _ChatSuggestion(
        Icons.museum_rounded,
        'Create a cultural tour in Luxor',
      ),
      const _ChatSuggestion(
        Icons.restaurant_rounded,
        'Plan a local food tour in Alexandria',
      ),
      const _ChatSuggestion(
        Icons.savings_rounded,
        'Plan a budget-friendly weekend trip',
      ),
      const _ChatSuggestion(
        Icons.hiking_rounded,
        'What are the best adventure activities in Dahab?',
      ),
      const _ChatSuggestion(
        Icons.wb_sunny_rounded,
        'What is the best season to visit Siwa?',
      ),
      const _ChatSuggestion(
        Icons.shopping_bag_rounded,
        'Plan a shopping day in Dubai',
      ),
      const _ChatSuggestion(
        Icons.child_care_rounded,
        'Create a kid-friendly travel plan',
      ),
      const _ChatSuggestion(
        Icons.favorite_rounded,
        'Design a calm honeymoon itinerary',
      ),
      const _ChatSuggestion(
        Icons.backpack_rounded,
        'What should I pack for a desert trip?',
      ),
      const _ChatSuggestion(
        Icons.route_rounded,
        'Compare Dubai and Abu Dhabi for families',
      ),
      const _ChatSuggestion(
        Icons.explore_rounded,
        'Suggest hidden gems away from crowds',
      ),
      const _ChatSuggestion(
        Icons.account_balance_rounded,
        'Make a walking tour for Old Cairo',
      ),
      const _ChatSuggestion(
        Icons.public_rounded,
        'Help me choose a short-break destination',
      ),
    ];
  }

  void _showClearConfirmation() {
    final isDark = _isDark(context);
    final cubit = context.read<ChatBotCubit>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
        title: Text(context.l10n.chatbotClearTitle,
            style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: Text(
          context.l10n.chatbotClearMessage,
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.commonCancel,
                style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600])),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await cubit.discardContext();
            },
            child: Text(context.l10n.commonDelete,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ChatSuggestion {
  const _ChatSuggestion(this.icon, this.text);

  final IconData icon;
  final String text;
}

class _SuggestionPromptCard extends StatelessWidget {
  const _SuggestionPromptCard({
    required this.suggestion,
    required this.isDark,
    required this.onTap,
  });

  final _ChatSuggestion suggestion;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        isDark ? const Color(0xFF242424) : const Color(0xFFFFFFFF);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.grey.withValues(alpha: 0.22);
    final textColor =
        isDark ? Colors.white.withValues(alpha: 0.9) : ThemeColor.charcoalColor;
    final iconBackgroundColor =
        ThemeColor.primaryColor.withValues(alpha: isDark ? 0.2 : 0.14);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Ink(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  suggestion.icon,
                  color: ThemeColor.primaryColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  suggestion.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Icon(
                Icons.arrow_forward_rounded,
                color: ThemeColor.primaryColor,
                size: 19.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
