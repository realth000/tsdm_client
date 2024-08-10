part of 'models.dart';

/// Keys for all settings.
// ignore_for_file: public_member_api_docs
enum SettingsKeys implements Comparable<SettingsKeys> {
  /// Net client config: Accept.
  netClientAccept(
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
  netClientAcceptEncoding(
    name: 'netClientAcceptEncoding',
    type: String,
    defaultValue: 'deflate, br',
  ),

  /// Net client config: Accept-Language.
  netClientAcceptLanguage(
    name: 'dioAcceptLanguage',
    type: String,
    defaultValue: 'zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6,zh-TW;q=0.5',
  ),

  /// Net client config: User-Agent.
  netClientUserAgent(
    name: 'dioUserAgent',
    type: String,
    defaultValue:
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36 Edg/110.0.1587.57',
  ),

  /// Window width config on desktop platforms.
  windowWidth(
    name: 'windowWidth',
    type: double,
    defaultValue: 600.0,
  ),

  /// Window height config on desktop platforms.
  windowHeight(
    name: 'windowHeight',
    type: double,
    defaultValue: 800.0,
  ),

  /// Window position config on desktop platforms.
  windowPositionDx(
    name: 'windowPositionX',
    type: double,
    defaultValue: 0.0,
  ),

  /// Window position config on desktop platforms.
  windowPositionDy(
    name: 'windowPositionY',
    type: double,
    defaultValue: 0.0,
  ),

  /// Window whether in the center of screen config on desktop platforms.
  windowInCenter(
    name: 'windowInCenter',
    type: bool,
    defaultValue: false,
  ),

  /// Login user username.
  loginUsername(
    name: 'loginUsername',
    type: String,
    defaultValue: '',
  ),

  /// Login user uid.
  loginUid(
    name: 'loginUid',
    type: int,
    defaultValue: 0,
  ),

  /// Login user email address.
  loginEmail(
    name: 'loginEmail',
    type: String,
    defaultValue: '',
  ),

  /// Default app theme mode.
  ///
  /// 0: [ThemeMode.system]
  /// 1: [ThemeMode.light]
  /// 2: [ThemeMode.dark]
  themeMode(
    name: 'ThemeMode',
    type: int,
    defaultValue: 0,
  ),

  /// Locale
  ///
  /// Empty means follow system locale.
  locale(
    name: 'locale',
    type: String,
    defaultValue: '',
  ),

  /// Default feeling when check in
  checkinFeeling(
    name: 'checkInFeeling',
    type: String,
    defaultValue: 'kx',
  ),

  /// Default check in message when check in
  checkinMessage(
    name: 'checkInMessage',
    type: String,
    defaultValue: '每日签到',
  ),

  /// Show shortcut widget that to redirect to latest thread or subreddit in
  /// forum card.
  showShortcutInForumCard(
    name: 'showShortcutInForumCard',
    type: bool,
    defaultValue: false,
  ),

  /// Default accent color.
  ///
  /// Less than zero represents default color.
  accentColor(
    name: 'accentColor',
    type: int,
    defaultValue: -1,
  ),

  /// Show badge or unread notice count on notice button.
  showUnreadInfoHint(
    name: 'showUnreadInfoHint',
    type: bool,
    defaultValue: true,
  ),

  /// Only exit the app when user press back button twice or more.
  ///
  /// Avoid accidentally exit the app.
  doublePressExit(
    name: 'doublePressExit',
    type: bool,
    defaultValue: true,
  ),

  /// View latest posts in thread first, in other words, posts are sorted in
  /// desc order.
  threadReverseOrder(
    name: 'threadReverseOrder',
    type: bool,
    defaultValue: false,
  ),

  /// Center align the info row in thread card.
  threadCardInfoRowAlignCenter(
    name: 'threadCardInfoRowAlignCenter',
    type: bool,
    defaultValue: false,
  ),

  /// Show last replied author's username in info row in `ThreadCard`.
  threadCardShowLastReplyAuthor(
    name: 'threadCardShowLastReplyAuthor',
    type: bool,
    defaultValue: true,
  );

  const SettingsKeys({
    required this.name,
    required this.type,
    required this.defaultValue,
  });

  final String name;
  final Type type;
  final dynamic defaultValue;

  @override
  int compareTo(SettingsKeys other) => name.compareTo(other.name);
}
