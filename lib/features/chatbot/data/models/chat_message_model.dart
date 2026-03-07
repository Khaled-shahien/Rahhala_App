import 'package:rahhala_app/features/chatbot/domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.role,
    required super.message,
    super.timestamp,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      role: json['role'] ?? 'user',
      message: json['message'] ?? '',
      timestamp:
          json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'message': message,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    };
  }
}
