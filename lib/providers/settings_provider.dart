import 'dart:io';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tsdm_client/models/database/cookie.dart';
import 'package:tsdm_client/models/database/settings.dart';
import 'package:tsdm_client/models/settings.dart';
import 'package:tsdm_client/utils/debug.dart';

part '../generated/providers/settings_provider.g.dart';

late final _SettingsStorage _storage;

/// Notifier of app settings.
@Riverpod(keepAlive: true)
class AppSettings extends _$AppSettings {
  /// Constructor.
  @override
  Settings build() {
    return Settings(
      dioAccept:
          _storage.getString(settingsNetClientAccept) ?? _defaultDioAccept,
      dioAcceptEncoding: _storage.getString(settingsNetClientAcceptEncoding) ??
          _defaultDioAcceptEncoding,
      dioAcceptLanguage: _storage.getString(settingsNetClientAcceptLanguage) ??
          _defaultDioAcceptLanguage,
      dioUserAgent: _storage.getString(settingsNetClientUserAgent) ??
          _defaultDioUserAgent,
      windowWidth:
          _storage.getDouble(settingsWindowWidth) ?? _defaultWindowWidth,
      windowHeight:
          _storage.getDouble(settingsWindowHeight) ?? _defaultWindowHeight,
      windowPositionDx: _storage.getDouble(settingsWindowPositionDx) ??
          _defaultWindowPositionDx,
      windowPositionDy: _storage.getDouble(settingsWindowPositionDy) ??
          _defaultWindowPositionDy,
      windowInCenter:
          _storage.getBool(settingsWindowInCenter) ?? _defaultWindowInCenter,
      loginUsername:
          _storage.getString(settingsLoginUsername) ?? _defaultLoginUsername,
      themeMode: _storage.getInt(settingsThemeMode) ?? _defaultThemeMode,
    );
  }

  /// Dio config: Accept.
  static const String _defaultDioAccept =
      'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7';

  /// Dio config: Accept-Encoding.
  static const String _defaultDioAcceptEncoding = 'gzip, deflate, br';

  /// Dio config: Accept-Language.
  static const String _defaultDioAcceptLanguage =
      'zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6,zh-TW;q=0.5';

  /// Dio config: User-Agent.
  static const String _defaultDioUserAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36 Edg/110.0.1587.57';

  /// Window position config on desktop platforms.
  static const _defaultWindowPositionDx = 0.0;

  /// Window position config on desktop platforms.
  static const _defaultWindowPositionDy = 0.0;

  /// Window width config on desktop platforms.
  static const _defaultWindowWidth = 600.0;

  /// Window height config on desktop platforms.
  static const _defaultWindowHeight = 800.0;

  /// Window whether in the center of screen config on desktop platforms.
  static const _defaultWindowInCenter = false;

  /// Login user username.
  static const _defaultLoginUsername = '';

  /// Default app theme mode.
  ///
  /// 0: [ThemeMode.system]
  /// 1: [ThemeMode.light]
  /// 2: [ThemeMode.dark]
  static final _defaultThemeMode = ThemeMode.system.index;

  Future<void> setWindowSize(Size size) async {
    await _storage.saveDouble(settingsWindowWidth, size.width);
    await _storage.saveDouble(settingsWindowHeight, size.height);
    state = state.copyWith(
      windowPositionDx: size.width,
      windowPositionDy: size.height,
    );
  }

  Future<void> setWindowPosition(Offset offset) async {
    await _storage.saveDouble(settingsWindowPositionDx, offset.dx);
    await _storage.saveDouble(settingsWindowPositionDy, offset.dy);
    state = state.copyWith(
      windowPositionDx: offset.dx,
      windowPositionDy: offset.dy,
    );
  }

  Future<void> setThemeMode(int themeMode) async {
    await _storage.saveInt(settingsThemeMode, themeMode);
    state = state.copyWith(themeMode: themeMode);
  }

  /// Update current login user username.
  ///
  /// Because in some situation we don't know uid (e.g. try to login), use this
  /// [username] to identify user.
  ///
  /// Note that the server side does not allow same username so it's safe to
  /// treat username as user identifier.
  Future<void> setLoginUsername(String username) async {
    await _storage.saveString(settingsLoginUsername, username);
    state = state.copyWith(loginUsername: username);
  }

  /// Get a cookie belongs to user with [username].
  ///
  /// Return null if not found.
  DatabaseCookie? getCookie(String username) {
    return _storage.getCookie(username);
  }

  /// Save cookie into database.
  ///
  /// This function should only be called by cookie provider.
  Future<void> saveCookie(
    String username,
    Map<String, String> cookie,
  ) async {
    return _storage.saveCookie(username, cookie);
  }

  /// Delete user [username]'s cookie from database.
  ///
  /// This function should only be called by cookie provider.
  Future<bool> deleteCookieByUsername(String username) async {
    return _storage.deleteCookieByUsername(username);
  }
}

/// Init settings, must call before start.
Future<void> initSettings() async {
  _storage = await _SettingsStorage().init();
}

class _SettingsStorage {
  late final Isar _isar;

  bool _initialized = false;

  Future<_SettingsStorage> init() async {
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
      schemas: [DatabaseSettingsSchema, DatabaseCookieSchema],
      directory: isarStorageDir.path,
      name: 'main',
    );
    return this;
  }

  void dispose() {
    // Only try to close isar instance when already initialized
    if (_initialized) {
      _isar.close();
    }
  }

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
