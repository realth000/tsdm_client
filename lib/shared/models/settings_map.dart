// All public fields in the map is defined in settings keys.
// ignore_for_file: public_member_api_docs

part of 'models.dart';

/// All settings and their keys.
@MappableClass()
class SettingsMap with SettingsMapMappable {
  /// Constructor.
  const SettingsMap({
    required this.netClientAccept,
    required this.netClientAcceptEncoding,
    required this.netClientAcceptLanguage,
    required this.netClientUserAgent,
    required this.windowRememberSize,
    required this.windowSize,
    required this.windowRememberPosition,
    required this.windowPosition,
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
    required this.accentColorFollowSystem,
    required this.showUnreadInfoHint,
    required this.doublePressExit,
    required this.threadReverseOrder,
    required this.threadCardInfoRowAlignCenter,
    required this.threadCardShowLastReplyAuthor,
    required this.threadCardHighlightRecentThread,
    required this.threadCardHighlightAuthorName,
    required this.threadCardHighlightInfoRow,
    required this.netClientProxy,
    required this.netClientUseProxy,
    required this.autoCheckin,
    required this.showUnreadNoticeBadge,
    required this.showUnreadPersonalMessageBadge,
    required this.showUnreadBroadcastMessageBadge,
    required this.autoSyncNoticeSeconds,
    required this.enableDebugOperations,
    required this.fontFamily,
    required this.enableEditorBBCodeParser,
    required this.enableUpdateCheckOnStartup,
    required this.editorRecentUsedCustomColors,
  });

  final String netClientAccept;
  final String netClientAcceptEncoding;
  final String netClientAcceptLanguage;
  final String netClientUserAgent;
  final bool windowRememberSize;
  final Size windowSize;
  final bool windowRememberPosition;
  final Offset windowPosition;
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
  final bool accentColorFollowSystem;
  final bool showUnreadInfoHint;
  final bool doublePressExit;
  final bool threadReverseOrder;
  final bool threadCardInfoRowAlignCenter;
  final bool threadCardShowLastReplyAuthor;
  final bool threadCardHighlightRecentThread;
  final bool threadCardHighlightAuthorName;
  final bool threadCardHighlightInfoRow;
  final String netClientProxy;
  final bool netClientUseProxy;
  final bool autoCheckin;
  final bool showUnreadNoticeBadge;
  final bool showUnreadPersonalMessageBadge;
  final bool showUnreadBroadcastMessageBadge;
  final int autoSyncNoticeSeconds;
  final bool enableDebugOperations;
  final String fontFamily;
  final bool enableEditorBBCodeParser;
  final bool enableUpdateCheckOnStartup;
  final List<int> editorRecentUsedCustomColors;

  SettingsMap copyWithKey<T>(SettingsKeys<T> key, T? value) {
    assert(
      T == key.type || T.toString() == '${key.type}?',
      'Settings value type and expected extract type MUST equal\n'
      'expected ${key.type}, but got $T',
    );

    return switch (key) {
      SettingsKeys.netClientAccept => copyWith(netClientAccept: value as String?),
      SettingsKeys.netClientAcceptEncoding => copyWith(netClientAcceptEncoding: value as String?),
      SettingsKeys.netClientAcceptLanguage => copyWith(netClientAcceptLanguage: value as String?),
      SettingsKeys.netClientUserAgent => copyWith(netClientUserAgent: value as String?),
      SettingsKeys.windowRememberSize => copyWith(windowRememberSize: value as bool?),
      SettingsKeys.windowSize => copyWith(windowSize: value as Size?),
      SettingsKeys.windowRememberPosition => copyWith(windowRememberPosition: value as bool?),
      SettingsKeys.windowPosition => copyWith(windowPosition: value as Offset?),
      SettingsKeys.windowInCenter => copyWith(windowInCenter: value as bool?),
      SettingsKeys.loginUsername => copyWith(loginUsername: value as String?),
      SettingsKeys.loginUid => copyWith(loginUid: value as int?),
      SettingsKeys.loginEmail => copyWith(loginEmail: value as String?),
      SettingsKeys.themeMode => copyWith(themeMode: value as int?),
      SettingsKeys.locale => copyWith(locale: value as String?),
      SettingsKeys.checkinFeeling => copyWith(checkinFeeling: value as String?),
      SettingsKeys.checkinMessage => copyWith(checkinMessage: value as String?),
      SettingsKeys.showShortcutInForumCard => copyWith(showShortcutInForumCard: value as bool?),
      SettingsKeys.accentColor => copyWith(accentColor: value as int?),
      SettingsKeys.accentColorFollowSystem => copyWith(accentColorFollowSystem: value as bool?),
      SettingsKeys.showUnreadInfoHint => copyWith(showUnreadInfoHint: value as bool?),
      SettingsKeys.doublePressExit => copyWith(doublePressExit: value as bool?),
      SettingsKeys.threadReverseOrder => copyWith(threadReverseOrder: value as bool?),
      SettingsKeys.threadCardInfoRowAlignCenter => copyWith(threadCardInfoRowAlignCenter: value as bool?),
      SettingsKeys.threadCardShowLastReplyAuthor => copyWith(threadCardShowLastReplyAuthor: value as bool?),
      SettingsKeys.threadCardHighlightRecentThread => copyWith(threadCardHighlightRecentThread: value as bool?),
      SettingsKeys.threadCardHighlightAuthorName => copyWith(threadCardHighlightAuthorName: value as bool?),
      SettingsKeys.threadCardHighlightInfoRow => copyWith(threadCardHighlightInfoRow: value as bool?),
      SettingsKeys.netClientProxy => copyWith(netClientProxy: value as String?),
      SettingsKeys.netClientUseProxy => copyWith(netClientUseProxy: value as bool?),
      SettingsKeys.autoCheckin => copyWith(autoCheckin: value as bool?),
      SettingsKeys.showUnreadNoticeBadge => copyWith(showUnreadNoticeBadge: value as bool?),
      SettingsKeys.showUnreadPersonalMessageBadge => copyWith(showUnreadPersonalMessageBadge: value as bool?),
      SettingsKeys.showUnreadBroadcastMessageBadge => copyWith(showUnreadBroadcastMessageBadge: value as bool?),
      SettingsKeys.autoSyncNoticeSeconds => copyWith(autoSyncNoticeSeconds: value as int?),
      SettingsKeys.enableDebugOperations => copyWith(enableDebugOperations: value as bool?),
      SettingsKeys.fontFamily => copyWith(fontFamily: value as String?),
      SettingsKeys.enableEditorBBCodeParser => copyWith(enableEditorBBCodeParser: value as bool?),
      SettingsKeys.enableUpdateCheckOnStartup => copyWith(enableUpdateCheckOnStartup: value as bool?),
      SettingsKeys.editorRecentUsedCustomColors => copyWith(editorRecentUsedCustomColors: value as List<int>?),
    };
  }
}
