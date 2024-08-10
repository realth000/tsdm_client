import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/storage_provider/models/database/database.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';
import 'package:tsdm_client/utils/logger.dart';

typedef _SK = SettingsKeys;

extension _ExtractExt on List<SettingsEntity> {
  T extract<T>(SettingsKeys settings) {
    assert(
      T == settings.type,
      'Settings value type and expected extract type MUST equal',
    );

    final v = firstWhereOrNull((e) => e.name == settings.name);
    if (v == null) {
      return settings.defaultValue as T;
    }
    return (switch (T) {
          int => v.intValue,
          double => v.doubleValue,
          String => v.stringValue,
          bool => v.boolValue,
          _ => null,
        } ??
        settings.defaultValue) as T;
  }
}

/// Settings repository of this app.
///
/// **Need to call dispose** before dispose.
final class SettingsRepository with LoggerMixin {
  /// Constructor.
  SettingsRepository(this._storage);

  final StorageProvider _storage;

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

  /// Current settings.
  late SettingsMap _state;

  /// Init initial settings.
  Future<void> init() async {
    _state = await _initMap();
    _controller.add(_state);
  }

  /// Load settings from storage.
  ///
  /// Some settings use default value directly.
  Future<SettingsMap> _initMap() async {
    final s = await _storage.getAllSettings();

    return SettingsMap(
      netClientAccept: s.extract(_SK.netClientAccept),
      netClientAcceptEncoding: s.extract(_SK.netClientAcceptEncoding),
      netClientAcceptLanguage: s.extract(_SK.netClientAcceptLanguage),
      netClientUserAgent: s.extract(_SK.netClientUserAgent),
      windowWidth: s.extract(_SK.windowWidth),
      windowHeight: s.extract(_SK.windowHeight),
      windowPositionDx: s.extract(_SK.windowPositionDx),
      windowPositionDy: s.extract(_SK.windowPositionDy),
      windowInCenter: s.extract(_SK.windowInCenter),
      loginUsername: s.extract(_SK.loginUsername),
      loginUid: s.extract(_SK.loginUid),
      loginEmail: s.extract(_SK.loginEmail),
      themeMode: s.extract(_SK.themeMode),
      locale: s.extract(_SK.locale),
      checkinFeeling: s.extract(_SK.checkinFeeling),
      checkinMessage: s.extract(_SK.checkinMessage),
      showShortcutInForumCard: s.extract(_SK.showShortcutInForumCard),
      accentColor: s.extract(_SK.accentColor),
      showUnreadInfoHint: s.extract(_SK.showUnreadInfoHint),
      doublePressExit: s.extract(_SK.doublePressExit),
      threadReverseOrder: s.extract(_SK.threadReverseOrder),
      threadCardInfoRowAlignCenter: s.extract(_SK.threadCardInfoRowAlignCenter),
      threadCardShowLastReplyAuthor:
          s.extract(SettingsKeys.threadCardShowLastReplyAuthor),
    );
  }

  /// Dispose settings repository instance.
  void dispose() {
    _controller.close();
  }

  /// Get settings [key] with value in type [T}.
  Future<T> getValue<T>(SettingsKeys key) async {
    assert(
      T == key.type,
      'Settings value type and expected extract type MUST equal',
    );

    final name = key.name;
    return await switch (T) {
      int => _storage.getInt(name),
      double => _storage.getDouble(name),
      String => _storage.getString(name),
      bool => _storage.getBool(name),
      _ => () {
            error('failed to getValue for key $key: unsupported type $T');
            return null;
          }() ??
          key.defaultValue
    } as T;
  }

  /// Delete the settings record in database.
  Future<void> deleteValue(SettingsKeys key) async {
    await _storage.deleteKey(key.name);
    _state = _state.copyWithKey(key, null);
    _controller.add(_state);
  }

  /// Save settings [key] with value [value].
  Future<void> setValue<T>(SettingsKeys key, T value) async {
    assert(
      T == key.type,
      'Settings value type and expected extract type MUST equal',
    );

    final name = key.name;
    final _ = await switch (T) {
      int => _storage.saveInt(name, value as int),
      double => _storage.saveDouble(name, value as double),
      String => _storage.saveString(name, value as String),
      bool => _storage.saveBool(name, value: value as bool),
      final t => () {
          error('failed to save settings for key $key:'
              ' unsupported type in storage: $t');
        }(),
    };

    _state = _state.copyWithKey(key, value);
    _controller.add(_state);
  }

  /// Build a default [Dio] instance from current settings.
  Dio buildDefaultDio() => Dio()
    ..options = BaseOptions(
      headers: <String, String>{
        HttpHeaders.acceptHeader: _state.netClientAccept,
        HttpHeaders.acceptEncodingHeader: _state.netClientAcceptEncoding,
        HttpHeaders.acceptLanguageHeader: _state.netClientAcceptLanguage,
        HttpHeaders.userAgentHeader: _state.netClientUserAgent,
      },
    );
}
