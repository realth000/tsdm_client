part of 'dao.dart';

/// DAO for table [UserAvatarCache].
@DriftAccessor(tables: [UserAvatarCache])
final class UserAvatarCacheDao extends DatabaseAccessor<AppDatabase>
    with _$UserAvatarCacheDaoMixin {
  /// Constructor.
  UserAvatarCacheDao(super.db);

// TODO: CRUD
}
