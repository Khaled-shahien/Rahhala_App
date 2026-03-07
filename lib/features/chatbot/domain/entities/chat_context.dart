import 'package:equatable/equatable.dart';

class ChatContext extends Equatable {
  final String contextId;
  final String? title;
  final DateTime createdAt;

  const ChatContext({
    required this.contextId,
    this.title,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'contextId': contextId,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ChatContext.fromJson(Map<String, dynamic> json) {
    return ChatContext(
      contextId: json['contextId'] ?? '',
      title: json['title'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [contextId, title, createdAt];
}
