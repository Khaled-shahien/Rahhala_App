import 'package:rahhala_app/features/chatbot/domain/entities/chat_message.dart';
import 'package:rahhala_app/features/chatbot/domain/repositories/chat_bot_repository.dart';

/// Use case for sending a chat message and receiving a streaming response
///
/// This use case enables real-time display of AI responses as they are generated,
/// creating a typing effect in the UI.
class StreamMessageUseCase {
  final ChatBotRepository repository;

  StreamMessageUseCase(this.repository);

  /// Execute the stream message use case
  ///
  /// [message] - The user's message text
  /// [contextId] - Optional context/session ID
  /// [conversationHistory] - List of previous messages
  /// Returns a stream of text chunks that can be displayed progressively
  Stream<String> call({
    required String message,
    String? contextId,
    List<ChatMessage>? conversationHistory,
  }) {
    return repository.streamMessage(
      message: message,
      contextId: contextId,
      conversationHistory: conversationHistory,
    );
  }
}
