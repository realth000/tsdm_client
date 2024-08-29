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
  netClientAcceptEncoding<String>(
    name: 'netClientAcceptEncoding',
    type: String,
    defaultValue: 'deflate, br',
  ),

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
    defaultValue:
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36',
  ),

  /// Window width config on desktop platforms.
  windowWidth<double>(
    name: 'windowWidth',
    type: double,
    defaultValue: 600,
  ),

  /// Window height config on desktop platforms.
  windowHeight<double>(
    name: 'windowHeight',
    type: double,
    defaultValue: 800,
  ),

  /// Window position config on desktop platforms.
  windowPositionDx<double>(
    name: 'windowPositionX',
    type: double,
    defaultValue: 0,
  ),

  /// Window position config on desktop platforms.
  windowPositionDy<double>(
    name: 'windowPositionY',
    type: double,
    defaultValue: 0,
  ),

  /// Window whether in the center of screen config on desktop platforms.
  windowInCenter<bool>(
    name: 'windowInCenter',
    type: bool,
    defaultValue: false,
  ),

  /// Login user username.
  loginUsername<String>(
    name: 'loginUsername',
    type: String,
    defaultValue: '',
  ),

  /// Login user uid.
  loginUid<int>(
    name: 'loginUid',
    type: int,
    defaultValue: 0,
  ),

  /// Login user email address.
  loginEmail<String>(
    name: 'loginEmail',
    type: String,
    defaultValue: '',
  ),

  /// Default app theme mode.
  ///
  /// 0: [ThemeMode.system]
  /// 1: [ThemeMode.light]
  /// 2: [ThemeMode.dark]
  themeMode<int>(
    name: 'ThemeMode',
    type: int,
    defaultValue: 0,
  ),

  /// Locale
  ///
  /// Empty means follow system locale.
  locale<String>(
    name: 'locale',
    type: String,
    defaultValue: '',
  ),

  /// Default feeling when check in
  checkinFeeling<String>(
    name: 'checkInFeeling',
    type: String,
    defaultValue: 'kx',
  ),

  /// Default check in message when check in
  checkinMessage<String>(
    name: 'checkInMessage',
    type: String,
    defaultValue: '每日签到',
  ),

  /// Show shortcut widget that to redirect to latest thread or subreddit in
  /// forum card.
  showShortcutInForumCard<bool>(
    name: 'showShortcutInForumCard',
    type: bool,
    defaultValue: false,
  ),

  /// Default accent color.
  ///
  /// Less than zero represents default color.
  accentColor<int>(
    name: 'accentColor',
    type: int,
    defaultValue: 4280391411, // PrimaryColors.blue
  ),

  /// Show badge or unread notice count on notice button.
  showUnreadInfoHint<bool>(
    name: 'showUnreadInfoHint',
    type: bool,
    defaultValue: true,
  ),

  /// Only exit the app when user press back button twice or more.
  ///
  /// Avoid accidentally exit the app.
  doublePressExit<bool>(
    name: 'doublePressExit',
    type: bool,
    defaultValue: true,
  ),

  /// View latest posts in thread first, in other words, posts are sorted in
  /// desc order.
  threadReverseOrder<bool>(
    name: 'threadReverseOrder',
    type: bool,
    defaultValue: false,
  ),

  /// Center align the info row in thread card.
  threadCardInfoRowAlignCenter<bool>(
    name: 'threadCardInfoRowAlignCenter',
    type: bool,
    defaultValue: false,
  ),

  /// Show last replied author's username in info row in `ThreadCard`.
  threadCardShowLastReplyAuthor<bool>(
    name: 'threadCardShowLastReplyAuthor',
    type: bool,
    defaultValue: true,
  ),

  /// Highlight recent thread (published in recent 24 hours).
  threadCardHighlightRecentThread<bool>(
    name: 'threadCardHighlightRecentThread',
    type: bool,
    defaultValue: true,
  ),

  /// Highlight author's username in thread card.
  threadCardHighlightAuthorName<bool>(
    name: 'threadCardHighlightAuthorName',
    type: bool,
    defaultValue: true,
  ),

  /// Use network proxy config below or not.
  netClientUseProxy<bool>(
    name: 'netClientUseProxy',
    type: bool,
    defaultValue: false,
  ),

  /// Network proxy.
  ///
  /// Manually set, in format: $domain:$port where $domain is usually localhost.
  netClientProxy<String>(
    name: 'netClientProxy',
    type: String,
    defaultValue: '',
  );

  const SettingsKeys({
    required this.name,
    required this.type,
    required this.defaultValue,
  });

  final String name;
  final Type type;
  final T defaultValue;

  @override
  int compareTo(SettingsKeys<dynamic> other) => name.compareTo(other.name);
}
