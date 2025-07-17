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
    required this.authorUid,
    required this.authorAvatarUrl,
    required this.message,
    required this.dateTime,
  });

  /// Username of message author.
  ///
  /// Optional because it's null when current sent the message.
  final String? author;

  /// Uid of message author.
  ///
  /// Required as it is used to visit user space page.
  final String? authorUid;

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
    final username = element.querySelector('dd.ptm > a')?.innerText.trim();
    // Not null when current logged user sent the message.
    final currentUsername = element.querySelector('dd.ptm > span.xi2')?.innerText.trim();
    if (username == null && currentUsername == null) {
      talker.error('failed to build chat message: author not found');
      return null;
    }

    final uid = element.querySelector('dd.m.avt > a')?.attributes['href']?.tryParseAsUri()?.queryParameters['uid'];

    final message = element.querySelector('dd:nth-child(4)')?.innerHtml;
    if (message == null) {
      talker.error('failed to build chat message: message not found');
      return null;
    }

    final dateTime = element.querySelector('dd.ptm > span.xg1')?.dateTime();

    final authorAvatarUrl = element.querySelector('dd.m.avt > a > img')?.imageUrl();

    return ChatMessage(
      author: username ?? currentUsername,
      authorUid: uid,
      authorAvatarUrl: authorAvatarUrl,
      message: message,
      dateTime: dateTime,
    );
  }

  /// Build from node `<li class="cl pmm">`.
  ///
  /// Chat page, not chat history page.
  ///
  /// With username, without avatar and uid.
  static ChatMessage? fromLi(uh.Element element) {
    final username = element.querySelector('div.pmt')?.innerText.split(':').first;
    final message = element.querySelector('div.pmd')?.innerHtml;
    if (username == null || message == null) {
      talker.error(
        'failed to build chat message: '
        'username=$username, message=$message',
      );
      return null;
    }

    return ChatMessage(author: username, authorUid: null, authorAvatarUrl: null, message: message, dateTime: null);
  }
}
