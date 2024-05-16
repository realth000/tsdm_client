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
  ///
  /// All messages in the list is reversed, a bit complex.
  /// For example we have 100 messages "1", "2", ..., "100", usually we first
  /// enter "the last page" which contains "91", "92", ..., "100" and "100" is
  /// the last message. So the page is desc but message in that page is asc
  /// sorted.
  /// We want to load "more page" (the previous page) by pulling the header of
  /// list view in UI and "81", "82", ..., "90" prepend in the bottom of screen.
  /// Besides, after pulling down, the screen is still at the position before
  /// pull (in this case "91") so user can scroll down the screen.
  /// The total behaviour is reversed compare to a normal list view, so we:
  ///
  /// 1. Reverse the data in each page, "100", "99", ..., "91" in this order.
  /// 2. Reverse the list view, so when using the list, "100" still at the
  ///    bottom of the screen.
  ///
  /// So when user try to pull down from the top of the screen, is doing action
  /// on the bottom of list view, all direction and sort is expected.
  final List<ChatMessage> messages;
}
