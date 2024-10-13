part of 'schema.dart';

// TODO: For different notice types, store in one table or one for each type
// TODO: Table fields incomplete.
/// Table for local cached notice.
@DataClassName('NoticeCacheEntity')
class NoticeCache extends Table {
  /// User id who owns the notice.
  IntColumn get uid => integer()();

  /// Notice timestamp.
  DateTimeColumn get timestamp => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {uid, timestamp};
}
