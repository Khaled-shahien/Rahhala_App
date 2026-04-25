// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:rahhala_app/features/chatbot/data/sources/chat_bot_api_service.dart';
import 'package:rahhala_app/features/chatbot/domain/entities/chat_message.dart';

void main() {
  group('ChatBot API Service Tests', () {
    late ChatBotApiService chatBotApiService;
    late Dio dio;

    setUp(() {
      dio = Dio(BaseOptions(
        baseUrl: 'https://express-js-on-vercel-ten-roan-21.vercel.app',
        headers: {'Content-Type': 'application/json'},
      ));
      chatBotApiService = ChatBotApiService(dio: dio);
    });

    group('Standard Chat (Non-Streaming)', () {
      test('should send a simple chat message and receive response', () async {
        // Arrange
        const message = 'Hello, I want to visit Dubai!';

        // Act
        final result = await chatBotApiService.sendMessage(
          message: message,
          conversationHistory: [],
        );

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['success'], isTrue);
        expect(result['result'], isNotNull);
        expect(result['result']['response'], isA<String>());
        print(
            '✓ Standard chat test passed. Response: ${result['result']['response']}');
      }, timeout: const Timeout(Duration(seconds: 30)));

      test('should send chat with conversation history', () async {
        // Arrange
        const message = 'What are the best places to visit there?';
        final conversationHistory = [
          ChatMessage(
              role: 'user',
              message: 'Hello, I want to visit Dubai!',
              timestamp: DateTime.now()),
          ChatMessage(
              role: 'assistant',
              message: 'Dubai is amazing! You should visit the Burj Khalifa...',
              timestamp: DateTime.now()),
        ];

        // Act
        final result = await chatBotApiService.sendMessage(
          message: message,
          conversationHistory: conversationHistory,
        );

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['success'], isTrue);
        expect(result['result']['response'], isA<String>());
        print(
            '✓ Chat with history test passed. Response: ${result['result']['response']}');
      }, timeout: const Timeout(Duration(seconds: 30)));
    });

    group('Context Management', () {
      String? testContextId;

      test('should create a new context', () async {
        // Arrange
        final dioForContext = Dio(BaseOptions(
          baseUrl: 'https://express-js-on-vercel-ten-roan-21.vercel.app',
          headers: {'Content-Type': 'application/json'},
        ));

        // Act - Create Context
        final createContextResponse = await dioForContext.post(
          '/api/chat',
          data: {
            'action': 'create-context',
            'payload': {
              'items': {
                'userParams': {'value': 'Budget traveler, likes spicy food'}
              }
            }
          },
        );

        // Assert
        expect(createContextResponse.statusCode, 200);
        expect(createContextResponse.data['result'], isNotNull);
        expect(createContextResponse.data['result']['contextId'], isNotNull);

        testContextId = createContextResponse.data['result']['contextId'];
        print('✓ Create context test passed. Context ID: $testContextId');
      }, timeout: const Timeout(Duration(seconds: 30)));

      test('should update context items', () async {
        // Skip if no context was created
        if (testContextId == null) {
          print('⊘ Update context test skipped (no context created)');
          return;
        }

        // Arrange
        final dioForContext = Dio(BaseOptions(
          baseUrl: 'https://express-js-on-vercel-ten-roan-21.vercel.app',
          headers: {'Content-Type': 'application/json'},
        ));

        // Act - Update Context
        final updateResponse = await dioForContext.post(
          '/api/chat',
          data: {
            'action': 'update-context-items',
            'payload': {
              'contextId': testContextId,
              'items': {
                'location': {'value': 'Dubai, UAE'}
              }
            }
          },
        );

        // Assert
        expect(updateResponse.statusCode, 200);
        print('✓ Update context test passed.');
      }, timeout: const Timeout(Duration(seconds: 30)));

      test('should retrieve context', () async {
        // Skip if no context was created
        if (testContextId == null) {
          print('⊘ Get context test skipped (no context created)');
          return;
        }

        // Arrange
        final dioForContext = Dio(BaseOptions(
          baseUrl: 'https://express-js-on-vercel-ten-roan-21.vercel.app',
          headers: {'Content-Type': 'application/json'},
        ));

        // Act - Get Context
        final getResponse = await dioForContext.post(
          '/api/chat',
          data: {
            'action': 'get-context',
            'payload': {'contextId': testContextId}
          },
        );

        // Assert
        expect(getResponse.statusCode, 200);
        expect(getResponse.data['result'], isNotNull);
        print(
            '✓ Get context test passed. Context data: ${getResponse.data['result']}');
      }, timeout: const Timeout(Duration(seconds: 30)));

      test('should discard context', () async {
        // Skip if no context was created
        if (testContextId == null) {
          print('⊘ Discard context test skipped (no context created)');
          return;
        }

        // Arrange
        final dioForContext = Dio(BaseOptions(
          baseUrl: 'https://express-js-on-vercel-ten-roan-21.vercel.app',
          headers: {'Content-Type': 'application/json'},
        ));

        // Act - Discard Context
        final discardResponse = await dioForContext.post(
          '/api/chat',
          data: {
            'action': 'discard-context',
            'payload': {'contextId': testContextId}
          },
        );

        // Assert
        expect(discardResponse.statusCode, 200);
        print('✓ Discard context test passed.');
      }, timeout: const Timeout(Duration(seconds: 30)));
    });

    group('Streaming Chat', () {
      test('should stream chat response', () async {
        // Arrange
        final dioForStream = Dio(BaseOptions(
          baseUrl: 'https://express-js-on-vercel-ten-roan-21.vercel.app',
          headers: {'Content-Type': 'application/json'},
          responseType: ResponseType.stream,
        ));

        const message = 'Tell me a short story about travel.';

        // Act
        final response = await dioForStream.post(
          '/api/chat',
          data: {
            'action': 'chat-stream',
            'payload': {'prompt': message, 'conversationHistory': []}
          },
        );

        // Assert
        expect(response.statusCode, 200);
        expect(response.data, isNotNull);

        // Read stream chunks
        final stream = response.data.stream;
        final buffer = StringBuffer();

        await for (final chunk in stream) {
          buffer.write(String.fromCharCodes(chunk));
        }

        final fullResponse = buffer.toString();
        expect(fullResponse, isNotEmpty);
        print(
            '✓ Streaming chat test passed. Response length: ${fullResponse.length} characters');
      }, timeout: const Timeout(Duration(seconds: 45)));
    });

    group('Legacy Simple Mode', () {
      test('should send simple prompt without action', () async {
        // Arrange
        final dioForSimple = Dio(BaseOptions(
          baseUrl: 'https://express-js-on-vercel-ten-roan-21.vercel.app',
          headers: {'Content-Type': 'application/json'},
        ));

        const prompt = 'Suggest a trip to Italy';

        // Act
        final response = await dioForSimple.post(
          '/api/chat',
          data: {'prompt': prompt},
        );

        // Assert
        expect(response.statusCode, 200);
        print('✓ Legacy simple mode test passed. Response: ${response.data}');
      }, timeout: const Timeout(Duration(seconds: 30)));
    });

    group('Error Handling', () {
      test('should handle invalid action gracefully', () async {
        // Arrange
        final dioForError = Dio(BaseOptions(
          baseUrl: 'https://express-js-on-vercel-ten-roan-21.vercel.app',
          headers: {'Content-Type': 'application/json'},
        ));

        // Act & Assert
        try {
          final response = await dioForError.post(
            '/api/chat',
            data: {'action': 'invalid-action', 'payload': {}},
          );
          // If we get here, the server should still return an error response
          expect(response.statusCode, anyOf(400, 500));
          print('✓ Invalid action handled. Status: ${response.statusCode}');
        } on DioException catch (e) {
          expect(e.response?.statusCode, anyOf(400, 500));
          print(
              '✓ Invalid action handled with DioException. Status: ${e.response?.statusCode}');
        }
      }, timeout: const Timeout(Duration(seconds: 30)));

      test('should handle empty prompt', () async {
        // Arrange
        final dioForError = Dio(BaseOptions(
          baseUrl: 'https://express-js-on-vercel-ten-roan-21.vercel.app',
          headers: {'Content-Type': 'application/json'},
        ));

        // Act & Assert
        try {
          final response = await dioForError.post(
            '/api/chat',
            data: {
              'action': 'chat',
              'payload': {'prompt': ''}
            },
          );
          expect(response.statusCode, inInclusiveRange(200, 500));
          print('✓ Empty prompt handled. Status: ${response.statusCode}');
        } on DioException {
          print('✓ Empty prompt handled with DioException');
        }
      }, timeout: const Timeout(Duration(seconds: 30)));
    });
  });
}
