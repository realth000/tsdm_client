part of 'dao.dart';

/// DAO for table [UserAvatarCache].
@DriftAccessor(tables: [UserAvatarCache])
final class UserAvatarCacheDao extends DatabaseAccessor<AppDatabase>
    with _$UserAvatarCacheDaoMixin {
  /// Constructor.
  UserAvatarCacheDao(super.db);

  /// Select all cache.
  Future<List<UserAvatarCacheEntity>> selectAll() async {
    return select(userAvatarCache).get();
  }

  /// Select the unique avatar cache for user [username].
  Future<UserAvatarCacheEntity?> selectAvatarByUsername(String username) async {
    return (select(userAvatarCache)..where((e) => e.username.equals(username)))
        .getSingleOrNull();
  }

  /// Save avatar cache.
  Future<int> upsertAvatar(UserAvatarCacheCompanion avatarCompanion) async {
    return into(userAvatarCache).insertOnConflictUpdate(avatarCompanion);
  }

  /// Delete avatar cache with user [username].
  Future<int> deleteAvatarByUsername(String username) async {
    return (delete(userAvatarCache)..where((e) => e.username.equals(username)))
        .go();
  }

  /// Delete all user avatar cache.
  Future<int> deleteAll() async {
    return delete(userAvatarCache).go();
  }
}
