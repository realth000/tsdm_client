part of 'schema.dart';

/// Table for local stored broadcast messages, aka public messages.
///
/// This type of message is generated when receiving system broadcast messages.
@DataClassName('BroadcastMessageEntity')
class BroadcastMessage extends Table {
  /// Uid of the user who owns the notice.
  IntColumn get uid => integer()();

  /// Notice timestamp in seconds.
  IntColumn get timestamp => integer()();

  /// Notice body in plain text.
  TextColumn get data => text()();

  /// Notice id.
  IntColumn get pmid => integer()();

  /// User already read this message or not.
  // ignore: unnecessary_nullable_return_type
  BoolColumn? get alreadyRead => boolean().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {uid, timestamp};
}
