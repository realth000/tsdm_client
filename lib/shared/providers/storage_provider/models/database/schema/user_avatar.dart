part of 'schema.dart';

/// Table for all user avatar cache.
///
/// Store the relationship between user and user avatar image cache.
///
/// This table is here because there are many places that only have a username
/// without avatar. Use this table to record all users' avatar, no matter login
/// or not, cache file name and user's name.
/// So that once avatar is cached, related user's avatar is available everywhere
/// in the app.
///
/// Remember that this table does not control or determine user avatar cache's
/// lifetime, only record the relationship. And of course multiple users may
/// share one avatar.
@DataClassName('UserAvatarEntity')
class UserAvatar extends Table {
  /// Username of the user using this avatar.
  TextColumn get username => text()();

  /// Cache file name.
  ///
  /// Only the name part.
  TextColumn get cacheName => text()();

  /// Avatar image url
  TextColumn get imageUrl => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {username};
}
