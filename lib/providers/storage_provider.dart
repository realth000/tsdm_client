import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tsdm_client/models/database/cookie.dart';
import 'package:tsdm_client/models/database/image_cache.dart';
import 'package:tsdm_client/models/database/settings.dart';
import 'package:tsdm_client/models/settings.dart';
import 'package:tsdm_client/utils/debug.dart';

part '../generated/providers/storage_provider.g.dart';

late final Storage _storage;

/// Init settings, must call before start.
Future<void> initStorage() async {
  _storage = await Storage().init();
}

// Now make this `keepAlive` to avoid schedule task exception.
// FIXME: Fix exception `Only one task can be scheduled at a time`.
/// Database instance provider.
@Riverpod(keepAlive: true)
class AppStorage extends _$AppStorage {
  @override
  Storage build() {
    return _storage;
  }
}

class Storage {
  late final Isar _isar;

  bool _initialized = false;

  Future<Storage> init() async {
    if (_initialized) {
      return this;
    }
    _initialized = true;

    final isarStorageDir =
        Directory('${(await getApplicationSupportDirectory()).path}/db');

    if (!isarStorageDir.existsSync()) {
      await isarStorageDir.create(recursive: true);
    }

    debug('init isar storage in $isarStorageDir');

    _isar = await Isar.openAsync(
      schemas: [
        DatabaseSettingsSchema,
        DatabaseCookieSchema,
        DatabaseImageCacheSchema,
      ],
      directory: isarStorageDir.path,
      name: 'main',
    );
    return this;
  }

  // TODO: Dispose before app exits.
  void _dispose() {
    // Only try to close isar instance when already initialized
    if (_initialized) {
      _isar.close();
    }
  }

  /*             cookie             */

  DatabaseCookie? getCookie(String username) {
    return _isar.databaseCookies.where().usernameEqualTo(username).findFirst();
  }

  Future<void> saveCookie(
    String username,
    Map<String, String> cookie,
  ) async {
    final currentCookie = _isar.databaseCookies
            .where()
            .usernameEqualTo(username)
            .findFirst()
            ?.cookie ??
        {};

    /// Combine two map together, do not directly use [cookie].
    currentCookie.addAll(cookie);
    await _isar.writeAsync((isar) {
      isar.databaseCookies.put(DatabaseCookie(
        id: isar.databaseCookies.autoIncrement(),
        username: username,
        cookie: currentCookie,
      ));
    });
  }

  Future<bool> deleteCookieByUsername(String username) async {
    return _isar.writeAsync((isar) {
      return isar.databaseCookies
          .where()
          .usernameEqualTo(username)
          .deleteFirst();
    });
  }

  /*            image cache           */

  DatabaseImageCache? getImageCache(String imageUrl) {
    return _isar.databaseImageCaches
        .where()
        .imageUrlEqualTo(imageUrl)
        .findFirst();
  }

  /// Insert or update cache info, update all info.
  Future<void> updateImageCache(
    String imageUrl, {
    String? fileName,
    DateTime? lastCacheTime,
    DateTime? lastUsedTime,
  }) async {
    final cache = await _isar.databaseImageCaches
        .where()
        .imageUrlEqualTo(imageUrl)
        .findFirstAsync();

    await _isar.writeAsync((isar) {
      isar.databaseImageCaches.put(DatabaseImageCache.fromData(
        id: cache?.id ?? isar.databaseImageCaches.autoIncrement(),
        imageUrl: imageUrl,
        fileName: fileName ?? cache?.fileName,
        lastCachedTime: lastCacheTime,
        lastUsedTime: lastUsedTime,
      ));
    });
  }

  /// Insert or update cache info, only update last used time.
  Future<void> updateImageCacheUsedTime(String imageUrl) async {
    final cache = await _isar.databaseImageCaches
        .where()
        .imageUrlEqualTo(imageUrl)
        .findFirstAsync();

    await _isar.writeAsync((isar) {
      isar.databaseImageCaches.put(DatabaseImageCache.fromData(
        id: cache?.id ?? isar.databaseImageCaches.autoIncrement(),
        imageUrl: imageUrl,
        fileName: cache?.fileName,
        lastCachedTime: cache?.lastUsedTime,
      ));
    });
  }

  Future<void> clearImageCache() async {
    await _isar.writeAsync((isar) {
      isar.databaseImageCaches.clear();
    });
  }

  /*             settings             */

  /// Get string type value of specified key.
  String? getString(String key) =>
      _isar.databaseSettings.where().nameEqualTo(key).findFirst()?.stringValue;

  /// Save string type value of specified key.
  Future<bool> saveString(String key, String value) async {
    if (!settingsMap.containsKey(key)) {
      debug('failed to save settings: invalid key $key');
      return false;
    }
    await _isar.writeAsync((isar) {
      isar.databaseSettings.put(DatabaseSettings.fromString(
        id: isar.databaseSettings.autoIncrement(),
        name: key,
        stringValue: value,
      ));
    });
    return true;
  }

  /// Get int type value of specified key.
  int? getInt(String key) =>
      _isar.databaseSettings.where().nameEqualTo(key).findFirst()?.intValue;

  /// Sae int type value of specified key.
  Future<bool> saveInt(String key, int value) async {
    if (!settingsMap.containsKey(key)) {
      debug('failed to save settings: invalid key $key');
      return false;
    }
    await _isar.writeAsync((isar) {
      isar.databaseSettings.put(DatabaseSettings.fromInt(
        id: isar.databaseSettings.autoIncrement(),
        name: key,
        intValue: value,
      ));
    });
    return true;
  }

