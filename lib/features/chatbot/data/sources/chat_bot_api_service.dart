import 'package:dio/dio.dart';
import 'package:rahhala_app/core/network/end_points.dart';
import 'package:rahhala_app/features/chatbot/domain/entities/chat_message.dart';

class ChatBotApiService {
  final Dio dio;

  ChatBotApiService({required this.dio});

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
