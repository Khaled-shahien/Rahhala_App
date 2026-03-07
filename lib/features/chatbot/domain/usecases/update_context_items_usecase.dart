import 'package:dartz/dartz.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/features/chatbot/domain/repositories/chat_bot_repository.dart';

/// Use case for updating items in an existing conversation context
///
/// This use case allows adding or modifying data stored in a context session,
/// such as user preferences, location, travel dates, etc.
class UpdateContextItemsUseCase {
  final ChatBotRepository repository;

  UpdateContextItemsUseCase(this.repository);

  /// Execute the update context items use case
  ///
  /// [contextId] - The ID of the context to update
  /// [items] - New or updated items to store in the context
  /// Returns true on success or a [Failure] on error
  Future<Either<Failure, bool>> call({
    required String contextId,
    required Map<String, dynamic> items,
  }) {
    return repository.updateContextItems(
      contextId: contextId,
      items: items,
    );
  }
}
