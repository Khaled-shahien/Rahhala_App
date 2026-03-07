import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/features/chatbot/domain/entities/chat_message.dart';
import 'package:rahhala_app/features/chatbot/domain/repositories/chat_bot_repository.dart';
import 'package:rahhala_app/features/chatbot/presentation/cubit/chat_bot_state.dart';

class ChatBotCubit extends Cubit<ChatBotState> {
  final ChatBotRepository repository;

  String? _currentContextId;
  final List<ChatMessage> _conversationHistory = [];

  ChatBotCubit({required this.repository}) : super(ChatBotInitial());

  List<ChatMessage> get conversationHistory =>
      List.unmodifiable(_conversationHistory);

  String? get currentContextId => _currentContextId;

  Future<void> initializeContext() async {
    try {
      final result = await repository.createContext();
      result.fold(
        (failure) {
          // Continue without context
        },
        (context) {
          _currentContextId = context.contextId;
          emit(ChatBotContextCreated(contextId: _currentContextId!));
        },
      );
    } catch (e) {
      // Continue without context
    }
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    emit(ChatBotLoading());

    // Add user message to history
    final userMessage = ChatMessage(
      role: 'user',
      message: message,
      timestamp: DateTime.now(),
    );
    _conversationHistory.add(userMessage);

    emit(ChatBotMessageSent(messages: List.unmodifiable(_conversationHistory)));

    try {
      final result = await repository.sendMessage(
        message: message,
        contextId: _currentContextId,
        conversationHistory: _conversationHistory,
      );

      result.fold(
        (failure) {
          emit(ChatBotError(errorMessage: failure.message));
          // Remove the failed message from history
          _conversationHistory.removeLast();
        },
        (response) {
          // Add assistant response to history
          final assistantMessage = ChatMessage(
            role: 'assistant',
            message: response,
            timestamp: DateTime.now(),
          );
          _conversationHistory.add(assistantMessage);

          emit(ChatBotMessageReceived(
              messages: List.unmodifiable(_conversationHistory)));
        },
      );
    } catch (e) {
      emit(ChatBotError(errorMessage: e.toString()));
      // Remove the failed message from history
      if (_conversationHistory.isNotEmpty &&
          _conversationHistory.last.role == 'user') {
        _conversationHistory.removeLast();
      }
    }
  }

  void clearConversation() {
    _conversationHistory.clear();
    _currentContextId = null;
    emit(ChatBotInitial());
  }

  Future<void> discardContext() async {
    if (_currentContextId != null) {
      await repository.discardContext(_currentContextId!);
    }
    clearConversation();
  }
}
