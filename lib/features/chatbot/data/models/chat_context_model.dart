import 'package:equatable/equatable.dart';
import 'package:rahhala_app/features/chatbot/domain/entities/chat_context.dart';

/// Data model for [ChatContext] entity
/// Used for JSON serialization/deserialization in data layer
class ChatContextModel extends Equatable {
  final String contextId;
  final String? title;
  final DateTime createdAt;
  final Map<String, dynamic>? items;

  const ChatContextModel({
    required this.contextId,
    this.title,
    required this.createdAt,
    this.items,
  });

  /// Convert from domain entity to model
  factory ChatContextModel.fromEntity(ChatContext entity) {
    return ChatContextModel(
      contextId: entity.contextId,
      title: entity.title,
      createdAt: entity.createdAt,
    );
  }

  /// Convert from model to domain entity
  ChatContext toEntity() {
    return ChatContext(
      contextId: contextId,
      title: title,
      createdAt: createdAt,
    );
  }

  /// Create model from JSON
  factory ChatContextModel.fromJson(Map<String, dynamic> json) {
    return ChatContextModel(
      contextId: json['contextId'] ?? '',
      title: json['title'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      items: json['items'] != null
          ? Map<String, dynamic>.from(json['items'])
          : null,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'contextId': contextId,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      if (items != null) 'items': items!,
    };
  }

  @override
  List<Object?> get props => [contextId, title, createdAt, items];
}
