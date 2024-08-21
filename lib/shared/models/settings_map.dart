// ignore_for_file: public_member_api_docs

part of 'models.dart';

/// All settings and their keys.
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
    required this.loginEmail,
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
    required this.threadCardHighlightRecentThread,
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
  final String loginUsername;
  final int loginUid;
  final String loginEmail;
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
  final bool threadCardHighlightRecentThread;

  SettingsMap copyWithKey<T>(SettingsKeys<T> key, T? value) {
    assert(
      T == key.type || T.toString() == '${key.type}?',
      'Settings value type and expected extract type MUST equal\n'
      'expected ${key.type}, but got $T',
    );

    return switch (key) {
      SettingsKeys.netClientAccept =>
        copyWith(netClientAccept: value as String?),
      SettingsKeys.netClientAcceptEncoding =>
        copyWith(netClientAcceptEncoding: value as String?),
      SettingsKeys.netClientAcceptLanguage =>
        copyWith(netClientAcceptLanguage: value as String?),
      SettingsKeys.netClientUserAgent =>
        copyWith(netClientUserAgent: value as String?),
      SettingsKeys.windowWidth => copyWith(windowWidth: value as double?),
      SettingsKeys.windowHeight => copyWith(windowHeight: value as double?),
      SettingsKeys.windowPositionDx =>
        copyWith(windowPositionDx: value as double?),
      SettingsKeys.windowPositionDy =>
        copyWith(windowPositionDy: value as double?),
      SettingsKeys.windowInCenter => copyWith(windowInCenter: value as bool?),
      SettingsKeys.loginUsername => copyWith(loginUsername: value as String?),
      SettingsKeys.loginUid => copyWith(loginUid: value as int?),
      SettingsKeys.loginEmail => copyWith(loginEmail: value as String?),
      SettingsKeys.themeMode => copyWith(themeMode: value as int?),
      SettingsKeys.locale => copyWith(locale: value as String?),
      SettingsKeys.checkinFeeling => copyWith(checkinFeeling: value as String?),
      SettingsKeys.checkinMessage => copyWith(checkinMessage: value as String?),
      SettingsKeys.showShortcutInForumCard =>
        copyWith(showShortcutInForumCard: value as bool?),
      SettingsKeys.accentColor => copyWith(accentColor: value as int?),
      SettingsKeys.showUnreadInfoHint =>
        copyWith(showUnreadInfoHint: value as bool?),
      SettingsKeys.doublePressExit => copyWith(doublePressExit: value as bool?),
      SettingsKeys.threadReverseOrder =>
        copyWith(threadReverseOrder: value as bool?),
      SettingsKeys.threadCardInfoRowAlignCenter =>
        copyWith(threadCardInfoRowAlignCenter: value as bool?),
      SettingsKeys.threadCardShowLastReplyAuthor =>
        copyWith(threadCardShowLastReplyAuthor: value as bool?),
      SettingsKeys.threadCardHighlightRecentThread =>
        copyWith(threadCardHighlightRecentThread: value as bool?),
    };
  }
}
