import 'package:dartz/dartz.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/features/chatbot/domain/entities/chat_context.dart';
import 'package:rahhala_app/features/chatbot/domain/repositories/chat_bot_repository.dart';

/// Use case for creating a new conversation context
///
/// This use case calls the repository to create a new context session
/// with optional initial items (user preferences, location, etc.)
class CreateContextUseCase {
  final ChatBotRepository repository;

  CreateContextUseCase(this.repository);

  /// Execute the create context use case
  ///
  /// [items] - Optional initial items to store in the context
  /// Returns either a [ChatContext] on success or a [Failure] on error
  Future<Either<Failure, ChatContext>> call({
    Map<String, dynamic>? items,
  }) {
    return repository.createContext(items: items);
  }
}
