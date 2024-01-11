import 'package:flutter/material.dart';
import 'package:tsdm_client/shared/providers/storage_provider/models/models.dart';

/// Notifier of app settings.
///
/// Can be used by SettingsRepository.
///
/// **DO NOT USE IT ELSEWHERE.**
abstract interface class SettingsProvider {
  String getNetClientAccept();

  String getNetClientAcceptEncoding();

  String getNetClientAcceptLanguage();

  String getNetClientUserAgent();

  Size getWindowSize();

  Future<void> setWindowSize(Size size);

  Offset getWindowPosition();

  Future<void> setWindowPosition(Offset offset);

  bool getWindowInCenter();

  Future<void> setWindowInCenter({required bool inCenter});

  int getThemeMode();

  Future<void> setThemeMode(int themeMode);

  (String username, int uid) getLoginInfo();

  /// Update current login user username.
  ///
  /// Because in some situation we don't know uid (e.g. try to login), use this
  /// [username] to identify user.
  ///
  /// Note that the server side does not allow same username so it's safe to
  /// treat username as user identifier.
  Future<void> setLoginInfo(String username, int uid);

  /// Get a cookie belongs to user with [username].
  ///
  /// Return null if not found.
  DatabaseCookie? getCookie(String username);

  /// Save cookie into database.
  ///
  /// This function should only be called by cookie provider.
  Future<void> saveCookie(String username, Map<String, String> cookie);

  /// Delete user [username]'s cookie from database.
  ///
  /// This function should only be called by cookie provider.
  Future<bool> deleteCookieByUsername(String username);

  String getLocale();

  Future<void> setLocale(String locale);

  String getCheckinFeeling();

  Future<void> setCheckinFeeling(String feeling);

  String getCheckinMessage();

  Future<void> setCheckinMessage(String message);

  bool getShowShortcutInForumCard();

  Future<void> setShowShortcutInForumCard({required bool visible});

  /// [Color]'s value.
  int getAccentColorValue();

  Future<void> setAccentColor(Color color);

  Future<void> clearAccentColor();
}
