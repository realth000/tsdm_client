part of 'schema.dart';

/// Table for history of all users visited thread.
///
/// Including user info, thread info and visit time.
@DataClassName('ThreadVisitHistoryEntity')
class ThreadVisitHistory extends Table {
  /// User id, part of [primaryKey].
  IntColumn get uid => integer()();

  /// Thread id, part of [primaryKey].
  IntColumn get tid => integer()();

  /// Name of user.
  TextColumn get username => text()();

  /// Thread title
  TextColumn get threadTitle => text()();

  /// Direct parent forum id.
  IntColumn get fid => integer()();

  /// Direct parent forum name.
  TextColumn get forumName => text()();

  /// Visit time, timestamp.
  DateTimeColumn get visitTime => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {uid, tid};
}