  /// Get bool type value of specified key.
  bool? getBool(String key) =>
      _isar.databaseSettings.where().nameEqualTo(key).findFirst()?.boolValue;

  /// Save bool type value of specified value.
  Future<bool> saveBool(String key, {required bool value}) async {
    if (!settingsMap.containsKey(key)) {
      debug('failed to save settings: invalid key $key');
      return false;
    }
    await _isar.writeAsync((isar) {
      isar.databaseSettings.put(DatabaseSettings.fromBool(
        id: isar.databaseSettings.autoIncrement(),
        name: key,
        boolValue: value,
      ));
    });
    return true;
  }

  /// Get double type value of specified key.
  double? getDouble(String key) =>
      _isar.databaseSettings.where().nameEqualTo(key).findFirst()?.doubleValue;

  /// Save double type value of specified key.
  Future<bool> saveDouble(String key, double value) async {
    if (!settingsMap.containsKey(key)) {
      debug('failed to save settings: invalid key $key');
      return false;
    }
    await _isar.writeAsync((isar) {
      isar.databaseSettings.put(DatabaseSettings.fromDouble(
        id: isar.databaseSettings.autoIncrement(),
        name: key,
        doubleValue: value,
      ));
    });
    return true;
  }

  DateTime? getDateTime(String key) => _isar.databaseSettings
      .where()
      .nameEqualTo(key)
      .findFirst()
      ?.dateTimeValue;

  Future<bool> saveDateTime(String key, DateTime value) async {
    if (!settingsMap.containsKey(key)) {
      debug('failed to save settings: invalid key $key');
      return false;
    }
    await _isar.writeAsync((isar) {
      isar.databaseSettings.put(DatabaseSettings.fromDateTime(
        id: isar.databaseSettings.autoIncrement(),
        name: key,
        dateTimeValue: value,
      ));
    });
    return true;
  }

  /// Get string list type value of specified key.
  List<String>? getStringList(String key) => _isar.databaseSettings
      .where()
      .nameEqualTo(key)
      .findFirst()
      ?.stringListValue;

  /// Save string list type value of specified key.
  Future<bool> saveStringList(String key, List<String> value) async {
    if (!settingsMap.containsKey(key)) {
      debug('failed to save settings: invalid key $key');
      return false;
    }
    await _isar.writeAsync((isar) {
      _isar.databaseSettings.put(DatabaseSettings.fromStringList(
        id: isar.databaseSettings.autoIncrement(),
        name: key,
        stringListValue: value,
      ));
    });
    return true;
  }

  /// Get string list type value of specified key.
  List<int>? getIntList(String key) =>
      _isar.databaseSettings.where().nameEqualTo(key).findFirst()?.intListValue;

  /// Save string list type value of specified key.
  Future<bool> saveIntList(String key, List<int> value) async {
    if (!settingsMap.containsKey(key)) {
      debug('failed to save settings: invalid key $key');
      return false;
    }
    await _isar.writeAsync((isar) {
      _isar.databaseSettings.put(DatabaseSettings.fromIntList(
        id: isar.databaseSettings.autoIncrement(),
        name: key,
        intListValue: value,
      ));
    });
    return true;
  }

  /// Get string list type value of specified key.
  List<double>? getDoubleList(String key) => _isar.databaseSettings
      .where()
      .nameEqualTo(key)
      .findFirst()
      ?.doubleListValue;

  /// Save string list type value of specified key.
  Future<bool> saveDoubleList(String key, List<double> value) async {
    if (!settingsMap.containsKey(key)) {
      debug('failed to save settings: invalid key $key');
      return false;
    }
    await _isar.writeAsync((isar) {
      _isar.databaseSettings.put(DatabaseSettings.fromDoubleList(
        id: isar.databaseSettings.autoIncrement(),
        name: key,
        doubleListValue: value,
      ));
    });
    return true;
  }

  /// Get string list type value of specified key.
  List<bool>? getBoolList(String key) => _isar.databaseSettings
      .where()
      .nameEqualTo(key)
      .findFirst()
      ?.boolListValue;

  /// Save string list type value of specified key.
  Future<bool> saveBoolList(String key, List<bool> value) async {
    if (!settingsMap.containsKey(key)) {
      debug('failed to save settings: invalid key $key');
      return false;
    }
    await _isar.writeAsync((isar) {
      _isar.databaseSettings.put(DatabaseSettings.fromBoolList(
        id: isar.databaseSettings.autoIncrement(),
        name: key,
        boolListValue: value,
      ));
    });
    return true;
  }

  /// Get string list type value of specified key.
  List<DateTime>? getDateTimeList(String key) => _isar.databaseSettings
      .where()
      .nameEqualTo(key)
      .findFirst()
      ?.dateTimeListValue;

  /// Save string list type value of specified key.
  Future<bool> saveDateTimeList(String key, List<DateTime> value) async {
    if (!settingsMap.containsKey(key)) {
      debug('failed to save settings: invalid key $key');
      return false;
    }
    await _isar.writeAsync((isar) {
      _isar.databaseSettings.put(DatabaseSettings.fromDateTimeList(
        id: isar.databaseSettings.autoIncrement(),
        name: key,
        dateTimeListValue: value,
      ));
    });
    return true;
  }
}
