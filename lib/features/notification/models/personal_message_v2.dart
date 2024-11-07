part of 'models.dart';

/// Model for personal messages in API.
@MappableClass(caseStyle: CaseStyle.snakeCase)
final class PersonalMessageV2 with PersonalMessageV2Mappable {
  /// Constructor.
  const PersonalMessageV2({
    required this.timestamp,
    required this.data,
    required this.peerUid,
    required this.peerUsername,
    required this.sender,
    required this.alreadyRead,
  });

  /// Timestamp in seconds.
  final int timestamp;

  /// Message content in plain text format.
  @MappableField(key: 'message')
  final String data;

  /// Uid of the user chatting with.
  final int peerUid;

  /// Username of the user chatting with.
  final String peerUsername;

  /// Flag indicating whether current user is the sender of the
  /// message.
  ///
  /// true if so, false if not.
  @MappableField(key: 'send')
  final bool sender;

  /// Flag indicating whether the message is read or not.
  final bool alreadyRead;
}
