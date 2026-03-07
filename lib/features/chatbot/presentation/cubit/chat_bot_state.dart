import 'package:equatable/equatable.dart';
import 'package:rahhala_app/features/chatbot/domain/entities/chat_message.dart';

abstract class ChatBotState extends Equatable {
  const ChatBotState();

  @override
  List<Object?> get props => [];
}

class ChatBotInitial extends ChatBotState {}

class ChatBotLoading extends ChatBotState {}

class ChatBotMessageSent extends ChatBotState {
  final List<ChatMessage> messages;

  const ChatBotMessageSent({required this.messages});

  @override
  List<Object?> get props => [messages];
}

class ChatBotMessageReceived extends ChatBotState {
  final List<ChatMessage> messages;

  const ChatBotMessageReceived({required this.messages});

  @override
  List<Object?> get props => [messages];
}

class ChatBotError extends ChatBotState {
  final String errorMessage;

  const ChatBotError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class ChatBotContextCreated extends ChatBotState {
  final String contextId;

  const ChatBotContextCreated({required this.contextId});

  @override
  List<Object?> get props => [contextId];
}
