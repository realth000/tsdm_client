import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:universal_html/html.dart' as uh;

/// Wrap a class so we can mark model as immutable.
@immutable
class _ForumInfo {
  const _ForumInfo({
    required this.forumID,
    required this.url,
    required this.name,
    required this.iconUrl,
    required this.threadCount,
    required this.replyCount,
    required this.latestThreadUrl,
    required this.latestThreadTime,
    required this.latestThreadTimeText,
    required this.threadTodayCount,

    /// Expanded layout only.
    this.subForumList,
    this.subThreadList,
    this.latestThreadTitle,
    this.latestThreadUserName,
    this.latestThreadUserUrl,
  });

  final int forumID;
  final String url;
  final String name;
  final String iconUrl;
  final int threadCount;
  final int replyCount;
  final String? latestThreadUrl;
  final DateTime? latestThreadTime;
  final String? latestThreadTimeText;
  final int? threadTodayCount;

  /// Expanded layout only.
  final List<(String subForumName, String url)>? subForumList;
  final List<(String threadTitle, String url)>? subThreadList;
  final String? latestThreadTitle;
  final String? latestThreadUserName;
  final String? latestThreadUserUrl;
}

/// Data model for sub forums.
@immutable
class Forum {
  Forum.fromFlGNode(uh.Element element) : _info = _buildForumInfo(element);

  Forum.fromFlRowNode(uh.Element element)
      : _info = _buildExpandedForumInfo(element);

  final _ForumInfo _info;

  int get forumID => _info.forumID;

  String get name => _info.name;

  String get url => _info.url;

  String get iconUrl => _info.iconUrl;

  int get threadCount => _info.threadCount;

  int get replyCount => _info.replyCount;

  String? get latestThreadUrl => _info.latestThreadUrl;

  DateTime? get latestThreadTime => _info.latestThreadTime;

  String? get latestThreadTimeText => _info.latestThreadTimeText;

  int? get threadTodayCount => _info.threadTodayCount;

  List<(String subForumName, String url)>? get subForumList =>
      _info.subForumList;

  List<(String threadTitle, String url)>? get subThreadList =>
      _info.subThreadList;

  String? get latestThreadTitle => _info.latestThreadTitle;

  String? get latestThreadUserName => _info.latestThreadUserName;

  String? get latestThreadUserUrl => _info.latestThreadUserUrl;

  bool get isExpanded =>
      latestThreadTitle != null && latestThreadUserName != null;

