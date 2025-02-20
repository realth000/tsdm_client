part of 'chat_bloc.dart';

/// Basic event of chat.
@MappableClass()
sealed class ChatEvent with ChatEventMappable {
  /// Constructor.
  const ChatEvent();
}

/// Basic event of chat.
@MappableClass()
final class ChatFetchHistoryRequested extends ChatEvent with ChatFetchHistoryRequestedMappable {
  /// Constructor.
  const ChatFetchHistoryRequested(this.uid);

  /// Uid to construct a chat dialog with.
  final String uid;
}
