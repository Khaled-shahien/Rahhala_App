import 'package:dartz/dartz.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/features/chatbot/domain/entities/chat_message.dart';
import 'package:rahhala_app/features/chatbot/domain/entities/chat_context.dart';

abstract class ChatBotRepository {
  Future<Either<Failure, String>> sendMessage({
    required String message,
    String? contextId,
    List<ChatMessage>? conversationHistory,
  });

  Future<Either<Failure, ChatContext>> createContext();

  Future<Either<Failure, bool>> discardContext(String contextId);
}
