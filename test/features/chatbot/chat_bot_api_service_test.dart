import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rahhala_app/features/chatbot/data/sources/chat_bot_api_service.dart';

/// Streams a fixed list of byte chunks as the response body.
class _ChunkedAdapter implements HttpClientAdapter {
  _ChunkedAdapter(this.chunks);

  final List<List<int>> chunks;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody(
      Stream<Uint8List>.fromIterable(chunks.map(Uint8List.fromList)),
      200,
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('streamed Arabic text survives chunks split mid-character', () async {
    const reply = 'مرحباً بك في رحّالة';
    final bytes = utf8.encode(reply);
    // Split inside a multi-byte character (Arabic letters are 2 bytes).
    final chunks = [bytes.sublist(0, 3), bytes.sublist(3, 9), bytes.sublist(9)];

    final dio = Dio(BaseOptions(baseUrl: 'https://chat.example.com'))
      ..httpClientAdapter = _ChunkedAdapter(chunks);
    final service = ChatBotApiService(dio: dio);

    final text = await service.streamMessage(message: 'hi').join();

    expect(text, reply);
  });
}
