import 'package:equatable/equatable.dart';
import 'package:rahhala_app/features/chatbot/domain/entities/chat_message.dart';

/// Base state class for ChatBot feature
abstract class ChatBotState extends Equatable {
  const ChatBotState();

  @override
  List<Object?> get props => [];
}

/// Initial state when chatbot is first loaded
class ChatBotInitial extends ChatBotState {}

/// Loading state while sending message or waiting for response
class ChatBotLoading extends ChatBotState {}

/// State after user message has been sent successfully
class ChatBotMessageSent extends ChatBotState {
  final List<ChatMessage> messages;

  const ChatBotMessageSent({required this.messages});

  @override
  List<Object?> get props => [messages];
}

/// State after receiving AI response (non-streaming)
class ChatBotMessageReceived extends ChatBotState {
  final List<ChatMessage> messages;

  const ChatBotMessageReceived({required this.messages});

  @override
  List<Object?> get props => [messages];
}

/// State during streaming response - emitted with each chunk
class ChatBotStreaming extends ChatBotState {
  final List<ChatMessage> messages;
  final String currentChunk;

  const ChatBotStreaming({
    required this.messages,
    required this.currentChunk,
  });

  @override
  List<Object?> get props => [messages, currentChunk];
}

/// Error state when something goes wrong
class ChatBotError extends ChatBotState {
  final String errorMessage;

  const ChatBotError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

/// State when a conversation context is created
class ChatBotContextCreated extends ChatBotState {
  final String contextId;

  const ChatBotContextCreated({required this.contextId});

  @override
  List<Object?> get props => [contextId];
}
