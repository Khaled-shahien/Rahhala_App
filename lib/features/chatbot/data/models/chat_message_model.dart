import 'package:equatable/equatable.dart';
import 'package:rahhala_app/features/chatbot/domain/entities/chat_message.dart';

/// Data model for [ChatMessage] entity
/// Used for JSON serialization/deserialization in data layer
class ChatMessageModel extends Equatable {
  final String role;
  final String message;
  final DateTime? timestamp;

  const ChatMessageModel({
    required this.role,
    required this.message,
    this.timestamp,
  });

  /// Convert from domain entity to model
  factory ChatMessageModel.fromEntity(ChatMessage entity) {
    return ChatMessageModel(
      role: entity.role,
      message: entity.message,
      timestamp: entity.timestamp,
    );
  }

  /// Convert from model to domain entity
  ChatMessage toEntity() {
    return ChatMessage(
      role: role,
      message: message,
      timestamp: timestamp,
    );
  }

  /// Create model from JSON
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      role: json['role'] ?? 'user',
      message: json['message'] ?? '',
      timestamp:
          json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'message': message,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [role, message, timestamp];
}
