part of 'schema.dart';

/// Table for local notice.
///
/// Generated when interacting with other users: reply, mention, rate, ...
@DataClassName('NoticeEntity')
class Notice extends Table {
  /// Uid of the user who owns the notice.
  IntColumn get uid => integer()();

  /// Notice id.
  ///
  /// A field in server response, not the id of table.
  IntColumn get nid => integer()();

  /// Notice timestamp in seconds.
  IntColumn get timestamp => integer()();

  /// Notice body in html format.
  TextColumn get data => text()();

  /// User already read this notice or not.
  // ignore: unnecessary_nullable_return_type
  BoolColumn? get alreadyRead => boolean().nullable().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {uid, nid};
}
