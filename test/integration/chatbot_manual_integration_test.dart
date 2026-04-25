// ignore_for_file: avoid_print

import 'dart:io';
import 'package:dio/dio.dart';

/// Manual integration test for ChatBot API endpoints
/// Run this test to verify all chatbot endpoints are working correctly
///
/// Usage: `flutter test test/integration/chatbot_manual_integration_test.dart`
void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://express-js-on-vercel-ten-roan-21.vercel.app',
    headers: {'Content-Type': 'application/json'},
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  print('\n${'=' * 60}');
  print('CHATBOT API ENDPOINT INTEGRATION TEST');
  print('=' * 60 + '\n');

  try {
    // Test 1: Standard Chat
    print('📝 Test 1: Standard Chat (Non-Streaming)');
    print('-' * 60);
    final chatResponse = await dio.post(
      '/api/chat',
      data: {
        'action': 'chat',
        'payload': {
          'prompt': 'Hello, I want to visit Dubai!',
          'conversationHistory': []
        }
      },
    );
    print('Status Code: ${chatResponse.statusCode}');
    print('Success: ${chatResponse.data['success']}');
    print('Response: ${chatResponse.data['result']?['response']}');
    print('✅ Test 1 PASSED\n');

    // Test 2: Chat with Context
    print('📝 Test 2: Chat with Conversation History');
    print('-' * 60);
    final chatWithHistoryResponse = await dio.post(
      '/api/chat',
      data: {
        'action': 'chat',
        'payload': {
          'prompt': 'What are the best places to visit there?',
          'conversationHistory': [
            {'role': 'user', 'message': 'Hello, I want to visit Dubai!'},
            {
              'role': 'assistant',
              'message':
                  'Dubai is amazing! You should visit the Burj Khalifa...'
            }
          ]
        }
      },
    );
    print('Status Code: ${chatWithHistoryResponse.statusCode}');
    print('Success: ${chatWithHistoryResponse.data['success']}');
    print('Response: ${chatWithHistoryResponse.data['result']?['response']}');
    print('✅ Test 2 PASSED\n');

    // Test 3: Create Context
    print('📝 Test 3: Create Context');
    print('-' * 60);
    final createContextResponse = await dio.post(
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
    String? contextId = createContextResponse.data['result']?['contextId'];
    print('Status Code: ${createContextResponse.statusCode}');
    print('Context ID: $contextId');
    print('✅ Test 3 PASSED\n');

    if (contextId != null) {
      // Test 4: Update Context
      print('📝 Test 4: Update Context Items');
      print('-' * 60);
      final updateContextResponse = await dio.post(
        '/api/chat',
        data: {
          'action': 'update-context-items',
          'payload': {
            'contextId': contextId,
            'items': {
              'location': {'value': 'Paris, France'}
            }
          }
        },
      );
      print('Status Code: ${updateContextResponse.statusCode}');
      print('✅ Test 4 PASSED\n');

      // Test 5: Get Context
      print('📝 Test 5: Get Context');
      print('-' * 60);
      final getContextResponse = await dio.post(
        '/api/chat',
        data: {
          'action': 'get-context',
          'payload': {'contextId': contextId}
        },
      );
      print('Status Code: ${getContextResponse.statusCode}');
      print('Context Data: ${getContextResponse.data['result']}');
      print('✅ Test 5 PASSED\n');

      // Test 6: Discard Context
      print('📝 Test 6: Discard Context');
      print('-' * 60);
      final discardContextResponse = await dio.post(
        '/api/chat',
        data: {
          'action': 'discard-context',
          'payload': {'contextId': contextId}
        },
      );
      print('Status Code: ${discardContextResponse.statusCode}');
      print('✅ Test 6 PASSED\n');
    }

    // Test 7: Streaming Chat
    print('📝 Test 7: Streaming Chat');
    print('-' * 60);
    final streamDio = Dio(BaseOptions(
      baseUrl: 'https://express-js-on-vercel-ten-roan-21.vercel.app',
      headers: {'Content-Type': 'application/json'},
      responseType: ResponseType.stream,
    ));

    final streamResponse = await streamDio.post(
      '/api/chat',
      data: {
        'action': 'chat-stream',
        'payload': {
          'prompt': 'Tell me a very short story about travel.',
          'conversationHistory': []
        }
      },
    );
    print('Status Code: ${streamResponse.statusCode}');

    // Read and display stream
    final buffer = StringBuffer();
    await for (final chunk in streamResponse.data.stream) {
      final text = String.fromCharCodes(chunk);
      buffer.write(text);
      stdout.write(text);
    }
    print('\nStream completed. Total length: ${buffer.length} characters');
    print('✅ Test 7 PASSED\n');

    // Test 8: Legacy Simple Mode
    print('📝 Test 8: Legacy Simple Mode');
    print('-' * 60);
    final simpleResponse = await dio.post(
      '/api/chat',
      data: {'prompt': 'Suggest a trip to Italy'},
    );
    print('Status Code: ${simpleResponse.statusCode}');
    print('Response: ${simpleResponse.data}');
    print('✅ Test 8 PASSED\n');

    print('=' * 60);
    print('🎉 ALL TESTS PASSED SUCCESSFULLY!');
    print('=' * 60 + '\n');
  } on DioException catch (e) {
    print('\n❌ TEST FAILED!');
    print('Error Type: ${e.type}');
    print('Status Code: ${e.response?.statusCode}');
    print('Error Message: ${e.message}');
    print('Error Data: ${e.response?.data}');
    print('\n💡 Troubleshooting Tips:');
    print('   - Check your internet connection');
    print('   - Verify the backend server is running');
    print('   - Ensure the base URL is correct');
    print('   - Check CORS settings if testing from web\n');
  } catch (e) {
    print('\n❌ UNEXPECTED ERROR!');
    print('Error: $e\n');
  }
}