  // <td class="fl_g"> node
  static _ForumInfo _buildForumInfo(uh.Element element) {
    final titleNode = element.querySelector('div.tsdm_fl_inf > dl > dt > a') ??
        // Style 5
        element.querySelector('dl > dt > a');
    final name = titleNode?.firstEndDeepText();
    final url = titleNode?.firstHref();
    final forumID = url?.split('fid=').lastOrNull?.parseToInt();

    final iconUrl = element
        .querySelector('div.fl_icn_g > a > img')
        ?.dataOriginalOrSrcImgUrl();

    final threadCount =
        // Style 1
        element
                .querySelector(
                  'div.tsdm_fl_inf > dl > dd > em:nth-child(1) > span:nth-child(2)',
                )
                ?.firstEndDeepText()
                ?.parseToInt() ??
            // Style 2
            //
            // <em>主题: 47857</em>, <em>帖数: 169905</em>
            //
            element
                .querySelector('div.tsdm_fl_inf > dl > dd > em:nth-child(1)')
                ?.firstEndDeepText()
                ?.split(' ')
                .elementAtOrNull(1)
                ?.parseToInt() ??
            // Style 3: With welcome text and without avatar.
            //
            // <em> <font>主题</font> <font>12345</font> </em>
            //
            element
                .querySelector(
                    'div.tsdm_fl_inf > dl > dd > em:nth-child(1) > font:nth-child(2)')
                ?.firstEndDeepText()
                ?.parseToInt() ??
            // Style 5
            element
                .querySelector('dl > dd > em:nth-child(1)')
                ?.firstEndDeepText()
                ?.split(' ')
                .lastOrNull
                ?.parseToInt();
    final replyCount =
        // Style 1
        element
                .querySelector(
                  'div.tsdm_fl_inf > dl > dd > em:nth-child(2) > span:nth-child(2)',
                )
                ?.firstEndDeepText()
                ?.parseToInt() ??
            // Style 2
            //
            // <em>主题: 47857</em>, <em>帖数: 169905</em>
            //
            element
                .querySelector('div.tsdm_fl_inf > dl > dd > em:nth-child(2)')
                ?.firstEndDeepText()
                ?.split(' ')
                .elementAtOrNull(1)
                ?.parseToInt() ??
            // Style 3: With welcome text and without avatar.
            //
            // <em> <font>主题</font> <font>12345</font> </em>
            //
            element
                .querySelector(
                    'div.tsdm_fl_inf > dl > dd > em:nth-child(2) > font:nth-child(2)')
                ?.firstEndDeepText()
                ?.parseToInt() ??

            // Style 5
            element
                .querySelector('dl > dd > em:nth-child(2)')
                ?.firstEndDeepText()
                ?.split(' ')
                .lastOrNull
                ?.parseToInt();
    final threadTodayCount = element
            .querySelector(
              'div.tsdm_fl_inf > dl > dd > em:nth-child(3)',
            )
            ?.firstEndDeepText()
            ?.replaceFirst(' (', '')
            .replaceFirst(')', '')
            .parseToInt() ??
        element
            .querySelector('div.tsdm_fl_inf > dl > dt > em')
            ?.firstEndDeepText()
            ?.replaceFirst(' (', '')
            .replaceFirst(')', '')
            .parseToInt() ??
        // Style 3: With welcome text and without avatar.
        //
        // <em> <font>主题</font> <font>12345</font> </em>
        //
        element
            .querySelector(
                'div.tsdm_fl_inf > dl > dd > em:nth-child(3) > font:nth-child(2)')
            ?.firstEndDeepText()
            ?.parseToInt() ??
        // Style 5
        element
            .querySelector('dl > dt > em')
            ?.firstEndDeepText()
            ?.split('(')
            .lastOrNull
            ?.split(')')
            .firstOrNull
            ?.parseToInt();

    final latestThreadNode =
        element.querySelector('div.tsdm_fl_inf > dl > dd:nth-child(3) > a');
    var latestThreadTime = latestThreadNode
        ?.querySelector('span')
        ?.attributes['title']
        ?.parseToDateTimeUtc8();
    final latestThreadTimeText = latestThreadNode?.innerText;
    if (latestThreadTime == null &&
        (latestThreadTimeText?.contains('最后发表: ') ?? false)) {
      latestThreadTime = latestThreadTimeText!
          .replaceFirst('最后发表: ', '')
          .parseToDateTimeUtc8();
    }
    final latestThreadUrl = latestThreadNode?.firstHref();

    return _ForumInfo(
      forumID: forumID ?? -1,
      url: url ?? '',
      name: name ?? '',
      iconUrl: iconUrl ?? '',
      threadCount: threadCount ?? -1,
      replyCount: replyCount ?? -1,
      threadTodayCount: threadTodayCount,
      latestThreadTime: latestThreadTime,
      latestThreadTimeText: latestThreadTimeText,
      latestThreadUrl: latestThreadUrl,
    );
  }

