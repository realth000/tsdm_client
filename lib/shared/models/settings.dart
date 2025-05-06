part of 'models.dart';

/// Keys for all settings.
// ignore_for_file: public_member_api_docs
enum SettingsKeys<T> implements Comparable<SettingsKeys<T>> {
  /// Net client config: Accept.
  netClientAccept<String>(
    name: 'netClientAccept',
    type: String,
    defaultValue:
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
  ),

  /// Net client config: Accept-Encoding.
  ///
  /// FormatException happens in some page, current found in 301 request in
  /// redirect
  /// url in notice page.
  /// After debugging like this:
  /// https://github.com/flutter/flutter/issues/32558#issuecomment-886022246
  /// Remove "gzip" encoding in "Accept-Encoding" can fix this.
  netClientAcceptEncoding<String>(name: 'netClientAcceptEncoding', type: String, defaultValue: 'deflate, br'),

  /// Net client config: Accept-Language.
  netClientAcceptLanguage<String>(
    name: 'dioAcceptLanguage',
    type: String,
    defaultValue: 'zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6,zh-TW;q=0.5',
  ),

  /// Net client config: User-Agent.
  netClientUserAgent<String>(
    name: 'dioUserAgent',
    type: String,
    defaultValue: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:136.0) Gecko/20100101 Firefox/136.0',
  ),

  /// Remember window size after window size changed on desktop platforms.
  ///
  /// Disable this config will never update [windowSize].
  windowRememberSize<bool>(name: 'windowRememberSize', type: bool, defaultValue: true),

  /// Window size config on desktop platforms.
  windowSize<Size>(name: 'windowSize', type: Size, defaultValue: Size(800, 600)),

  /// Remember window position after window position changed on desktop
  /// platforms.
  ///
  /// Disable this config will never update [windowPosition].
  windowRememberPosition<bool>(name: 'windowRememberPosition', type: bool, defaultValue: true),

  /// Window position config on desktop platforms.
  windowPosition<Offset>(name: 'windowPosition', type: Offset, defaultValue: Offset.zero),

  /// Window whether in the center of screen config on desktop platforms.
  ///
  /// Enable this config will disable [windowPosition] and
  /// [windowRememberPosition].
  windowInCenter<bool>(name: 'windowInCenter', type: bool, defaultValue: false),

  /// Login user username.
  loginUsername<String>(name: 'loginUsername', type: String, defaultValue: ''),

  /// Login user uid.
  loginUid<int>(name: 'loginUid', type: int, defaultValue: 0),

  /// Login user email address.
  loginEmail<String>(name: 'loginEmail', type: String, defaultValue: ''),

  /// Default app theme mode.
  ///
  /// 0: [ThemeMode.system]
  /// 1: [ThemeMode.light]
  /// 2: [ThemeMode.dark]
  themeMode<int>(name: 'ThemeMode', type: int, defaultValue: 0),

  /// Locale
  ///
  /// Empty means follow system locale.
  locale<String>(name: 'locale', type: String, defaultValue: ''),

  /// Default feeling when check in
  checkinFeeling<String>(name: 'checkInFeeling', type: String, defaultValue: 'kx'),

  /// Default check in message when check in
  checkinMessage<String>(name: 'checkInMessage', type: String, defaultValue: '每日签到'),

  /// Show shortcut widget that to redirect to latest thread or subreddit in
  /// forum card.
  showShortcutInForumCard<bool>(name: 'showShortcutInForumCard', type: bool, defaultValue: false),

  /// Default accent color.
  ///
  /// Less than zero represents default color.
  accentColor<int>(
    name: 'accentColor',
    type: int,
    defaultValue: 4280391411, // PrimaryColors.blue
  ),

  /// Using system color (usually wallpaper color) as app accent color.
  accentColorFollowSystem<bool>(name: 'accentColorFollowSystem', type: bool, defaultValue: false),

  /// Show badge or unread notice count on notice button.
  showUnreadInfoHint<bool>(name: 'showUnreadInfoHint', type: bool, defaultValue: true),

  /// Only exit the app when user press back button twice or more.
  ///
  /// Avoid accidentally exit the app.
  doublePressExit<bool>(name: 'doublePressExit', type: bool, defaultValue: true),

  /// View latest posts in thread first, in other words, posts are sorted in
  /// desc order.
  threadReverseOrder<bool>(name: 'threadReverseOrder', type: bool, defaultValue: false),

  /// Center align the info row in thread card.
  threadCardInfoRowAlignCenter<bool>(name: 'threadCardInfoRowAlignCenter', type: bool, defaultValue: false),

  /// Show last replied author's username in info row in `ThreadCard`.
  threadCardShowLastReplyAuthor<bool>(name: 'threadCardShowLastReplyAuthor', type: bool, defaultValue: true),

  /// Highlight recent thread (published in recent 24 hours).
  threadCardHighlightRecentThread<bool>(name: 'threadCardHighlightRecentThread', type: bool, defaultValue: true),

  /// Highlight author's username in thread card.
  threadCardHighlightAuthorName<bool>(name: 'threadCardHighlightAuthorName', type: bool, defaultValue: true),
  threadCardHighlightInfoRow<bool>(name: 'threadCardHighlightInfoRow', type: bool, defaultValue: true),

  /// Use network proxy config below or not.
  netClientUseProxy<bool>(name: 'netClientUseProxy', type: bool, defaultValue: false),

  /// Network proxy.
  ///
  /// Manually set, in format: $domain:$port where $domain is usually localhost.
  netClientProxy<String>(name: 'netClientProxy', type: String, defaultValue: ''),

  /// Enable auto checkin for all users when app startup.
  autoCheckin<bool>(name: 'autoCheckin', type: bool, defaultValue: true),

  /// Show unread badge on notice card.
  ///
  /// Disabled by default because the read/unread flag is offline.
  showUnreadNoticeBadge<bool>(name: 'showUnreadNoticeBadge', type: bool, defaultValue: false),

  /// Show unread badge on personal message card.
  ///
  /// Enabled by default because the read/unread flag is provided by server.
  showUnreadPersonalMessageBadge<bool>(name: 'showUnreadPersonalMessageBadge', type: bool, defaultValue: true),

  /// Show unread badge on broadcast message card.
  ///
  /// Disabled by default because the read/unread flag is offline.
  showUnreadBroadcastMessageBadge<bool>(name: 'showUnreadBroadcastMessageBadge', type: bool, defaultValue: false),

  /// Duration of automatically fetch notice from server, in seconds.
  ///
  /// Default is 600 seconds.
  autoSyncNoticeSeconds<int>(name: 'autoSyncNoticeSeconds', type: int, defaultValue: 600),

  /// Enable operations for debugging.
  enableDebugOperations<bool>(name: 'enableDebugOperations', type: bool, defaultValue: false),

  /// APP font family.
  fontFamily<String>(name: 'fontFamily', type: String, defaultValue: ''),

  /// Enable experimental BBCode parser for editor.
  ///
  /// The editor will try to parse raw bbcode text into quill delta and provide WYSIWYG experience, it is not considered
  /// to be stable but... give it a chance.
  enableEditorBBCodeParser<bool>(name: 'enableEditorBBCodeParser', type: bool, defaultValue: true),

  /// Enable the update check when app startup.
  enableUpdateCheckOnStartup<bool>(name: 'enableUpdateCheckOnStartup', type: bool, defaultValue: true),

  /// Recent used custom colors in editor.
  ///
  /// The length of the list is determined to .
  editorRecentUsedCustomColors<List<int>>(name: 'editorRecentUsedCustomColors', type: List<int>, defaultValue: []);

  const SettingsKeys({required this.name, required this.type, required this.defaultValue});

  final String name;
  final Type type;
  final T defaultValue;

  /// Ignore dynamic generic type here because the function is used to compare
  /// all types of [SettingsKeys].
  @override
  // Intend to have dynamic types.
  // ignore: avoid_dynamic
  int compareTo(SettingsKeys<dynamic> other) => name.compareTo(other.name);
}
