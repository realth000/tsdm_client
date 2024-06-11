import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/shared/providers/settings_provider/database_settings_provider.dart';
import 'package:tsdm_client/shared/providers/settings_provider/settings_provider.dart';
import 'package:tsdm_client/shared/providers/storage_provider/models/models.dart';

/// Settings repository of this app.
///
/// **Need to call dispose** before dispose.
class SettingsRepository {
  /// Constructor.
  SettingsRepository({SettingsProvider? settingsProvider})
      : _settingsProvider = settingsProvider ?? DatabaseSettingsProvider() {
    _state = _initMap();
    _controller.add(_state);
  }

  /// Controller of [SettingsMap] stream.
  final _controller = BehaviorSubject<SettingsMap>();

  /// Stream of [SettingsMap].
  ///
  /// Current settings stream.
  Stream<SettingsMap> get settings async* {
    yield* _controller.asBroadcastStream();
  }

  /// Get current [SettingsMap].
  SettingsMap get currentSettings => _state;

  /// Provider of settings, implementation of storage.
  final SettingsProvider _settingsProvider;

  /// Current settings.
  late SettingsMap _state;

  /// Load settings from [_settingsProvider].
  ///
  /// Some settings use default value directly.
  SettingsMap _initMap() {
    final windowSize = _settingsProvider.getWindowSize();
    final windowPosition = _settingsProvider.getWindowPosition();
    final loggedUserInfo = _settingsProvider.getLoginInfo();
    return SettingsMap(
      netClientAccept: _settingsProvider.getNetClientAccept(),
      netClientAcceptEncoding: _settingsProvider.getNetClientAcceptEncoding(),
      netClientAcceptLanguage: _settingsProvider.getNetClientAcceptLanguage(),
      netClientUserAgent: _settingsProvider.getNetClientUserAgent(),
      windowWidth: windowSize.width,
      windowHeight: windowSize.height,
      windowPositionDx: windowPosition.dx,
      windowPositionDy: windowPosition.dy,
      windowInCenter: _settingsProvider.getWindowInCenter(),
      loginUsername: loggedUserInfo.$1,
      loginUid: loggedUserInfo.$2,
      themeMode: _settingsProvider.getThemeMode(),
      locale: _settingsProvider.getLocale(),
      checkinFeeling: _settingsProvider.getCheckinFeeling(),
      checkinMessage: _settingsProvider.getCheckinMessage(),
      showShortcutInForumCard: _settingsProvider.getShowShortcutInForumCard(),
      accentColor: _settingsProvider.getAccentColorValue(),
      showUnreadInfoHint: _settingsProvider.getShowUnreadInfoHint(),
      doublePressExit: _settingsProvider.getDoublePressExit(),
      threadReverseOrder: _settingsProvider.getThreadReverseOrder(),
    );
  }

  /// Dispose settings repository instance.
  void dispose() {
    _controller.close();
  }

  /// Get the current app window size.
  Size getWindowSize() => _settingsProvider.getWindowSize();

  /// Set the app window size.
  Future<void> setWindowSize(Size size) async {
    await _settingsProvider.setWindowSize(size);
    _state = _state.copyWith(
      windowPositionDx: size.width,
      windowPositionDy: size.height,
    );
    _controller.add(_state);
  }

  /// Get app window position.
  Offset getWindowPosition() => _settingsProvider.getWindowPosition();

  /// Set app window position.
  Future<void> setWindowPosition(Offset offset) async {
    await _settingsProvider.setWindowPosition(offset);
    _state = _state.copyWith(
      windowPositionDx: offset.dx,
      windowPositionDy: offset.dy,
    );
    _controller.add(_state);
  }

  /// Get status of app window in center of screen.
  bool getWindowInCenter() => _settingsProvider.getWindowInCenter();

  /// Set status of app window in center of screen.
  Future<void> setWindowInCenter({required bool inCenter}) async {
    await _settingsProvider.setWindowInCenter(inCenter: inCenter);
    _state = _state.copyWith(windowInCenter: inCenter);
    _controller.add(_state);
  }

  /// Get app theme mode index.
  int getThemeMode() => _settingsProvider.getThemeMode();

  /// Set app theme mode index.
  Future<void> setThemeMode(int themeMode) async {
    await _settingsProvider.setThemeMode(themeMode);
    _state = _state.copyWith(themeMode: themeMode);
    _controller.add(_state);
  }

