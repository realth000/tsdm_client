part of 'models.dart';

/// Chat message model.
///
/// Represent a single chat message with corresponding info including:
///
/// * Author.
/// * Time (Optional).
/// * Message content.
@MappableClass()
final class ChatMessage with ChatMessageMappable {
  /// Constructor.
  const ChatMessage({
    required this.author,
    required this.message,
    required this.dateTime,
  });

  /// Username of message author.
  ///
  /// Optional because it's null when current sent the message.
  final String? author;

  /// Message content.
  ///
  /// Html fragment.
  final String message;

  /// Optional message send time.
  ///
  /// Make this field optional because we do not have it in the chat dialog.
  final DateTime? dateTime;

  /// Build from node `<dl>` with id starts with "pmlist_".
  static ChatMessage? fromDl(uh.Element element) {
    // Not null when another user sent the message.
    final username = element.querySelector('dd.ptm > a')?.attributes['href'];
    // Not null when current logged user sent the message.
    final currentUserNode = element.querySelector('dd.ptm > span.xi2');
    if (username == null && currentUserNode == null) {
      debug('failed to build chat message: author not found');
      return null;
    }

    final message = element.querySelector('dd:nth-child(4)')?.innerHtml;
    if (message == null) {
      debug('failed to build chat message: message not found');
      return null;
    }

    final dateTime = element.querySelector('span.xg1')?.dateTime();
    return ChatMessage(
      author: username,
      message: message,
      dateTime: dateTime,
    );
  }
}
