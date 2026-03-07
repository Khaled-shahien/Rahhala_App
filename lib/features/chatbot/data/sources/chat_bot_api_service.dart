import 'package:dio/dio.dart';
import 'package:rahhala_app/core/network/end_points.dart';
import 'package:rahhala_app/features/chatbot/domain/entities/chat_message.dart';

/// Remote data source for ChatBot API operations
/// Handles all HTTP requests to the chatbot backend
class ChatBotApiService {
  final Dio dio;

  ChatBotApiService({required this.dio});

  /// Send a standard chat message and receive a complete response
  ///
  /// [message] - The user's message text
  /// [contextId] - Optional context/session ID for maintaining conversation state
  /// [conversationHistory] - List of previous messages in the conversation
  ///
  /// Returns the complete response from the API
  Future<Map<String, dynamic>> sendMessage({
    required String message,
    String? contextId,
    List<ChatMessage>? conversationHistory,
  }) async {
    try {
      final response = await dio.post(
        EndPoints.chatBot,
        data: {
          'action': 'chat',
          'payload': {
            'prompt': message,
            if (contextId != null) 'contextId': contextId,
            if (conversationHistory != null && conversationHistory.isNotEmpty)
              'conversationHistory':
                  conversationHistory.map((msg) => msg.toJson()).toList(),
          },
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Send a chat message and receive a streaming response
  ///
  /// Returns a stream of text chunks that can be displayed progressively
  Stream<String> streamMessage({
    required String message,
    String? contextId,
    List<ChatMessage>? conversationHistory,
  }) async* {
    try {
      final response = await dio.post(
        EndPoints.chatBot,
        data: {
          'action': 'chat-stream',
          'payload': {
            'prompt': message,
            if (contextId != null) 'contextId': contextId,
            if (conversationHistory != null && conversationHistory.isNotEmpty)
              'conversationHistory':
                  conversationHistory.map((msg) => msg.toJson()).toList(),
          },
        },
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      // Process the stream response
      final stream = response.data.stream as Stream<List<int>>;

      await for (final chunk in stream) {
        final text = String.fromCharCodes(chunk);
        yield text;
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Create a new conversation context/session
  ///
  /// [items] - Optional initial items to store in the context
  ///
  /// Returns the API response containing the generated context ID
  Future<Map<String, dynamic>> createContext({
    Map<String, dynamic>? items,
  }) async {
    try {
      final response = await dio.post(
        EndPoints.chatBot,
        data: {
          'action': 'create-context',
          'payload': {
            if (items != null) 'items': items,
          },
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Update items in an existing context
  ///
  /// [contextId] - The ID of the context to update
  /// [items] - New or updated items to store in the context
  ///
  /// Returns the API response confirming the update
  Future<Map<String, dynamic>> updateContextItems({
    required String contextId,
    required Map<String, dynamic> items,
  }) async {
    try {
      final response = await dio.post(
        EndPoints.chatBot,
        data: {
          'action': 'update-context-items',
          'payload': {
            'contextId': contextId,
            'items': items,
          },
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Retrieve an existing context by ID
  ///
  /// [contextId] - The ID of the context to retrieve
  ///
  /// Returns the API response containing the context data
  Future<Map<String, dynamic>> getContext({
    required String contextId,
  }) async {
    try {
      final response = await dio.post(
        EndPoints.chatBot,
        data: {
          'action': 'get-context',
          'payload': {
            'contextId': contextId,
          },
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Discard/delete an existing context
  ///
  /// [contextId] - The ID of the context to delete
  ///
  /// Returns the API response confirming deletion
  Future<Map<String, dynamic>> discardContext({
    required String contextId,
  }) async {
    try {
      final response = await dio.post(
        EndPoints.chatBot,
        data: {
          'action': 'discard-context',
          'payload': {
            'contextId': contextId,
          },
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handle Dio errors and convert to user-friendly exceptions
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please try again.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return Exception('Unauthorized. Please login again.');
        } else if (statusCode == 503) {
          return Exception(
              'Service temporarily unavailable. Please try again later.');
        }
        return Exception('Server error. Please try again.');
      case DioExceptionType.cancel:
        return Exception('Request was cancelled.');
      default:
        return Exception('Network error. Please check your connection.');
    }
  }
}
