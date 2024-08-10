import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/storage_provider/models/database/dao/dao.dart';
import 'package:tsdm_client/shared/providers/storage_provider/models/database/database.dart';
import 'package:tsdm_client/utils/logger.dart';

/// Load all cookie info from database without any dependency except [db].
///
/// Only use this function to preload cookie before initializing
/// [StorageProvider].
Future<Map<UserLoginInfo, Cookie>> preloadCookie(AppDatabase db) async {
  final allCookie = await CookieDao(db).selectAll();
  final mappedCookie = allCookie.map(
    (e) => MapEntry(
      UserLoginInfo(
        username: e.username,
        uid: e.uid,
        email: e.email,
      ),
      jsonEncode(e.cookie) as Map<String, String>,
    ),
  );

  return Map.fromEntries(mappedCookie);
}

/// Load all image cache info from database without any dependency except [db].
///
/// Only use this function to preload cookie before initializing
/// [StorageProvider].
Future<List<ImageCacheEntity>> preloadImageCache(AppDatabase db) async =>
    ImageCacheDao(db).selectAll();

/// [StorageProvider] should be used by other providers.
class StorageProvider with LoggerMixin {
  /// Constructor.
  const StorageProvider(this._db, this._cookieCache, this._imageCache);

  /// Injected database
  final AppDatabase _db;

  /// All cookie cached in memory.
  ///
  /// Read cache to avoid disk IO and make it synchronous.
  ///
  /// MUST update during cookie setter calls.
  final Map<UserLoginInfo, Cookie> _cookieCache;

  /// All image cache cached in memory.
  ///
  /// Access this field to avoid disk IO and make it synchronous.
  ///
  /// MUST update during image cache setter calls.
  final List<ImageCacheEntity> _imageCache;

  /*             cookie             */

  /// Get [Cookie] with [uid] from cookie cached saved in memory.
  ///
  /// Return null if not found.
  ///
  /// Generally the cookie cache is synced with database cookie values.
  /// So may not need to use the async version API to retry to read.
  Cookie? getCookieByUidSync(int uid) {
    return _cookieCache.entries
        .firstWhereOrNull((e) => e.key.uid == uid)
        ?.value;
  }

  /// Get [Cookie] with [uid].
  Future<Cookie?> getCookieByUid(int uid) async {
    final cookieEntity = await CookieDao(_db).selectCookieByUid(uid);
    if (cookieEntity == null) {
      return null;
    }
    return jsonDecode(cookieEntity.cookie) as Map<String, String>?;
  }

  /// Get [Cookie] with [username] from cookie cached saved in memory.
  ///
  /// Return null if not found.
  ///
  /// Generally the cookie cache is synced with database cookie values.
  /// So may not need to use the async version API to retry to read.
  Cookie? getCookieByUsernameSync(String username) {
    return _cookieCache.entries
        .firstWhereOrNull((e) => e.key.username == username)
        ?.value;
  }

  /// Get [Cookie] with [username].
  Future<Cookie?> getCookieByUsername(String username) async {
    final cookieEntity = await CookieDao(_db).selectCookieByUsername(username);
    if (cookieEntity == null) {
      return null;
    }
    return jsonDecode(cookieEntity.cookie) as Map<String, String>?;
  }

  /// Get [Cookie] with [email] from cookie cached saved in memory.
  ///
  /// Return null if not found.
  ///
  /// Generally the cookie cache is synced with database cookie values.
  /// So may not need to use the async version API to retry to read.
  Cookie? getCookieByEmailSync(String email) {
    return _cookieCache.entries
        .firstWhereOrNull((e) => e.key.email == email)
        ?.value;
  }

  /// Get [Cookie] with [email].
  Future<Cookie?> getCookieByEmail(String email) async {
    final cookieEntity = await CookieDao(_db).selectCookieByEmail(email);
    if (cookieEntity == null) {
      return null;
    }
    return jsonDecode(cookieEntity.cookie) as Map<String, String>?;
  }

