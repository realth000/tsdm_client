// ignore_for_file: public_member_api_docs

import 'package:dart_mappable/dart_mappable.dart';

part '../../../../generated/shared/providers/storage_provider/models/settings_map.mapper.dart';

/// Settings map.
@MappableClass()
class SettingsMap with SettingsMapMappable {
  /// Freezed constructor.
  SettingsMap({
    required this.netClientAccept,
    required this.netClientAcceptEncoding,
    required this.netClientAcceptLanguage,
    required this.netClientUserAgent,
    required this.windowWidth,
    required this.windowHeight,
    required this.windowPositionDx,
    required this.windowPositionDy,
    required this.windowInCenter,
    required this.loginUsername,
    required this.loginUid,
    required this.themeMode,
    required this.locale,
    required this.checkinFeeling,
    required this.checkinMessage,
    required this.showShortcutInForumCard,
    required this.accentColor,
    required this.showUnreadInfoHint,
    required this.doublePressExit,
    required this.threadReverseOrder,
    required this.threadCardInfoRowAlignCenter,
    required this.threadCardShowLastReplyAuthor,
  });

  final String netClientAccept;
  final String netClientAcceptEncoding;
  final String netClientAcceptLanguage;
  final String netClientUserAgent;
  final double windowWidth;
  final double windowHeight;
  final double windowPositionDx;
  final double windowPositionDy;
  final bool windowInCenter;
  final String? loginUsername;
  final int? loginUid;
  final int themeMode;
  final String locale;
  final String checkinFeeling;
  final String checkinMessage;
  final bool showShortcutInForumCard;
  final int accentColor;
  final bool showUnreadInfoHint;
  final bool doublePressExit;
  final bool threadReverseOrder;
  final bool threadCardInfoRowAlignCenter;
  final bool threadCardShowLastReplyAuthor;
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
const settingsShowUnreadInfoHint = 'showUnreadInfoHint';
const settingsDoublePressExit = 'doublePressExit';
const settingsThreadReverseOrder = 'threadReverseOrder';
const settingsThreadCardInfoRowAlignCenter = 'threadCardInfoRowAlignCenter';
const settingsThreadCardShowLastReplyAuthor = 'threadCardShowLastReplyAuthor';

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
  settingsShowUnreadInfoHint: bool,
  settingsDoublePressExit: bool,
  settingsThreadReverseOrder: bool,
  settingsThreadCardInfoRowAlignCenter: bool,
  settingsThreadCardShowLastReplyAuthor: bool,
};
