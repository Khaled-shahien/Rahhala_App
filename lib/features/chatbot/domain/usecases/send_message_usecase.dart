import 'package:dartz/dartz.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/features/chatbot/domain/entities/chat_message.dart';
import 'package:rahhala_app/features/chatbot/domain/repositories/chat_bot_repository.dart';

class SendMessageUseCase {
  final ChatBotRepository repository;

  SendMessageUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String message,
    String? contextId,
    List<ChatMessage>? conversationHistory,
  }) {
    return repository.sendMessage(
      message: message,
      contextId: contextId,
      conversationHistory: conversationHistory,
    );
  }
}