  /// Get current logged user info.
  ///
  /// Return (null, null) if no user logged.
  (String? username, int? uid) getLoginInfo() =>
      _settingsProvider.getLoginInfo();

  /// Update current login user username.
  ///
  /// Because in some situation we don't know uid (e.g. try to login), use this
  /// [username] to identify user.
  ///
  /// Note that the server side does not allow same username so it's safe to
  /// treat username as user identifier.
  Future<void> setLoginInfo(String username, int uid) async {
    await _settingsProvider.setLoginInfo(username, uid);
    _state = _state.copyWith(loginUsername: username, loginUid: uid);
    _controller.add(_state);
  }

  /// Get a cookie belongs to user with [username].
  ///
  /// Return null if not found.
  DatabaseCookie? getCookie(String username) =>
      _settingsProvider.getCookie(username);

  /// Save cookie into database.
  ///
  /// This function should only be called by cookie provider.
  Future<void> saveCookie(String username, Map<String, String> cookie) async =>
      _settingsProvider.saveCookie(username, cookie);

  /// Delete user [username]'s cookie from database.
  ///
  /// This function should only be called by cookie provider.
  Future<bool> deleteCookieByUsername(String username) async =>
      _settingsProvider.deleteCookieByUsername(username);

  /// Get app locale.
  String getLocale() => _settingsProvider.getLocale();

  /// Set app locale.
  Future<void> setLocale(String locale) async {
    await _settingsProvider.setLocale(locale);
    _state = _state.copyWith(locale: locale);
    _controller.add(_state);
  }

  /// Get checkin feeling.
  String getCheckinFeeling() => _settingsProvider.getCheckinFeeling();

  /// Set checkin feeling.
  Future<void> setCheckinFeeling(String feeling) async {
    await _settingsProvider.setCheckinFeeling(feeling);
    _state = _state.copyWith(checkinFeeling: feeling);
    _controller.add(_state);
  }

  /// Get checkin message.
  String getCheckinMessage() => _settingsProvider.getCheckinMessage();

  /// Set checkin message.
  Future<void> setCheckinMessage(String message) async {
    await _settingsProvider.setCheckinMessage(message);
    _state = _state.copyWith(checkinMessage: message.truncate(50));
    _controller.add(_state);
  }

  /// Get visibility of shortcut on forum card.
  bool getShowShortcutInForumCard() =>
      _settingsProvider.getShowShortcutInForumCard();

  /// Set visibility of shortcut on forum card.
  Future<void> setShowShortcutInForumCard({required bool visible}) async {
    await _settingsProvider.setShowShortcutInForumCard(visible: visible);
    _state = _state.copyWith(showShortcutInForumCard: visible);
    _controller.add(_state);
  }

  /// [Color]'s value.
  int getAccentColorValue() => _settingsProvider.getAccentColorValue();

  /// Get app accent color.
  Future<void> setAccentColor(Color color) async {
    await _settingsProvider.setAccentColor(color);
    _state = _state.copyWith(accentColor: color.value);
    _controller.add(_state);
  }

  /// Reset app accent color to default.
  Future<void> clearAccentColor() async {
    await _settingsProvider.clearAccentColor();
    _state = _state.copyWith(accentColor: -1);
    _controller.add(_state);
  }

  /// Get the current visibility of unread info hint.
  bool getShowUnreadInfoHint() => _settingsProvider.getShowUnreadInfoHint();

  /// Set the visibility of unread info hint.
  Future<void> setShowUnreadInfoHint({required bool enabled}) async {
    await _settingsProvider.setShowUnreadInfoHint(enabled: enabled);
    _state = _state.copyWith(showUnreadInfoHint: enabled);
    _controller.add(_state);
  }

  /// Get the state of double press exit feature.
  bool getDoublePressExit() => _settingsProvider.getDoublePressExit();

  /// Set the state of double press exit feature.
  Future<void> setDoublePressExit({required bool enabled}) async {
    await _settingsProvider.setDoublePressExit(enabled: enabled);
    _state = _state.copyWith(doublePressExit: enabled);
    _controller.add(_state);
  }

  /// Get the state of reverse posts in thread feature.
  bool getThreadReverseOrder() => _settingsProvider.getThreadReverseOrder();

  /// Set the state of revers posts in thread feature.
  Future<void> setThreadReverseOrder({required bool enabled}) async {
    await _settingsProvider.setThreadReverseOrder(enabled: enabled);
    _state = _state.copyWith(threadReverseOrder: enabled);
    _controller.add(_state);
  }
}
