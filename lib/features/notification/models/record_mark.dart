part of 'models.dart';

/// Base class of all marks on all types of notification.
@MappableClass()
sealed class RecordMark with RecordMarkMappable {
  /// Constructor.
  const RecordMark();
}

/// Mark a notice.
@MappableClass()
final class RecordMarkNotice extends RecordMark with RecordMarkNoticeMappable {
  /// Constructor.
  const RecordMarkNotice({required this.uid, required this.nid, required this.alreadyRead});

  /// Uid of the notice.
  final int uid;

  /// Notice id of the notice.
  final int nid;

  /// Mark as read if true, or unread if false.
  final bool alreadyRead;
}

/// Mark a personal message.
@MappableClass()
final class RecordMarkPersonalMessage extends RecordMark with RecordMarkPersonalMessageMappable {
  /// Constructor.
  const RecordMarkPersonalMessage({required this.uid, required this.peerUid, required this.alreadyRead});

  /// Uid of the notice.
  final int uid;

  /// Uid of opposite user to chat with.
  final int peerUid;

  /// Mark as read if true, or unread if false.
  final bool alreadyRead;
}

/// Mark a personal message.
@MappableClass()
final class RecordMarkBroadcastMessage extends RecordMark with RecordMarkBroadcastMessageMappable {
  /// Constructor.
  const RecordMarkBroadcastMessage({required this.uid, required this.timestamp, required this.alreadyRead});

  /// Uid of the notice.
  final int uid;

  /// Timestamp of the message, in second.
  final int timestamp;

  /// Mark as read if true, or unread if false.
  final bool alreadyRead;
}
