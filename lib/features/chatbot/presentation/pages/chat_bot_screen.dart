import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/features/chatbot/presentation/cubit/chat_bot_cubit.dart';
import 'package:rahhala_app/features/chatbot/presentation/cubit/chat_bot_state.dart';
import 'package:rahhala_app/features/chatbot/presentation/widgets/chat_bubble.dart';

import 'package:rahhala_app/features/chatbot/presentation/widgets/typing_indicator.dart';
import 'package:rahhala_app/features/chatbot/presentation/widgets/chat_input_field.dart';

class ChatBotScreen extends StatelessWidget {
  const ChatBotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChatBotCubit>(),
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
                    alignment: Alignment.centerLeft,
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
            'ANIS',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'Your AI travel assistant',
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
          padding: EdgeInsets.only(right: 12.w),
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
    final suggestions = [
      "Plan a trip to Dubai",
      "What are the best hotels in Mecca?",
      "Suggest family-friendly entertainment places"
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 60.h, horizontal: 30.w),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(25.r),
              decoration: BoxDecoration(
                color: ThemeColor.primaryColor
                    .withValues(alpha: isDark ? 0.15 : 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy_outlined,
                size: 70.sp,
                color: ThemeColor.primaryColor,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Welcome to ANIS!',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'I am here to help you plan your next trip. Try one of the suggestions below:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            SizedBox(height: 30.h),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: suggestions
                  .map((text) => ActionChip(
                        label: Text(text,
                            style: TextStyle(
                                color:
                                    isDark ? Colors.white70 : Colors.black87)),
                        backgroundColor:
                            isDark ? const Color(0xFF2C2C2C) : Colors.white,
                        shape: StadiumBorder(
                          side: BorderSide(
                              color: isDark
                                  ? Colors.white12
                                  : Colors.grey.shade300),
                        ),
                        onPressed: () => cubit.sendMessage(text),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearConfirmation() {
    final isDark = _isDark(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
        title: Text('Clear Conversation',
            style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: Text(
          'Are you sure you want to delete all messages? This action cannot be undone.',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600])),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r)),
            ),
            onPressed: () {
              context.read<ChatBotCubit>().clearConversation();
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
