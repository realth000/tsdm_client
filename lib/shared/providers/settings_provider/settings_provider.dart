import 'package:flutter/material.dart';
import 'package:tsdm_client/shared/providers/storage_provider/models/models.dart';

/// Notifier of app settings.
///
/// Can be used by SettingsRepository.
///
/// **DO NOT USE IT ELSEWHERE.**
abstract interface class SettingsProvider {
  /// Get the value of http client header `Accept`.
  String getNetClientAccept();

  /// Get the value of http client header `Accept-Encoding`.
  String getNetClientAcceptEncoding();

  /// Get the value of http client header `Accept-Language`.
  String getNetClientAcceptLanguage();

  /// Get the value of http client header `User-Agent`.
  String getNetClientUserAgent();

  /// Get app window size.
  Size getWindowSize();

  /// Set app window size.
  Future<void> setWindowSize(Size size);

  /// Get app window position.
  Offset getWindowPosition();

  /// Set app window position.
  Future<void> setWindowPosition(Offset offset);

  /// Check the value in settings: windows should be placed in the center of
  /// screen or not.
  bool getWindowInCenter();

  /// Record the app window in screen center or not status.
  Future<void> setWindowInCenter({required bool inCenter});

  /// Get app theme mode index.
  int getThemeMode();

  /// Set app theme mode index.
  Future<void> setThemeMode(int themeMode);

  /// Get current logged user info.
  ///
  /// Return (null, null) if not logged in.
  (String? username, int? uid) getLoginInfo();

  /// Update current login user username.
  ///
  /// Because in some situation we don't know uid (e.g. try to login), use this
  /// [username] to identify user.
  ///
  /// Note that the server side does not allow same username so it's safe to
  /// treat username as user identifier.
  Future<void> setLoginInfo(String? username, int? uid);

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

  /// Get app locale.
  String getLocale();

  /// Set app locale.
  Future<void> setLocale(String locale);

  /// Get user checking feeling.
  String getCheckinFeeling();

  /// Set user checkin feeling.
  Future<void> setCheckinFeeling(String feeling);

  /// Get checkin message.
  String getCheckinMessage();

  /// Set checkin message.
  Future<void> setCheckinMessage(String message);

  /// Get the visibility of shortcuts in forum card in settings.
  bool getShowShortcutInForumCard();

  /// Set the visibility of shortcuts in forum card in settings.
  Future<void> setShowShortcutInForumCard({required bool visible});

  /// [Color]'s value.
  int getAccentColorValue();

  /// Set app accent color.
  Future<void> setAccentColor(Color color);

  /// Reset app accent color to default.
  Future<void> clearAccentColor();
}
