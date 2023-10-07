import 'package:freezed_annotation/freezed_annotation.dart';

part '../generated/models/settings.freezed.dart';

/// Settings for Dio.
@freezed
class Settings with _$Settings {
  /// Freezed constructor.
  const factory Settings({
    required String dioAccept,
    required String dioAcceptEncoding,
    required String dioAcceptLanguage,
    required String dioUserAgent,
    required double windowWidth,
    required double windowHeight,
    required double windowPositionDx,
    required double windowPositionDy,
    required bool windowInCenter,
    required int loginUserUid,
    required String loginUsername,
    required int themeMode,
  }) = _Settings;
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
const settingsLoginUserUid = 'loginUserUid';
const settingsLoginUsername = 'loginUsername';
const settingsThemeMode = 'ThemeMode';

/// All settings names (as keys) and settings value types (as values).
const settingsMap = <String, Type>{
  settingsNetClientAccept: String,
  settingsNetClientAcceptEncoding: String,
  settingsNetClientAcceptLanguage: String,
  settingsNetClientUserAgent: String,
  settingsWindowWidth: double,
  settingsWindowHeight: double,
  settingsWindowPositionDx: double,
  settingsWindowPositionDy: double,
  settingsWindowInCenter: bool,
  settingsLoginUserUid: int,
  settingsLoginUsername: String,
  settingsThemeMode: int,
};
