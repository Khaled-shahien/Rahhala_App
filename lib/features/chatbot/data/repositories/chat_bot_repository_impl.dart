import 'package:dartz/dartz.dart';
import 'package:rahhala_app/core/errors/exceptions.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/features/chatbot/data/sources/chat_bot_api_service.dart';
import 'package:rahhala_app/features/chatbot/domain/entities/chat_context.dart';
import 'package:rahhala_app/features/chatbot/domain/entities/chat_message.dart';
import 'package:rahhala_app/features/chatbot/domain/repositories/chat_bot_repository.dart';

/// Implementation of [ChatBotRepository]
/// Handles all data operations for the chatbot feature
class ChatBotRepositoryImpl implements ChatBotRepository {
  final ChatBotApiService apiService;

  ChatBotRepositoryImpl({
    required this.apiService,
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
  Stream<String> streamMessage({
    required String message,
    String? contextId,
    List<ChatMessage>? conversationHistory,
  }) {
    return apiService.streamMessage(
      message: message,
      contextId: contextId,
      conversationHistory: conversationHistory,
    );
  }

  @override
  Future<Either<Failure, ChatContext>> createContext({
    Map<String, dynamic>? items,
  }) async {
    try {
      final response = await apiService.createContext(items: items);

      if (response['result'] != null &&
          response['result']['contextId'] != null) {
        final contextId = response['result']['contextId'].toString();
        final context = ChatContext(
          contextId: contextId,
          createdAt: DateTime.now(),
        );
        return Right(context);
      } else {
        return Left(ServerFailure(
            message: 'Failed to create context: No context ID returned'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.errorModel.message));
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateContextItems({
    required String contextId,
    required Map<String, dynamic> items,
  }) async {
    try {
      final response = await apiService.updateContextItems(
        contextId: contextId,
        items: items,
      );

      if (response['success'] == true || response['success'] == 'true') {
        return const Right(true);
      } else {
        final errorMsg = response['message'] ??
            response['Message'] ??
            response['error'] ??
            'Failed to update context items';
        return Left(ServerFailure(message: errorMsg.toString()));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.errorModel.message));
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatContext>> getContext({
    required String contextId,
  }) async {
    try {
      final response = await apiService.getContext(contextId: contextId);

      if (response['success'] == true || response['success'] == 'true') {
        final result = response['result'];
        if (result != null) {
          // Parse context data from response
          final contextData = result['items'] ?? result;
          final context = ChatContext(
            contextId: contextId,
            title: null, // Title may not be provided by API
            createdAt: DateTime.now(),
          );
          return Right(context);
        }
        return Left(
            ServerFailure(message: 'Invalid response format from server'));
      } else {
        final errorMsg = response['message'] ??
            response['Message'] ??
            response['error'] ??
            'Failed to get context';
        return Left(ServerFailure(message: errorMsg.toString()));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.errorModel.message));
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> discardContext({
    required String contextId,
  }) async {
    try {
      final response = await apiService.discardContext(contextId: contextId);

      if (response['success'] == true || response['success'] == 'true') {
        return const Right(true);
      } else {
        final errorMsg = response['message'] ??
            response['Message'] ??
            response['error'] ??
            'Failed to discard context';
        return Left(ServerFailure(message: errorMsg.toString()));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.errorModel.message));
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
