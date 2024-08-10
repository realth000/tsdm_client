part of 'dao.dart';

/// DAO for table [Cookie].
@DriftAccessor(tables: [Cookie])
final class CookieDao extends DatabaseAccessor<AppDatabase>
    with _$CookieDaoMixin {
  /// Constructor.
  CookieDao(super.db);

  /// Get all cookies.
  Future<List<CookieEntity>> selectAll() async {
    return select(cookie).get();
  }

  /// Get cookie by [username].
  Future<CookieEntity?> selectCookieByUsername(String username) async {
    return (select(cookie)..where((e) => e.username.equals(username)))
        .getSingleOrNull();
  }

  /// Get cookie by [uid].
  Future<CookieEntity?> selectCookieByUid(int uid) async {
    return (select(cookie)..where((e) => e.uid.equals(uid))).getSingleOrNull();
  }

  /// Get cookie by [email].
  Future<CookieEntity?> selectCookieByEmail(String email) async {
    return (select(cookie)..where((e) => e.email.equals(email)))
        .getSingleOrNull();
  }

  /// Insert or update cookie from [cookieCompanion].
  Future<int> upsertCookie(CookieCompanion cookieCompanion) async {
    return into(cookie).insertOnConflictUpdate(cookieCompanion);
  }

  /// Delete cookie by user's [username].
  Future<int> deleteCookieByUsername(String username) async {
    return (delete(cookie)..where((e) => e.username.equals(username))).go();
  }

  /// Delete cookie by user's [uid].
  Future<int> deleteCookieByUid(int uid) async {
    return (delete(cookie)..where((e) => e.uid.equals(uid))).go();
  }

  /// Delete cookie by user's [email].
  Future<int> deleteCookieByEmail(String email) async {
    return (delete(cookie)..where((e) => e.email.equals(email))).go();
  }
}
