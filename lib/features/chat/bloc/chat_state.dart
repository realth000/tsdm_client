part of 'chat_bloc.dart';

/// Status of chat.
enum ChatStatus {
  /// Initial status.
  initial,

  /// Loading data.
  loading,

  /// Succeed to load data.
  success,

  /// Failed to load data.
  failure,
}

/// State of chat.
///
/// Since chat target is constructed from chat dialog, all these data are parsed
/// from that dialog, html fragment wrapped in xml.
@MappableClass()
final class ChatState with ChatStateMappable {
  /// Constructor.
  const ChatState({
    this.status = ChatStatus.initial,
    this.username = '',
    this.uid = '',
    this.chatHistoryUrl = '',
    this.spaceUrl = '',
    this.chatSendTarget,
    this.refreshMessageUrl,
    this.messageList = const [],
  });

  /// Status.
  final ChatStatus status;

  /// Username of the other user that chat with.
  ///
  /// Because sometimes we do not know who is chatting with (username is
  /// nullable in chat page). This value is parsed from the chat dialog.
  final String username;

  /// Uid of the other user that chat with.
  final String uid;

  /// User chat history url.
  final String chatHistoryUrl;

  /// User space url that chat with.
  final String spaceUrl;

  /// Parameters used in sending message to server.
  final ChatSendTarget? chatSendTarget;

  /// Url to fetch the latest message.
  ///
  /// This url is used after sending a message or some time elapsed (passive).
  final String? refreshMessageUrl;

  /// Recent chat history list.
  ///
  /// Each message only contains author and message content.
  ///
  /// No avatar, no detail date time.
  final List<ChatMessage> messageList;
}
