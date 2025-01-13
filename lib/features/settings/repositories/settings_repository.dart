import 'dart:async';
import 'dart:io' if (dart.libaray.js) 'package:web/web.dart';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/storage_provider/models/database/database.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';
import 'package:tsdm_client/utils/logger.dart';

typedef _SK<T> = SettingsKeys<T>;

extension _ExtractExt on List<SettingsEntity> {
  T extract<T>(SettingsKeys<T> settings) {
    assert(
      T == settings.type,
      'Settings value type and expected extract type MUST equal\n'
      'expected ${settings.type}, but got $T',
    );

    final v = firstWhereOrNull((e) => e.name == settings.name);
    if (v == null) {
      return settings.defaultValue;
    }
    return (switch (T) {
          // ref: https://github.com/dart-lang/sdk/issues/59334
          // ignore: type_literal_in_constant_pattern
          int => v.intValue,
          // ref: https://github.com/dart-lang/sdk/issues/59334
          // ignore: type_literal_in_constant_pattern
          double => v.doubleValue,
          // ref: https://github.com/dart-lang/sdk/issues/59334
          // ignore: type_literal_in_constant_pattern
          String => v.stringValue,
          // ref: https://github.com/dart-lang/sdk/issues/59334
          // ignore: type_literal_in_constant_pattern
          bool => v.boolValue,
          // ref: https://github.com/dart-lang/sdk/issues/59334
          // ignore: type_literal_in_constant_pattern
          DateTime => v.dateTimeValue,
          // ref: https://github.com/dart-lang/sdk/issues/59334
          // ignore: type_literal_in_constant_pattern
          Offset => v.offsetValue,
          // ref: https://github.com/dart-lang/sdk/issues/59334
          // ignore: type_literal_in_constant_pattern
          Size => v.sizeValue,
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
      windowRememberSize: s.extract(_SK.windowRememberSize),
      windowSize: s.extract(_SK.windowSize),
      windowRememberPosition: s.extract(_SK.windowRememberPosition),
      windowPosition: s.extract(_SK.windowPosition),
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
      accentColorFollowSystem: s.extract(_SK.accentColorFollowSystem),
      showUnreadInfoHint: s.extract(_SK.showUnreadInfoHint),
      doublePressExit: s.extract(_SK.doublePressExit),
      threadReverseOrder: s.extract(_SK.threadReverseOrder),
      threadCardInfoRowAlignCenter: s.extract(_SK.threadCardInfoRowAlignCenter),
      threadCardShowLastReplyAuthor:
          s.extract(_SK.threadCardShowLastReplyAuthor),
      threadCardHighlightRecentThread:
          s.extract(_SK.threadCardHighlightRecentThread),
      threadCardHighlightAuthorName:
          s.extract(_SK.threadCardHighlightAuthorName),
      threadCardHighlightInfoRow: s.extract(_SK.threadCardHighlightInfoRow),
      netClientUseProxy: s.extract(_SK.netClientUseProxy),
      netClientProxy: s.extract(_SK.netClientProxy),
      autoCheckin: s.extract(_SK.autoCheckin),
      showUnreadNoticeBadge: s.extract(_SK.showUnreadNoticeBadge),
      showUnreadPersonalMessageBadge:
          s.extract(_SK.showUnreadPersonalMessageBadge),
      showUnreadBroadcastMessageBadge:
          s.extract(_SK.showUnreadBroadcastMessageBadge),
      autoSyncNoticeSeconds: s.extract(_SK.autoSyncNoticeSeconds),
      enableDebugOperations: s.extract(_SK.enableDebugOperations),
      fontFamily: s.extract(_SK.fontFamily),
    );
  }

  /// Dispose settings repository instance.
  void dispose() {
    _controller.close();
  }

  /// Get settings [key] with value in type [T}.
  Future<T> getValue<T>(SettingsKeys<T> key) async {
    assert(
      T == key.type,
      'Settings value type and expected extract type MUST equal\n'
      'expected ${key.type}, but got $T',
    );

    final name = key.name;
    final v = await switch (T) {
      // ref: https://github.com/dart-lang/sdk/issues/59334
      // ignore: type_literal_in_constant_pattern
      int => _storage.getInt(name),
      // ref: https://github.com/dart-lang/sdk/issues/59334
      // ignore: type_literal_in_constant_pattern
      double => _storage.getDouble(name),
      // ref: https://github.com/dart-lang/sdk/issues/59334
      // ignore: type_literal_in_constant_pattern
      String => _storage.getString(name),
      // ref: https://github.com/dart-lang/sdk/issues/59334
      // ignore: type_literal_in_constant_pattern
      bool => _storage.getBool(name),
      // ref: https://github.com/dart-lang/sdk/issues/59334
      // ignore: type_literal_in_constant_pattern
      DateTime => _storage.getDateTime(name),
      // ref: https://github.com/dart-lang/sdk/issues/59334
      // ignore: type_literal_in_constant_pattern
      Offset => _storage.getOffset(name),
      // ref: https://github.com/dart-lang/sdk/issues/59334
      // ignore: type_literal_in_constant_pattern
      Size => _storage.getSize(name),
      _ => () {
          error('failed to getValue for key $key: unsupported type $T');
          return null;
        }()
    };
    return (v ?? key.defaultValue) as T;
  }

  /// Delete the settings record in database.
  Future<void> deleteValue<T>(SettingsKeys<T> key) async {
    await _storage.deleteKey(key.name);
    _state = _state.copyWithKey(key, null);
    _controller.add(_state);
  }

  /// Save settings [key] with value [value].
  Future<void> setValue<T>(SettingsKeys<T> key, T value) async {
    assert(
      T == key.type,
      'Settings value type and expected extract type MUST equal\n'
      'expected ${key.type}, but got $T',
    );

    final name = key.name;
    final _ = await switch (T) {
      // ref: https://github.com/dart-lang/sdk/issues/59334
      // ignore: type_literal_in_constant_pattern
      int => _storage.saveInt(name, value as int),
      // ref: https://github.com/dart-lang/sdk/issues/59334
      // ignore: type_literal_in_constant_pattern
      double => _storage.saveDouble(name, value as double),
      // ref: https://github.com/dart-lang/sdk/issues/59334
      // ignore: type_literal_in_constant_pattern
      String => _storage.saveString(name, value as String),
      // ref: https://github.com/dart-lang/sdk/issues/59334
      // ignore: type_literal_in_constant_pattern
      bool => _storage.saveBool(name, value: value as bool),
      // ref: https://github.com/dart-lang/sdk/issues/59334
      // ignore: type_literal_in_constant_pattern
      DateTime => _storage.saveDateTime(name, value as DateTime),
      // ref: https://github.com/dart-lang/sdk/issues/59334
      // ignore: type_literal_in_constant_pattern
      Offset => _storage.saveOffset(name, value as Offset),
      // ref: https://github.com/dart-lang/sdk/issues/59334
      // ignore: type_literal_in_constant_pattern
      Size => _storage.saveSize(name, value as Size),
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
        // HttpHeaders.hostHeader: baseUrl,
        // HttpHeaders.pragmaHeader: 'no-cache',
      },
    );
}
