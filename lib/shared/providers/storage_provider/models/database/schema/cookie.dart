part of 'schema.dart';

/// Table for user cookies.
@DataClassName('CookieEntity')
class Cookie extends Table {
  /// User's name.
  TextColumn get username => text()();

  /// User id.
  IntColumn get uid => integer()();

  /// Email address.
  TextColumn get email => text()();

  /// Cookie value.
  TextColumn get cookie => text()();

  /// Last checkin time.
  DateTimeColumn get lastCheckin => dateTime().nullable()();

  /// Timestamp of last notice fetch from server.
  DateTimeColumn get lastFetchNotice => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {uid};
}
