part of 'schema.dart';

/// Table recoding user used avatars history.
///
/// All user submitted external avatar url are saved here.
@DataClassName('AvatarHistoryEntity')
class AvatarHistory extends Table {
  /// Uid of the user last used the avatar.
  IntColumn get lastUsedUserId => integer()();

  /// Avatar url.
  TextColumn get url => text()();

  /// The time last used this avatar.
  DateTimeColumn get lastUsedTime => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {lastUsedUserId, url};
}
