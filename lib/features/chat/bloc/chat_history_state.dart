part of 'chat_history_bloc.dart';

/// Status of chat history.
enum ChatHistoryStatus {
  /// Initial state.
  initial,

  /// Loading data.
  loading,

  /// Load data succeed.
  success,

  /// Failed to load data.
  failure,

  /// Loading more data.
  ///
  /// Loading the second or more pages of data.
  loadingMore,
}

/// State of chat history, maintains data.
@MappableClass()
final class ChatHistoryState with ChatHistoryStateMappable {
  /// Constructor.
  const ChatHistoryState({
    this.status = ChatHistoryStatus.initial,
    this.user = const User.empty(),
    this.messageCount = 0,
    this.pageNumber,
    this.nextPage,
    this.previousPage,
    this.messages = const [],
  });

  /// Status.
  final ChatHistoryStatus status;

  /// The other user in the chat.
  ///
  /// Have username and user space url, without avatar here.
  final User user;

  /// Total messages count in chat history.
  final int messageCount;

  /// Current page number
  ///
  /// Default is null means we do not set it and do not know it.
  final int? pageNumber;

  /// Next page number or not.
  ///
  /// Null for no next page.
  final int? nextPage;

  /// Previous page or not.
  ///
  /// Null for no previous page.
  final int? previousPage;

  /// All chat messages fetched.
  ///
  /// May separate into different pages by server.
  ///
  /// 10 messages per page.
  final List<ChatMessage> messages;
}
