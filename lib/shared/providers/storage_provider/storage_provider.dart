import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/storage_provider/models/database/dao/dao.dart';
import 'package:tsdm_client/shared/providers/storage_provider/models/database/database.dart';
import 'package:tsdm_client/utils/logger.dart';

/// [StorageProvider] should be used by other providers.
class StorageProvider with LoggerMixin {
  /// Constructor.
  const StorageProvider(this._db);

  /// Injected database
  final AppDatabase _db;

  /*             cookie             */

  /// Get [Cookie] with [uid].
  Future<Cookie?> getCookieByUid(int uid) async {
    final cookieEntity = await CookieDao(_db).selectCookieByUid(uid);
    if (cookieEntity == null) {
      return null;
    }
    return jsonDecode(cookieEntity.cookie) as Map<String, dynamic>?;
  }

  /// Get [Cookie] with [username].
  Future<Cookie?> getCookieByUsername(String username) async {
    final cookieEntity = await CookieDao(_db).selectCookieByUsername(username);
    if (cookieEntity == null) {
      return null;
    }
    return jsonDecode(cookieEntity.cookie) as Map<String, dynamic>?;
  }

  /// Get [Cookie] with [email].
  Future<Cookie?> getCookieByEmail(String email) async {
    final cookieEntity = await CookieDao(_db).selectCookieByEmail(email);
    if (cookieEntity == null) {
      return null;
    }
    return jsonDecode(cookieEntity.cookie) as Map<String, dynamic>?;
  }

  /// Save cookie with completed user info.
  ///
  /// Required full user info and save by [uid] so that we handled some extreme
  /// situation when username or email changed.
  Future<void> saveCookie({
    required String username,
    required int uid,
    required String email,
    required Map<String, String> cookie,
  }) async {
    final currentCookie = (await getCookieByUid(uid)) ?? {};

    // Combine two map together, do not directly use [cookie].
    // ignore: cascade_invocations
    currentCookie.addAll(cookie);

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
    final affectedRows = await CookieDao(_db).deleteCookieByUid(uid);
    return affectedRows != 0;
  }

  /*            image cache           */

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
    if (!settingsTypeMap.containsKey(name)) {
      error('failed to save settings: invalid key $name');
      return false;
    }
    final affectedRows = await SettingsDao(_db).deleteByName(name);
    return affectedRows != 0;
  }

  /// Get string type value of specified key.
  Future<String?> getString(String key) async =>
      SettingsDao(_db).getValueByName<String>(key);

  /// Save string type value of specified key.
  Future<void> saveString(String key, String value) async {
    if (!settingsTypeMap.containsKey(key)) {
      error('failed to save settings: invalid key $key');
      return;
    }
    await SettingsDao(_db).setValue<String>(key, value);
  }

  /// Get int type value of specified key.
  Future<int?> getInt(String key) async =>
      SettingsDao(_db).getValueByName<int>(key);

  /// Sae int type value of specified key.
  Future<void> saveInt(String key, int value) async {
    if (!settingsTypeMap.containsKey(key)) {
      error('failed to save settings: invalid key $key');
      return;
    }
    await SettingsDao(_db).setValue<int>(key, value);
  }

  /// Get bool type value of specified key.
  Future<bool?> getBool(String key) async =>
      SettingsDao(_db).getValueByName<bool>(key);

  /// Save bool type value of specified value.
  Future<void> saveBool(String key, {required bool value}) async {
    if (!settingsTypeMap.containsKey(key)) {
      error('failed to save settings: invalid key $key');
      return;
    }
    await SettingsDao(_db).setValue<bool>(key, value);
  }

  /// Get double type value of specified key.
  Future<double?> getDouble(String key) async =>
      SettingsDao(_db).getValueByName<double>(key);

  /// Save double type value of specified key.
  Future<void> saveDouble(String key, double value) async {
    if (!settingsTypeMap.containsKey(key)) {
      error('failed to save settings: invalid key $key');
      return;
    }
    await SettingsDao(_db).setValue<double>(key, value);
  }

  /// Delete the given record from database.
  Future<void> deleteKey(String key) async {
    if (!settingsTypeMap.containsKey(key)) {
      error('failed to save settings: invalid key $key');
      return;
    }

    await SettingsDao(_db).deleteByName(key);
  }
}
