import 'package:dartz/dartz.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/features/chatbot/domain/entities/chat_context.dart';
import 'package:rahhala_app/features/chatbot/domain/repositories/chat_bot_repository.dart';

/// Use case for retrieving an existing conversation context
///
/// This use case fetches the stored data for a specific context session,
/// allowing the AI to access previously stored user information.
class GetContextUseCase {
  final ChatBotRepository repository;

  GetContextUseCase(this.repository);

  /// Execute the get context use case
  ///
  /// [contextId] - The ID of the context to retrieve
  /// Returns either a [ChatContext] on success or a [Failure] on error
  Future<Either<Failure, ChatContext>> call({
    required String contextId,
  }) {
    return repository.getContext(contextId: contextId);
  }
}
