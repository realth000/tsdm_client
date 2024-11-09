part of 'models.dart';

/// Base class of state or result from auto sync notice actions.
///
/// All types derived are used for pushing local notifications.
///
/// Functionality only get enabled when auto sync notice feature is enabled.
@MappableClass()
sealed class NotificationAutoSyncInfo with NotificationAutoSyncInfoMappable {
  /// Constructor.
  const NotificationAutoSyncInfo({
    required this.notice,
    required this.personalMessage,
    required this.broadcastMessage,
  });

  /// Count of unread notice.
  final int notice;

  /// Count of unread personal message.
  final int personalMessage;

  /// Count of unread broadcast message.
  final int broadcastMessage;
}

/// Received notice in auto sync notice actions.
///
/// No personal message, no broadcast message.
@MappableClass()
final class NotificationAutoSyncInfoNotice extends NotificationAutoSyncInfo
    with NotificationAutoSyncInfoNoticeMappable {
  /// Constructor.
  const NotificationAutoSyncInfoNotice({
    required this.msg,
    required super.notice,
    required super.personalMessage,
    required super.broadcastMessage,
  });

  /// String msg
  final String msg;
}

/// Received personal message in auto sync notice actions.
@MappableClass()
final class NotificationAutoSyncInfoPm extends NotificationAutoSyncInfo
    with NotificationAutoSyncInfoPmMappable {
  /// Constructor.
  const NotificationAutoSyncInfoPm({
    required this.user,
    required this.msg,
    required super.notice,
    required super.personalMessage,
    required super.broadcastMessage,
  });

  /// Username of the message sender.
  final String user;

  /// Preview of message;
  final String msg;
}

/// Received broadcast message in auto sync notice actions.
@MappableClass()
final class NotificationAutoSyncInfoBm extends NotificationAutoSyncInfo
    with NotificationAutoSyncInfoBmMappable {
  /// Constructor.
  const NotificationAutoSyncInfoBm({
    required this.msg,
    required super.notice,
    required super.personalMessage,
    required super.broadcastMessage,
  });

  /// Preview of message.
  final String msg;
}
