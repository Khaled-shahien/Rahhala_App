import 'package:dartz/dartz.dart';
import 'package:rahhala_app/core/errors/exceptions.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/core/network/api_consumer.dart';
import 'package:rahhala_app/features/chatbot/data/sources/chat_bot_api_service.dart';
import 'package:rahhala_app/features/chatbot/domain/entities/chat_context.dart';
import 'package:rahhala_app/features/chatbot/domain/entities/chat_message.dart';
import 'package:rahhala_app/features/chatbot/domain/repositories/chat_bot_repository.dart';

class ChatBotRepositoryImpl implements ChatBotRepository {
  final ChatBotApiService apiService;
  final ApiConsumer apiConsumer;

  ChatBotRepositoryImpl({
    required this.apiService,
    required this.apiConsumer,
  });

  @override
  Future<Either<Failure, String>> sendMessage({
    required String message,
    String? contextId,
    List<ChatMessage>? conversationHistory,
  }) async {
    try {
      final response = await apiService.sendMessage(
        message: message,
        contextId: contextId,
        conversationHistory: conversationHistory,
      );

      if (response['success'] == true || response['success'] == 'true') {
        final result = response['result'];
        if (result != null && result['response'] != null) {
          return Right(result['response'].toString());
        }
        return Left(
            ServerFailure(message: 'Invalid response format from server'));
      } else {
        final errorMsg = response['message'] ??
            response['Message'] ??
            response['error'] ??
            'Failed to get response';
        return Left(ServerFailure(message: errorMsg.toString()));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.errorModel.message));
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatContext>> createContext() async {
    try {
      // For now, we'll generate a local context ID
      // In the future, this can call the API to create a context
      final contextId = DateTime.now().millisecondsSinceEpoch.toString();
      final context = ChatContext(
        contextId: contextId,
        createdAt: DateTime.now(),
      );
      return Right(context);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> discardContext(String contextId) async {
    try {
      // TODO: Implement API call to discard context when backend supports it
      // For now, just return success
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
