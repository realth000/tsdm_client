import 'dart:ui';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsdm_client/models/settings.dart';

late final _SettingsService _storage;

/// Provider of app settings.
final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>(
  (ref) => SettingsNotifier(),
);

/// Notifier of app settings.
class SettingsNotifier extends StateNotifier<Settings> {
  /// Constructor.
  SettingsNotifier()
      : super(
          Settings(
            dioAccept: _storage.getString('dioAccept') ?? _defaultDioAccept,
            dioAcceptEncoding: _storage.getString('dioAcceptEncoding') ??
                _defaultDioAcceptEncoding,
            dioAcceptLanguage: _storage.getString('dioAcceptLanguage') ??
                _defaultDioAcceptLanguage,
            dioUserAgent:
                _storage.getString('dioUserAgent') ?? _defaultDioUserAgent,
            windowWidth:
                _storage.getDouble('windowWidth') ?? _defaultWindowWidth,
            windowHeight:
                _storage.getDouble('windowHeight') ?? _defaultWindowHeight,
            windowPositionDx: _storage.getDouble('windowPositionDx') ??
                _defaultWindowPositionDx,
            windowPositionDy: _storage.getDouble('windowPositionDy') ??
                _defaultWindowPositionDy,
            windowInCenter:
                _storage.getBool('windowInCenter') ?? _defaultWindowInCenter,
          ),
        );

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

  Future<void> setWindowSize(Size size) async {
    await _storage.saveDouble('windowWidth', size.width);
    await _storage.saveDouble('windowHeight', size.height);
    state = state.copyWith(
      windowPositionDx: size.width,
      windowPositionDy: size.height,
    );
  }

  Future<void> setWindowPosition(Offset offset) async {
    await _storage.saveDouble('windowPositionDx', offset.dx);
    await _storage.saveDouble('windowPositionDy', offset.dy);
    state = state.copyWith(
      windowPositionDx: offset.dx,
      windowPositionDy: offset.dy,
    );
  }
}

/// Init settings, must call before start.
Future<void> initSettings() async {
  _storage = await _SettingsService().init();
}

class _SettingsService {
  late final SharedPreferences _sp;

  Future<_SettingsService> init() async {
    _sp = await SharedPreferences.getInstance();
    return this;
  }

  dynamic get(String key) => _sp.get(key);

  /// Get int type value of specified key.
  int? getInt(String key) => _sp.getInt(key);

  /// Sae int type value of specified key.
  Future<bool> saveInt(String key, int value) async {
    if (!settingsMap.containsKey(key)) {
      return false;
    }
    await _sp.setInt(key, value);
    return true;
  }

  /// Get bool type value of specified key.
  bool? getBool(String key) => _sp.getBool(key);

  /// Save bool type value of specified value.
  Future<bool> saveBool(String key, bool value) async {
    if (!settingsMap.containsKey(key)) {
      return false;
    }
    await _sp.setBool(key, value);
    return true;
  }

  /// Get double type value of specified key.
  double? getDouble(String key) => _sp.getDouble(key);

  /// Save double type value of specified key.
  Future<bool> saveDouble(String key, double value) async {
    if (!settingsMap.containsKey(key)) {
      return false;
    }
    await _sp.setDouble(key, value);
    return true;
  }

  /// Get string type value of specified key.
  String? getString(String key) => _sp.getString(key);

  /// Save string type value of specified key.
  Future<bool> saveString(String key, String value) async {
    if (!settingsMap.containsKey(key)) {
      return false;
    }
    await _sp.setString(key, value);
    return true;
  }

  /// Get string list type value of specified key.
  List<String>? getStringList(String key) => _sp.getStringList(key);

  /// Save string list type value of specified key.
  Future<bool> saveStringList(String key, List<String> value) async {
    if (!settingsMap.containsKey(key)) {
      return false;
    }
    await _sp.setStringList(key, value);
    return true;
  }
}
