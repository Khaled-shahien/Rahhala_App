import 'package:rahhala_app/features/chatbot/domain/entities/chat_context.dart';

class ChatContextModel extends ChatContext {
  const ChatContextModel({
    required super.contextId,
    super.title,
    required super.createdAt,
  });

  factory ChatContextModel.fromJson(Map<String, dynamic> json) {
    return ChatContextModel(
      contextId: json['contextId'] ?? '',
      title: json['title'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'contextId': contextId,
      if (title != null) 'title': title,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
