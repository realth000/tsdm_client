import 'package:flutter/material.dart';

/// Mixin that provides default settings values.
mixin SettingsDefaultMapMixin {
  /// Net client config: Accept.
  String get defaultNetClientAccept =>
      'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7';

  /// Net client config: Accept-Encoding.
  ///
  /// FormatException happens in some page, current found in 301 request in
  /// redirect
  /// url in notice page.
  /// After debugging like this:
  /// https://github.com/flutter/flutter/issues/32558#issuecomment-886022246
  /// Remove "gzip" encoding in "Accept-Encoding" can fix this.
  String get defaultNetClientAcceptEncoding => 'deflate, br';

  /// Net client config: Accept-Language.
  String get defaultNetClientAcceptLanguage =>
      'zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6,zh-TW;q=0.5';

  /// Net client config: User-Agent.
  String get defaultNetClientUserAgent =>
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36 Edg/110.0.1587.57';

  /// Window position config on desktop platforms.
  double get defaultWindowPositionDx => 0;

  /// Window position config on desktop platforms.
  double get defaultWindowPositionDy => 0;

  /// Window width config on desktop platforms.
  double get defaultWindowWidth => 600;

  /// Window height config on desktop platforms.
  double get defaultWindowHeight => 800;

  /// Window whether in the center of screen config on desktop platforms.
  bool get defaultWindowInCenter => false;

  /// Login user username.
  String get defaultLoginUsername => '';

  /// Login user uid.
  int get defaultLoginUid => -1;

  /// Default app theme mode.
  ///
  /// 0: [ThemeMode.system]
  /// 1: [ThemeMode.light]
  /// 2: [ThemeMode.dark]
  int get defaultThemeMode => ThemeMode.system.index;

  /// Locale
  ///
  /// Empty means follow system locale.
  String get defaultLocale => '';

  /// Default feeling when check in
  String get defaultCheckInFeeling => 'kx';

  /// Default check in message when check in
  String get defaultCheckInMessage => '每日签到';

  /// Show shortcut widget that to redirect to latest thread or subreddit in
  /// forum card.
  bool get defaultShowRedirectInForumCard => false;

  /// Default accent color.
  ///
  /// Less than zero represents default color.
  int get defaultAccentColor => -1;
}
