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
    required this.authorAvatarUrl,
    required this.message,
    required this.dateTime,
  });

  /// Username of message author.
  ///
  /// Optional because it's null when current sent the message.
  final String? author;

  /// Avatar url of author.
  final String? authorAvatarUrl;

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
    final username = element.querySelector('dd.ptm > a')?.innerText ??
        element.querySelector('dd.ptm > span.xi2')?.innerText;
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

    final dateTime = element.querySelector('dd.ptm > span.xg1')?.dateTime();

    final authorAvatarUrl =
        element.querySelector('dd.m.avt > a > img')?.imageUrl();

    return ChatMessage(
      author: username,
      authorAvatarUrl: authorAvatarUrl,
      message: message,
      dateTime: dateTime,
    );
  }
}
