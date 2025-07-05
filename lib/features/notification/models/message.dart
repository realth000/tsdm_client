part of 'models.dart';

/// Private personal message with other users.
///
/// Each instance represents a session with another user including a series of
/// messages.
///
/// All private messages have id "pmlist_${MESSAGE_ID}".
///
/// We do not distinguish latest message direction (send to or receive from),
/// act like other chat apps.
@MappableClass()
final class PersonalMessage with PersonalMessageMappable {
  /// Constructor.
  const PersonalMessage({
    required this.user,
    required this.message,
    required this.lastMessageTime,
    required this.count,
    required this.chatUrl,
  });

  /// The other user communicating with.
  final User user;

  /// Last message content.
  final String message;

  /// Datetime of latest message.
  final DateTime lastMessageTime;

  /// Count of messages with user.
  final int? count;

  /// Chat page url.
  final String chatUrl;

  /// Build from dl with id "pmlist_XXXX".
  static PersonalMessage? fromDl(uh.Element element) {
    if (!element.id.startsWith('pmlist')) {
      return null;
    }
    final messageId = element.id.split('_').elementAtOrNull(1);
    if (messageId == null) {
      talker.error('failed to parse private message: message id not found');
      return null;
    }

    // Parse N from "共 N 条"
    final count = element
        .querySelector('dd.y.mtm.pm_o > span.xg1')
        ?.innerText
        .split(' ')
        .elementAtOrNull(1)
        ?.parseToInt();

    final avatarUrl = element.querySelector('dd.m.avt > a > img')?.imageUrl();
    final spaceUrl = element.querySelector('dd.m.avt > a')?.attributes['href'];

    if (avatarUrl == null || spaceUrl == null) {
      talker.error(
        'failed to parse private message: '
        'avatarUrl=$avatarUrl, spaceUrl=$spaceUrl',
      );
      return null;
    }

    final contentNode = element.querySelector('dd.ptm.pm_c');
    if (contentNode == null) {
      talker.error('failed to parse private message: content node not found');
      return null;
    }

    final username = element.querySelector('dd:nth-child(3) > a')?.innerText;
    final lastMessageTime = element.querySelector('dd:nth-child(3) > span.xg1')?.dateTime();
    final chatUrl = element.querySelector('a#pmlist_${messageId}_a')?.attributes['href']?.unescapeHtml()?.prependHost();
    final message = element
        .querySelector('dd:nth-child(3) > span.xg1')
        ?.previousNode
        ?.text
        ?.split(':')
        .elementAtOrNull(1)
        ?.trim();
    if (username == null || lastMessageTime == null || chatUrl == null || message == null) {
      talker.error(
        'failed to parse private message: '
        'username=$username, lastMessageTime=$lastMessageTime, '
        'chatUrl=$chatUrl, message=$message',
      );
      return null;
    }

    return PersonalMessage(
      user: User(avatarUrl: avatarUrl, name: username, url: spaceUrl),
      message: message,
      lastMessageTime: lastMessageTime,
      count: count,
      chatUrl: chatUrl,
    );
  }
}

/// Broadcast messages received from system.
///
/// All broadcast messages have id "gpmlist_${MESSAGE_ID}".
@MappableClass()
final class BroadcastMessage with BroadcastMessageMappable {
  /// Constructor.
  const BroadcastMessage({required this.message, required this.messageTime, required this.redirectUrl});

  /// Message content text.
  final String message;

  /// Datetime of message.
  final DateTime messageTime;

  /// Url to redirect, usually is a thread page.
  ///
  /// Maybe some broadcast messages have no corresponding url
  /// so make it nullable.
  final String? redirectUrl;

  /// Build a [BroadcastMessage] instance from dl node [element].
  ///
  /// Node MUST have id in format "gpmlist_${ID}".
  static BroadcastMessage? fromDl(uh.Element element) {
    if (!element.id.startsWith('gpmlist_')) {
      talker.error('failed to build broadcast message: id not found');
      return null;
    }

    final infoNode = element.querySelector('dd:nth-child(3)');
    if (infoNode == null) {
      talker.error('failed to build broadcast message: info node not found');
      return null;
    }
    final message = infoNode.querySelector('span')?.innerText.trim();
    final messageTime = infoNode.querySelector('span.xg1')?.dateTime();
    final redirectUrl = infoNode.querySelector('a')?.attributes['href']?.unescapeHtml()?.prependHost();
    if (message == null || messageTime == null) {
      talker.error(
        'failed to build broadcast message: '
        'redirectUrl=$redirectUrl, messageTime=$messageTime',
      );
      return null;
    }

    return BroadcastMessage(message: message, messageTime: messageTime, redirectUrl: redirectUrl);
  }
}
