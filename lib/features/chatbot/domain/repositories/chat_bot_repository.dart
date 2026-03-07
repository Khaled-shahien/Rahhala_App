import 'package:dartz/dartz.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/features/chatbot/domain/entities/chat_message.dart';
import 'package:rahhala_app/features/chatbot/domain/entities/chat_context.dart';

/// Repository interface for ChatBot operations
/// Defines the contract for all repository implementations
abstract class ChatBotRepository {
  /// Send a chat message and receive a response
  Future<Either<Failure, String>> sendMessage({
    required String message,
    String? contextId,
    List<ChatMessage>? conversationHistory,
  });

  /// Send a chat message and receive a streaming response
  Stream<String> streamMessage({
    required String message,
    String? contextId,
    List<ChatMessage>? conversationHistory,
  });

  /// Create a new conversation context
  Future<Either<Failure, ChatContext>> createContext({
    Map<String, dynamic>? items,
  });

  /// Update items in an existing context
  Future<Either<Failure, bool>> updateContextItems({
    required String contextId,
    required Map<String, dynamic> items,
  });

  /// Retrieve an existing context by ID
  Future<Either<Failure, ChatContext>> getContext({
    required String contextId,
  });

  /// Discard/delete an existing context
  Future<Either<Failure, bool>> discardContext({
    required String contextId,
  });
}
