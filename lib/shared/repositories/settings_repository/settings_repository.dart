import 'dart:async';

import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/storage_provider/models/database/database.dart';
import 'package:tsdm_client/shared/providers/storage_provider/models/settings_map.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';
import 'package:tsdm_client/shared/repositories/settings_repository/mixin/settings_default_mixin.dart';
import 'package:tsdm_client/utils/logger.dart';

typedef _SK = SettingsKeys;

extension _ExtractExt on List<SettingsEntity> {
  T extract<T>(String name, T fallback) {
    final v = firstWhereOrNull((e) => e.name == name);
    if (v == null) {
      return fallback;
    }
    return (switch (T) {
          int => v.intValue,
          double => v.doubleValue,
          String => v.stringValue,
          bool => v.boolValue,
          _ => null,
        } ??
        fallback) as T;
  }
}

/// Settings repository of this app.
///
/// **Need to call dispose** before dispose.
final class SettingsRepository with SettingsDefaultMapMixin, LoggerMixin {
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
      netClientAccept: s.extract(_SK.netClientAccept, defaultNetClientAccept),
      netClientAcceptEncoding: s.extract(
        _SK.netClientAcceptEncoding,
        defaultNetClientAcceptEncoding,
      ),
      netClientAcceptLanguage: s.extract(
        _SK.netClientAcceptLanguage,
        defaultNetClientAcceptLanguage,
      ),
      netClientUserAgent:
          s.extract(_SK.netClientUserAgent, defaultNetClientUserAgent),
      windowWidth: s.extract(_SK.windowWidth, defaultWindowWidth),
      windowHeight: s.extract(_SK.windowHeight, defaultWindowHeight),
      windowPositionDx:
          s.extract(_SK.windowPositionDx, defaultWindowPositionDx),
      windowPositionDy:
          s.extract(_SK.windowPositionDy, defaultWindowPositionDy),
      windowInCenter: s.extract(_SK.windowInCenter, defaultWindowInCenter),
      loginUsername: s.extract(_SK.loginUsername, defaultLoginUsername),
      loginUid: s.extract(_SK.loginUid, defaultLoginUid),
      themeMode: s.extract(_SK.themeMode, defaultThemeMode),
      locale: s.extract(_SK.locale, defaultLocale),
      checkinFeeling: s.extract(_SK.checkinFeeling, defaultCheckInFeeling),
      checkinMessage: s.extract(_SK.checkinMessage, defaultCheckInMessage),
      showShortcutInForumCard: s.extract(
        _SK.showShortcutInForumCard,
        defaultShowRedirectInForumCard,
      ),
      accentColor: s.extract(_SK.accentColor, defaultAccentColor),
      showUnreadInfoHint:
          s.extract(_SK.showUnreadInfoHint, defaultShowUnreadInfoHint),
      doublePressExit: s.extract(_SK.doublePressExit, defaultDoublePressExit),
      threadReverseOrder:
          s.extract(_SK.threadReverseOrder, defaultThreadReverseOrder),
      threadCardInfoRowAlignCenter: s.extract(
        _SK.threadCardInfoRowAlignCenter,
        defaultThreadCardInfoRowAlignCenter,
      ),
      threadCardShowLastReplyAuthor: s.extract(
        SettingsKeys.threadCardShowLastReplyAuthor,
        defaultThreadCardShowLastReplyAuthor,
      ),
    );
  }

  /// Dispose settings repository instance.
  void dispose() {
    _controller.close();
  }

  Future<T?> getValue<T>(String key) async {
    if (!settingsTypeMap.containsKey(key)) {
      error('failed to getValue: unknown settings name "$key"');
      return null;
    }
    if (settingsTypeMap[key] != T) {
      error('failed to getValue: settings type mismatch: "$key" is not $T ');
      return null;
    }

    // TODO: Implement
  }

  /// Save settings [key] with value [value].
  Future<void> setValue<T>(String key, T value) async {
    if (!settingsTypeMap.containsKey(key)) {
      error('failed to setValue: unknown settings name "$key"');
      return;
    }
    if (settingsTypeMap[key] != T) {
      error('failed to setValue: settings type mismatch: "$key" is not $T ');
      return;
    }
    final _ = await switch (T) {
      int => _storage.saveInt(key, value as int),
      double => _storage.saveDouble(key, value as double),
      String => _storage.saveString(key, value as String),
      bool => _storage.saveBool(key, value: value as bool),
      final t => () {
          error('failed to save settings for key $key:'
              ' unsupported type in storage: $t');
        }(),
    };

    _state = _state.copyWithKey(key, value);
    _controller.add(_state);
  }
}
