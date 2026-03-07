import 'dart:io';
import 'package:dio/dio.dart';

/// Simple ChatBot API Endpoint Verification Script
/// This script tests if the /api/chat endpoint is accessible and working
///
/// Usage: `dart test/chatbot_simple_verification.dart`
void main() async {
  print('\n${'=' * 60}');
  print('CHATBOT API SIMPLE VERIFICATION');
  print('=' * 60 + '\n');

  // Test configuration
  const baseUrl = 'https://express-js-on-vercel-ten-roan-21.vercel.app';
  const endpoint = '/api/chat';
  const fullUrl = '$baseUrl$endpoint';

  print('📍 Testing Endpoint: $fullUrl\n');

  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  try {
    // Test 1: Basic connectivity check
    print('📝 Test 1: Basic Connectivity Check');
    print('-' * 60);

    final basicResponse = await dio.post(
      endpoint,
      data: {'prompt': 'Hello'},
    );

    print('✅ Status Code: ${basicResponse.statusCode}');
    print('✅ Response: ${basicResponse.data}\n');

    if (basicResponse.statusCode == 200) {
      print('✅ Endpoint is accessible!\n');
    } else {
      print('⚠️ Endpoint returned status code: ${basicResponse.statusCode}\n');
    }

    // Test 2: Standard chat action
    print('📝 Test 2: Standard Chat Action');
    print('-' * 60);

    final chatResponse = await dio.post(
      endpoint,
      data: {
        'action': 'chat',
        'payload': {
          'prompt': 'Hello, I want to visit Dubai!',
          'conversationHistory': []
        }
      },
    );

    print('✅ Status Code: ${chatResponse.statusCode}');
    print('✅ Success: ${chatResponse.data['success']}');
    if (chatResponse.data['result'] != null &&
        chatResponse.data['result']['response'] != null) {
      print('✅ Response: ${chatResponse.data['result']['response']}');
    }
    print('');

    // Test 3: Create context
    print('📝 Test 3: Create Context');
    print('-' * 60);

    final createContextResponse = await dio.post(
      endpoint,
      data: {
        'action': 'create-context',
        'payload': {
          'items': {
            'userParams': {'value': 'Test user'}
          }
        }
      },
    );

    String? contextId = createContextResponse.data['result']?['contextId'];
    print('✅ Status Code: ${createContextResponse.statusCode}');
    print('✅ Context ID: $contextId\n');

    if (contextId != null) {
      // Test 4: Get context
      print('📝 Test 4: Get Context');
      print('-' * 60);

      final getContextResponse = await dio.post(
        endpoint,
        data: {
          'action': 'get-context',
          'payload': {'contextId': contextId}
        },
      );

      print('✅ Status Code: ${getContextResponse.statusCode}');
      print('✅ Context Data: ${getContextResponse.data['result']}\n');

      // Test 5: Discard context
      print('📝 Test 5: Discard Context');
      print('-' * 60);

      final discardResponse = await dio.post(
        endpoint,
        data: {
          'action': 'discard-context',
          'payload': {'contextId': contextId}
        },
      );

      print('✅ Status Code: ${discardResponse.statusCode}');
      print('✅ Context discarded successfully\n');
    }

    print('=' * 60);
    print('🎉 ALL TESTS COMPLETED SUCCESSFULLY!');
    print('=' * 60 + '\n');
  } on DioException catch (e) {
    print('\n❌ REQUEST FAILED!');
    print('-' * 60);
    print('Error Type: ${e.type}');
    print('Status Code: ${e.response?.statusCode ?? "N/A"}');
    print('Error Message: ${e.message}');

    if (e.response != null) {
      print('Response Data: ${e.response?.data}');
      print('Response Headers: ${e.response?.headers}');
    }

    print('\n💡 TROUBLESHOOTING STEPS:');
    print('-' * 60);

    if (e.type == DioExceptionType.badResponse &&
        e.response?.statusCode == 404) {
      print('1. ⚠️  Endpoint not found (404)');
      print('   - Verify the endpoint URL is correct: $fullUrl');
      print('   - Check if the backend API is deployed correctly');
      print('   - Contact backend team to confirm endpoint exists');
    } else if (e.type == DioExceptionType.connectionTimeout) {
      print('1. ⚠️  Connection timeout');
      print('   - Check your internet connection');
      print('   - Verify the server is running');
      print('   - Try increasing timeout duration');
    } else if (e.type == DioExceptionType.badResponse &&
        e.response?.statusCode == 401) {
      print('1. ⚠️  Unauthorized (401)');
      print('   - The endpoint may require authentication');
      print('   - Check if token needs to be added to headers');
      print('   - Verify token is valid and not expired');
    } else if (e.type == DioExceptionType.badResponse &&
        e.response?.statusCode == 503) {
      print('1. ⚠️  Service Unavailable (503)');
      print('   - Backend server may be down or overloaded');
      print('   - Try again later');
      print('   - Contact backend team');
    } else {
      print('1. ⚠️  Network error occurred');
      print('   - Check internet connection');
      print('   - Verify server is accessible');
      print('   - Check firewall/proxy settings');
    }

    print('\n2. 🔍 Additional debugging:');
    print('   - Try opening the URL in browser: $baseUrl');
    print('   - Use Postman to test the endpoint manually');
    print('   - Check server logs for errors');
    print('   - Verify CORS settings if testing from web\n');
  } catch (e) {
    print('\n❌ UNEXPECTED ERROR!');
    print('-' * 60);
    print('Error: $e\n');
    print('Stack Trace:');
    print(StackTrace.current);
  }
}
