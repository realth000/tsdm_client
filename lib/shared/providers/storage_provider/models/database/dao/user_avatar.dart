part of 'dao.dart';

/// DAO for table [UserAvatar].
@DriftAccessor(tables: [UserAvatar])
final class UserAvatarDao extends DatabaseAccessor<AppDatabase>
    with _$UserAvatarDaoMixin {
  /// Constructor.
  UserAvatarDao(super.db);

  /// Select all cache.
  Future<List<UserAvatarEntity>> selectAll() async {
    return select(userAvatar).get();
  }

  /// Select the unique avatar cache for user [username].
  Future<UserAvatarEntity?> selectAvatarByUsername(String username) async {
    return (select(userAvatar)..where((e) => e.username.equals(username)))
        .getSingleOrNull();
  }

  /// Save avatar cache.
  Future<int> upsertAvatar(UserAvatarCompanion avatarCompanion) async {
    return into(userAvatar).insertOnConflictUpdate(avatarCompanion);
  }

  /// Delete avatar cache with user [username].
  Future<int> deleteAvatarByUsername(String username) async {
    return (delete(userAvatar)..where((e) => e.username.equals(username))).go();
  }

  /// Delete all user avatar cache.
  Future<int> deleteAll() async {
    return delete(userAvatar).go();
  }
}