  /// Save cookie with completed user info.
  ///
  /// Required full user info and save by [uid] so that we handled some extreme
  /// situation when username or email changed.
  Future<void> saveCookie({
    required String username,
    required int uid,
    required String email,
    required Cookie cookie,
  }) async {
    final currentCookie = (await getCookieByUid(uid)) ?? {};

    // Combine two map together, do not directly use [cookie].
    // ignore: cascade_invocations
    currentCookie.addAll(cookie);

    // Update cookie cache.
    final userInfo = UserLoginInfo(username: username, uid: uid, email: email);
    _cookieCache[userInfo] = cookie;

    await CookieDao(_db).upsertCookie(
      CookieCompanion(
        username: Value(username),
        uid: Value(uid),
        email: Value(email),
        cookie: Value(jsonEncode(currentCookie)),
      ),
    );
  }

  /// Delete cookie for [uid].
  Future<bool> deleteCookieByUid(int uid) async {
    // Update cookie cache.
    _cookieCache.removeWhere((e, _) => e.uid == uid);
    final affectedRows = await CookieDao(_db).deleteCookieByUid(uid);
    return affectedRows != 0;
  }

  /*            image cache           */

  /// Get the image cache for image from [url].
  ImageCacheEntity? getImageCacheSync(String url) =>
      _imageCache.firstWhereOrNull((e) => e.url == url);

  /// Get the image cache for image from [url].
  Future<ImageCacheEntity?> getImageCache(String url) async {
    return ImageCacheDao(_db).selectImageCacheByUrl(url);
  }

  /// Insert or update cache info, update all info.
  Future<void> updateImageCache(
    String url, {
    String? fileName,
    DateTime? lastCacheTime,
    DateTime? lastUsedTime,
  }) async {
    await ImageCacheDao(_db).upsertImageCache(
      ImageCacheCompanion(
        url: Value(url),
        fileName: fileName != null ? Value(fileName) : const Value.absent(),
        lastCachedTime: lastCacheTime != null
            ? Value(lastCacheTime)
            : Value(DateTime.now()),
        lastUsedTime:
            lastUsedTime != null ? Value(lastUsedTime) : const Value.absent(),
      ),
    );
  }

  /// Insert or update cache info, only update last used time.
  Future<void> updateImageCacheUsedTime(String url) async {
    await ImageCacheDao(_db).upsertImageCache(
      ImageCacheCompanion(url: Value(url), lastUsedTime: Value(DateTime.now())),
    );
  }

  /// Clear all image cache in database.
  Future<void> clearImageCache() async {
    await ImageCacheDao(_db).deleteAll();
  }

  /*             settings             */

  /// Load all saved settings.
  Future<List<SettingsEntity>> getAllSettings() async {
    return SettingsDao(_db).getAll();
  }

  /// Remove a settings with given [name].
  Future<bool> removeByKey(String name) async {
    final affectedRows = await SettingsDao(_db).deleteByName(name);
    return affectedRows != 0;
  }

  /// Get string type value of specified key.
  Future<String?> getString(String key) async =>
      SettingsDao(_db).getValueByName<String>(key);

  /// Save string type value of specified key.
  Future<void> saveString(String key, String value) async {
    await SettingsDao(_db).setValue<String>(key, value);
  }

  /// Get int type value of specified key.
  Future<int?> getInt(String key) async =>
      SettingsDao(_db).getValueByName<int>(key);

  /// Sae int type value of specified key.
  Future<void> saveInt(String key, int value) async {
    await SettingsDao(_db).setValue<int>(key, value);
  }

  /// Get bool type value of specified key.
  Future<bool?> getBool(String key) async =>
      SettingsDao(_db).getValueByName<bool>(key);

  /// Save bool type value of specified value.
  Future<void> saveBool(String key, {required bool value}) async {
    await SettingsDao(_db).setValue<bool>(key, value);
  }

  /// Get double type value of specified key.
  Future<double?> getDouble(String key) async =>
      SettingsDao(_db).getValueByName<double>(key);

  /// Save double type value of specified key.
  Future<void> saveDouble(String key, double value) async {
    await SettingsDao(_db).setValue<double>(key, value);
  }

  /// Delete the given record from database.
  Future<void> deleteKey(String key) async {
    await SettingsDao(_db).deleteByName(key);
  }
}
