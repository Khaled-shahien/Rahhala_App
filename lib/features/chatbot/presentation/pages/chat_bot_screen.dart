import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/features/chatbot/presentation/cubit/chat_bot_cubit.dart';
import 'package:rahhala_app/features/chatbot/presentation/cubit/chat_bot_state.dart';
import 'package:rahhala_app/features/chatbot/presentation/widgets/chat_bubble.dart';
import 'package:rahhala_app/features/chatbot/presentation/widgets/chat_input_field.dart';
import 'package:rahhala_app/features/chatbot/presentation/widgets/typing_indicator.dart';

class ChatBotScreen extends StatelessWidget {
  const ChatBotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChatBotCubit>(),
      child: Builder(
        builder: (innerContext) {
          return const _ChatBotScreenContent();
        },
      ),
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
    // Initialize context when screen loads
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
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        try {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } catch (e) {
          // Ignore scroll errors
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: ThemeColor.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.smart_toy_outlined,
                color: ThemeColor.primaryColor,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: ThemeColor.charcoalColor,
                  ),
                ),
                Text(
                  'Always here to help',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: ThemeColor.neutralGrayColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all_outlined, color: Colors.black54),
            onPressed: () {
              _showClearConfirmation();
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined,
              color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<ChatBotCubit, ChatBotState>(
        listener: (context, state) {
          if (state is ChatBotMessageSent ||
              state is ChatBotMessageReceived ||
              state is ChatBotError) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          final cubit = context.read<ChatBotCubit>();
          final messages = cubit.conversationHistory;

          return Column(
            children: [
              // Messages List
              Expanded(
                child: messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 16.h),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          return ChatBubble(
                            message: message.message,
                            isUser: message.role == 'user',
                            timestamp: message.timestamp,
                          );
                        },
                      ),
              ),

              // Typing Indicator
              if (state is ChatBotLoading)
                const Padding(
                  padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
                  child: TypingIndicator(),
                ),

              // Error Message
              if (state is ChatBotError)
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: Colors.red.shade700, size: 20.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          state.errorMessage,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Input Field
              ChatInputField(
                controller: _messageController,
                onSend: (message) {
                  cubit.sendMessage(message);
                  _messageController.clear();
                },
                isLoading: state is ChatBotLoading,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32.r),
            decoration: BoxDecoration(
              color: ThemeColor.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy_outlined,
              size: 80.sp,
              color: ThemeColor.primaryColor,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Hello! How can I help you today?',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: ThemeColor.charcoalColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'Ask me anything about your travel plans',
            style: TextStyle(
              fontSize: 14.sp,
              color: ThemeColor.neutralGrayColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Conversation'),
        content: const Text(
            'Are you sure you want to clear this conversation? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ChatBotCubit>().clearConversation();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
