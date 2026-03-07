import 'package:dartz/dartz.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/features/chatbot/domain/repositories/chat_bot_repository.dart';

/// Use case for discarding/deleting an existing conversation context
///
/// This use case removes a context session and all its stored data,
/// effectively ending the conversation session.
class DiscardContextUseCase {
  final ChatBotRepository repository;

  DiscardContextUseCase(this.repository);

  /// Execute the discard context use case
  ///
  /// [contextId] - The ID of the context to delete
  /// Returns true on success or a [Failure] on error
  Future<Either<Failure, bool>> call({
    required String contextId,
  }) {
    return repository.discardContext(contextId: contextId);
  }
}