  /// Build from '<tr class="fl_row">' of '<tr>' (only the first row in table)
  /// node [element] inside table, with expanded layout.
  static _ForumInfo _buildExpandedForumInfo(uh.Element element) {
    final titleNode = element.querySelector('td:nth-child(2) > h2 > a') ??
        // Theme 旅行者
        element.querySelector('td:nth-child(1) > h2 > a');
    final name = titleNode?.firstEndDeepText();
    final url = titleNode?.firstHref();
    final forumID = url?.split('fid=').lastOrNull?.parseToInt();

    final iconUrl =
        element.querySelector('td > a > img')?.dataOriginalOrSrcImgUrl();

    final threadCount =
        (element.querySelector('td:nth-child(3) > span:nth-child(1)') ??
                // 旅行者 theme
                element.querySelector('td:nth-child(2) > span:nth-child(1)'))
            ?.firstEndDeepText()
            ?.parseToInt();
    final replyCount =
        (element.querySelector('td:nth-child(3) > span:nth-child(2)') ??
                // 旅行者 theme
                element.querySelector('td:nth-child(2) > span:nth-child(2)'))
            ?.firstEndDeepText()
            ?.split(' ')
            .lastOrNull
            ?.parseToInt();
    final threadTodayCount =
        // Style 1: With avatar.
        (element.querySelector('td:nth-child(2) > h2 > em') ??
                    // 旅行者 theme
                    element.querySelector('td:nth-child(1) > h2 > em'))
                ?.firstEndDeepText()
                ?.split('(')
                .lastOrNull
                ?.split(')')
                .firstOrNull
                ?.parseToInt() ??
            // Style 2: With welcome text.
            (element.querySelector('td:nth-child(2) > h2 > em:nth-child(3)') ??
                    // 旅行者 theme
                    element.querySelector(
                        'td:nth-child(2) > h2 > em:nth-child(3)'))
                ?.firstEndDeepText()
                ?.parseToInt();

    final latestThreadNode = element.querySelector('td:nth-child(4) > div') ??
        // 旅行者 theme
        element.querySelector('td:nth-child(3) > div');
    final latestThreadTime = latestThreadNode
        ?.querySelector('cite > span')
        ?.attributes['title']
        ?.parseToDateTimeUtc8();
    final latestThreadTimeText =
        latestThreadNode?.querySelector('cite > span')?.firstEndDeepText();
    final latestThreadUrl = latestThreadNode?.querySelector('a')?.firstHref();

    // Expanded layout only.
    final latestThreadTitle =
        latestThreadNode?.querySelector('a')?.firstEndDeepText();
    final latestThreadUserName =
        latestThreadNode?.querySelector('cite > a')?.firstEndDeepText();
    final latestThreadUserUrl =
        latestThreadNode?.querySelector('cite > a')?.firstHref();

    final subForumList = element
        .querySelectorAll('td > p')
        .firstWhereOrNull(
          (e) => e.nodes.firstOrNull?.text?.contains('子版块') ?? false,
        )
        ?.querySelectorAll('a')
        .map((e) => (e.firstEndDeepText()?.trim(), e.attributes['href']))
        .whereType<(String, String)>()
        .toList();

    final subThreadList = element
        .querySelectorAll('td > p a')
        .where((e) => e.attributes['href']?.contains('tid=') ?? false)
        .map((e) => (e.firstEndDeepText(), e.attributes['href']))
        .whereType<(String, String)>()
        .toList();

    return _ForumInfo(
      forumID: forumID ?? -1,
      url: url ?? '',
      name: name ?? '',
      iconUrl: iconUrl ?? '',
      threadCount: threadCount ?? -1,
      replyCount: replyCount ?? -1,
      threadTodayCount: threadTodayCount,
      latestThreadTime: latestThreadTime,
      latestThreadTimeText: latestThreadTimeText,
      latestThreadUrl: latestThreadUrl,
      // Expanded layout only.
      latestThreadTitle: latestThreadTitle,
      latestThreadUserName: latestThreadUserName,
      latestThreadUserUrl: latestThreadUserUrl,
      subForumList: subForumList,
      subThreadList: subThreadList,
    );
  }

  bool isValid() {
    if (name.isEmpty || url.isEmpty || threadCount == -1 || replyCount == -1) {
      debug(
        'failed to build forum page: $name, $url, $iconUrl, $threadCount, $replyCount',
      );
      return false;
    }
    return true;
  }
}
