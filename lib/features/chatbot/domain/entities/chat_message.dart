import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String role; // 'user' or 'assistant'
  final String message;
  final DateTime? timestamp;

  const ChatMessage({
    required this.role,
    required this.message,
    this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'message': message,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] ?? 'user',
      message: json['message'] ?? '',
      timestamp:
          json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
    );
  }

  @override
  List<Object?> get props => [role, message, timestamp];
}
