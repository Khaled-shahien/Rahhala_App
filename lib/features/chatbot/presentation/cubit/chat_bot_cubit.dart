import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/features/chatbot/domain/entities/chat_message.dart';
import 'package:rahhala_app/features/chatbot/domain/usecases/send_message_usecase.dart';
import 'package:rahhala_app/features/chatbot/domain/usecases/stream_message_usecase.dart';
import 'package:rahhala_app/features/chatbot/domain/usecases/create_context_usecase.dart';
import 'package:rahhala_app/features/chatbot/domain/usecases/update_context_items_usecase.dart';
import 'package:rahhala_app/features/chatbot/domain/usecases/get_context_usecase.dart';
import 'package:rahhala_app/features/chatbot/domain/usecases/discard_context_usecase.dart';
import 'package:rahhala_app/features/chatbot/presentation/cubit/chat_bot_state.dart';

/// Cubit for managing ChatBot state and business logic
/// Handles message sending, streaming, and context management
class ChatBotCubit extends Cubit<ChatBotState> {
  final SendMessageUseCase sendMessageUseCase;
  final StreamMessageUseCase streamMessageUseCase;
  final CreateContextUseCase createContextUseCase;
  final UpdateContextItemsUseCase updateContextItemsUseCase;
  final GetContextUseCase getContextUseCase;
  final DiscardContextUseCase discardContextUseCase;

  String? _currentContextId;
  final List<ChatMessage> _conversationHistory = [];
  bool _isStreaming = false;

  ChatBotCubit({
    required this.sendMessageUseCase,
    required this.streamMessageUseCase,
    required this.createContextUseCase,
    required this.updateContextItemsUseCase,
    required this.getContextUseCase,
    required this.discardContextUseCase,
  }) : super(ChatBotInitial());

  /// Get unmodifiable list of conversation history
  List<ChatMessage> get conversationHistory =>
      List.unmodifiable(_conversationHistory);

  /// Get current context ID if one exists
  String? get currentContextId => _currentContextId;

  /// Check if currently streaming a response
  bool get isStreaming => _isStreaming;

  /// Initialize a new conversation context
  /// Optionally pass initial items to store in the context
  Future<void> initializeContext({Map<String, dynamic>? items}) async {
    try {
      final result = await createContextUseCase(items: items);
      result.fold(
        (failure) {
          // Continue without context on failure
          emit(const ChatBotError(errorMessage: 'Failed to create context'));
        },
        (context) {
          _currentContextId = context.contextId;
          emit(ChatBotContextCreated(contextId: _currentContextId!));
        },
      );
    } catch (e) {
      emit(ChatBotError(errorMessage: e.toString()));
    }
  }

  /// Send a message and receive a complete response (non-streaming)
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
      final result = await sendMessageUseCase(
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
          _addAssistantResponse(response);
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

  /// Send a message and receive a streaming response
  /// Emits [ChatBotStreaming] states with each chunk
  Future<void> streamMessage(String message) async {
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
      _isStreaming = true;
      final buffer = StringBuffer();

      final stream = streamMessageUseCase(
        message: message,
        contextId: _currentContextId,
        conversationHistory: _conversationHistory,
      );

      await for (final chunk in stream) {
        buffer.write(chunk);
        emit(ChatBotStreaming(
          messages: List.unmodifiable(_conversationHistory),
          currentChunk: buffer.toString(),
        ));
      }

      _isStreaming = false;

      // Add complete response to history
      _addAssistantResponse(buffer.toString());
    } catch (e) {
      _isStreaming = false;
      emit(ChatBotError(errorMessage: e.toString()));
      // Remove the failed message from history
      if (_conversationHistory.isNotEmpty &&
          _conversationHistory.last.role == 'user') {
        _conversationHistory.removeLast();
      }
    }
  }

  /// Helper method to add assistant response to history
  void _addAssistantResponse(String response) {
    final assistantMessage = ChatMessage(
      role: 'assistant',
      message: response,
      timestamp: DateTime.now(),
    );
    _conversationHistory.add(assistantMessage);

    emit(ChatBotMessageReceived(
        messages: List.unmodifiable(_conversationHistory)));
  }

  /// Update items in the current context
  Future<void> updateContext(Map<String, dynamic> items) async {
    if (_currentContextId == null) {
      emit(const ChatBotError(errorMessage: 'No active context'));
      return;
    }

    try {
      final result = await updateContextItemsUseCase(
        contextId: _currentContextId!,
        items: items,
      );

      result.fold(
        (failure) {
          emit(ChatBotError(errorMessage: failure.message));
        },
        (success) {
          // Context updated successfully
          // You may want to emit a specific state here
        },
      );
    } catch (e) {
      emit(ChatBotError(errorMessage: e.toString()));
    }
  }

  /// Retrieve and display current context data
  Future<void> loadContext() async {
    if (_currentContextId == null) {
      emit(const ChatBotError(errorMessage: 'No active context'));
      return;
    }

    try {
      final result = await getContextUseCase(contextId: _currentContextId!);

      result.fold(
        (failure) {
          emit(ChatBotError(errorMessage: failure.message));
        },
        (context) {
          // Context loaded successfully
          // You may want to emit a specific state with context data
        },
      );
    } catch (e) {
      emit(ChatBotError(errorMessage: e.toString()));
    }
  }

  /// Clear conversation and reset to initial state
  void clearConversation() {
    _conversationHistory.clear();
    _currentContextId = null;
    _isStreaming = false;
    emit(ChatBotInitial());
  }

  /// Discard current context and clear conversation
  Future<void> discardContext() async {
    if (_currentContextId != null) {
      final result = await discardContextUseCase(contextId: _currentContextId!);
      result.fold(
        (failure) {
          emit(ChatBotError(errorMessage: failure.message));
        },
        (success) {
          // Context discarded successfully
        },
      );
    }
    clearConversation();
  }
}
