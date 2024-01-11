import 'package:freezed_annotation/freezed_annotation.dart';

part '../../../../generated/shared/providers/storage_provider/models/settings_map.freezed.dart';

/// Settings map.
@freezed
class SettingsMap with _$SettingsMap {
  /// Freezed constructor.
  const factory SettingsMap({
    required String netClientAccept,
    required String netClientAcceptEncoding,
    required String netClientAcceptLanguage,
    required String netClientUserAgent,
    required double windowWidth,
    required double windowHeight,
    required double windowPositionDx,
    required double windowPositionDy,
    required bool windowInCenter,
    required String loginUsername,
    required int loginUid,
    required int themeMode,
    required String locale,
    required String checkinFeeling,
    required String checkinMessage,
    required bool showShortcutInForumCard,
    required int accentColor,
  }) = _SettingsMap;
}

const settingsNetClientAccept = 'dioAccept';
const settingsNetClientAcceptEncoding = 'dioAcceptEncoding';
const settingsNetClientAcceptLanguage = 'dioAcceptLanguage';
const settingsNetClientUserAgent = 'dioUserAgent';
const settingsWindowWidth = 'windowWidth';
const settingsWindowHeight = 'windowHeight';
const settingsWindowPositionDx = 'windowPositionX';
const settingsWindowPositionDy = 'windowPositionY';
const settingsWindowInCenter = 'windowInCenter';
const settingsLoginUsername = 'loginUsername';
const settingsLoginUid = 'loginUid';
const settingsThemeMode = 'ThemeMode';
const settingsLocale = 'locale';
const settingsCheckinFeeling = 'checkInFeeling';
const settingsCheckinMessage = 'checkInMessage';
const settingsShowShortcutInForumCard = 'showShortcutInForumCard';
const settingsAccentColor = 'accentColor';

/// All settings names (as keys) and settings value types (as values).
const settingsTypeMap = <String, Type>{
  settingsNetClientAccept: String,
  settingsNetClientAcceptEncoding: String,
  settingsNetClientAcceptLanguage: String,
  settingsNetClientUserAgent: String,
  settingsWindowWidth: double,
  settingsWindowHeight: double,
  settingsWindowPositionDx: double,
  settingsWindowPositionDy: double,
  settingsWindowInCenter: bool,
  settingsLoginUsername: String,
  settingsLoginUid: int,
  settingsThemeMode: int,
  settingsLocale: String,
  settingsCheckinFeeling: String,
  settingsCheckinMessage: String,
  settingsShowShortcutInForumCard: bool,
  settingsAccentColor: int,
};
