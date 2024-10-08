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
  ///
  /// Added in v3.
  DateTimeColumn get lastCheckin => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {uid};
}
