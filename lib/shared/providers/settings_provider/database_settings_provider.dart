import 'package:flutter/material.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/settings_provider/mixin/settings_default_mixin.dart';
import 'package:tsdm_client/shared/providers/settings_provider/settings_provider.dart';
import 'package:tsdm_client/shared/providers/storage_provider/models/models.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';

/// Notifier of app settings.
///
/// Can be used by SettingsRepository.
///
/// **DO NOT USE IT ELSEWHERE.**
class DatabaseSettingsProvider
    with SettingsDefaultMapMixin
    implements SettingsProvider {
  DatabaseSettingsProvider();

  StorageProvider _getStorage() {
    return getIt.get<StorageProvider>();
  }

  @override
  String getNetClientAccept() {
    final storage = _getStorage();
    final accept =
        storage.getString(settingsNetClientAccept) ?? defaultNetClientAccept;
    return accept;
  }

  @override
  String getNetClientAcceptEncoding() {
    final storage = _getStorage();
    final acceptEncoding = storage.getString(settingsNetClientAcceptEncoding) ??
        defaultNetClientAcceptEncoding;
    return acceptEncoding;
  }

  @override
  String getNetClientAcceptLanguage() {
    final storage = _getStorage();
    final acceptLanguage = storage.getString(settingsNetClientAcceptLanguage) ??
        defaultNetClientAcceptLanguage;
    return acceptLanguage;
  }

  @override
  String getNetClientUserAgent() {
    final storage = _getStorage();
    final userAgent = storage.getString(settingsNetClientUserAgent) ??
        defaultNetClientUserAgent;
    return userAgent;
  }

  @override
  Size getWindowSize() {
    final storage = _getStorage();
    final width = storage.getDouble(settingsWindowWidth) ?? defaultWindowWidth;
    final height =
        storage.getDouble(settingsWindowHeight) ?? defaultWindowHeight;
    return Size(width, height);
  }

  @override
  Future<void> setWindowSize(Size size) async {
    final storage = _getStorage();

    await storage.saveDouble(settingsWindowWidth, size.width);
    await storage.saveDouble(settingsWindowHeight, size.height);
  }

  @override
  Offset getWindowPosition() {
    final storage = _getStorage();
    final dx =
        storage.getDouble(settingsWindowPositionDx) ?? defaultWindowPositionDx;
    final dy =
        storage.getDouble(settingsWindowPositionDy) ?? defaultWindowPositionDy;
    return Offset(dx, dy);
  }

  @override
  Future<void> setWindowPosition(Offset offset) async {
    final storage = _getStorage();

    await storage.saveDouble(settingsWindowPositionDx, offset.dx);
    await storage.saveDouble(settingsWindowPositionDy, offset.dy);
  }

  @override
  bool getWindowInCenter() {
    final storage = _getStorage();
    final inCenter =
        storage.getBool(settingsWindowInCenter) ?? defaultWindowInCenter;
    return inCenter;
  }

  @override
  Future<void> setWindowInCenter({required bool inCenter}) async {
    final storage = _getStorage();
    await storage.saveBool(settingsWindowInCenter, value: inCenter);
    return;
  }

  @override
  int getThemeMode() {
    final storage = _getStorage();
    final themeModeValue =
        storage.getInt(settingsThemeMode) ?? defaultThemeMode;
    return themeModeValue;
  }

  @override
  Future<void> setThemeMode(int themeMode) async {
    final storage = _getStorage();
    await storage.saveInt(settingsThemeMode, themeMode);
  }

  @override
  (String username, int uid) getLoginInfo() {
    final storage = _getStorage();
    final username =
        storage.getString(settingsLoginUsername) ?? defaultLoginUsername;
    final uid = storage.getInt(settingsLoginUid) ?? defaultLoginUid;
    return (username, uid);
  }

  /// Update current login user username.
  ///
  /// Because in some situation we don't know uid (e.g. try to login), use this
  /// [username] to identify user.
  ///
  /// Note that the server side does not allow same username so it's safe to
  /// treat username as user identifier.
  @override
  Future<void> setLoginInfo(String username, int uid) async {
    final storage = _getStorage();

    await storage.saveString(settingsLoginUsername, username);
    await storage.saveInt(settingsLoginUid, uid);
  }

  /// Get a cookie belongs to user with [username].
  ///
  /// Return null if not found.
  @override
  DatabaseCookie? getCookie(String username) {
    final storage = _getStorage();
    return storage.getCookie(username);
  }

  /// Save cookie into database.
  ///
  /// This function should only be called by cookie provider.
  @override
  Future<void> saveCookie(
    String username,
    Map<String, String> cookie,
  ) async {
    final storage = _getStorage();

    return storage.saveCookie(username, cookie);
  }

  /// Delete user [username]'s cookie from database.
  ///
  /// This function should only be called by cookie provider.
  @override
  Future<bool> deleteCookieByUsername(String username) async {
    final storage = _getStorage();

    return storage.deleteCookieByUsername(username);
  }

  @override
  String getLocale() {
    final storage = _getStorage();
    final locale = storage.getString(settingsLocale) ?? defaultLocale;
    return locale;
  }

  @override
  Future<void> setLocale(String locale) async {
    final storage = _getStorage();

    // Filter invalid locales.
    // Empty locale means follow system locale.
    if (locale.isNotEmpty &&
        !AppLocale.values.any((v) => v.languageTag == locale)) {
      return;
    }
    await storage.saveString(settingsLocale, locale);
  }

  @override
  String getCheckinFeeling() {
    final storage = _getStorage();
    final feeling =
        storage.getString(settingsCheckinFeeling) ?? defaultCheckInFeeling;
    return feeling;
  }

  @override
  Future<void> setCheckinFeeling(String feeling) async {
    final storage = _getStorage();
    await storage.saveString(settingsCheckinFeeling, feeling);
  }

  @override
  Future<void> setCheckinMessage(String message) async {
    final storage = _getStorage();
    await storage.saveString(settingsCheckinMessage, message.truncate(50));
  }

  @override
  String getCheckinMessage() {
    final storage = _getStorage();
    final feeling =
        storage.getString(settingsCheckinMessage) ?? defaultCheckInMessage;
    return feeling;
  }

  @override
  bool getShowShortcutInForumCard() {
    final storage = _getStorage();
    final visible = storage.getBool(settingsShowShortcutInForumCard) ??
        defaultShowRedirectInForumCard;
    return visible;
  }

  @override
  Future<void> setShowShortcutInForumCard({required bool visible}) async {
    final storage = _getStorage();
    await storage.saveBool(settingsShowShortcutInForumCard, value: visible);
  }

  @override
  int getAccentColorValue() {
    final storage = _getStorage();
    final colorValue =
        storage.getInt(settingsAccentColor) ?? defaultAccentColor;
    return colorValue;
  }

  @override
  Future<void> setAccentColor(Color color) async {
    final storage = _getStorage();
    await storage.saveInt(settingsAccentColor, color.value);
  }

  @override
  Future<void> clearAccentColor() async {
    final storage = _getStorage();
    await storage.saveInt(settingsAccentColor, -1);
  }
}
