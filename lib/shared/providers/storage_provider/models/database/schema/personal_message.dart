part of 'schema.dart';

/// Table for local stored personal message, aka private message.
///
/// This type of message is generated when chatting with other users.
@DataClassName('PersonalMessageEntity')
class PersonalMessage extends Table {
  /// Uid of the user who owns the notice.
  IntColumn get uid => integer()();

  /// Notice timestamp in seconds.
  IntColumn get timestamp => integer()();

  /// Message body in plain text.
  TextColumn get data => text()();

  /// Uid of the user that chatting with.
  IntColumn get peerUid => integer()();

  /// Username of the user that chatting with.
  TextColumn get peerUsername => text()();

  /// Flag indicating whether notice user (with [uid]) is the sender of the
  /// message.
  ///
  /// true if so, false if not.
  BoolColumn get sender => boolean()();

  /// Flag indicating message already read or not?
  ///
  /// Passive format of verb read.
  BoolColumn get alreadyRead => boolean()();

  @override
  Set<Column<Object>> get primaryKey => {uid, peerUid};
}
