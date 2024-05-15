part of 'chat_history_bloc.dart';

/// Basic class of events in chat.
@MappableClass()
sealed class ChatHistoryEvent with ChatHistoryEventMappable {
  /// Constructor.
  const ChatHistoryEvent();
}

/// Requested to load
@MappableClass()
final class ChatHistoryLoadHistoryRequested extends ChatHistoryEvent
    with ChatHistoryLoadHistoryRequestedMappable {
  /// Constructor.
  const ChatHistoryLoadHistoryRequested({
    required this.uid,
    required this.page,
  });

  /// User uid to chat with.
  final String uid;

  /// Page number in chat history.
  final int? page;
}
