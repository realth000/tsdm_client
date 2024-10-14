part of 'schema.dart';

/// Table for local notice.
///
/// Generated when interacting with other users: reply, mention, rate, ...
@DataClassName('NoticeEntity')
class Notice extends Table {
  /// Uid of the user who owns the notice.
  IntColumn get uid => integer()();

  /// Notice timestamp.
  DateTimeColumn get timestamp => dateTime()();

  /// Notice body in html format.
  TextColumn get data => text()();

  @override
  Set<Column<Object>> get primaryKey => {uid, timestamp};
}
