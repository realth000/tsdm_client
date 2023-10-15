import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as dom;
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/utils/html_element.dart';

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
}

/// Data model for sub forums.
@immutable
class Forum {
  Forum.fromFlGNode(dom.Element element) : _info = _buildForumInfo(element);

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

  static _ForumInfo _buildForumInfo(dom.Element element) {
    final titleNode = element.querySelector('div.tsdm_fl_inf > dl > dt > a');
    final name = titleNode?.firstEndDeepText();
    final url = titleNode?.firstHref();
    final forumID = url?.split('fid=').lastOrNull;

    final iconUrl = element
        .querySelector('div.fl_icn_g > a > img')
        ?.dataOriginalOrSrcImgUrl();

    final ddNode = element
        .querySelector('div.tsdm_fl_inf')
        ?.childAtOrNull(0)
        ?.childAtOrNull(1);
    final threadCount =
        ddNode?.childAtOrNull(0)?.childAtOrNull(1)?.firstEndDeepText();
    final replyCount =
        ddNode?.childAtOrNull(1)?.childAtOrNull(1)?.firstEndDeepText();
    final threadTodayCount =
        ddNode?.childAtOrNull(2)?.childAtOrNull(1)?.firstEndDeepText();

    // The html package has bug in nth-child query, do not use it.
    // final threadCount = element
    //     .querySelector(
    //       'div.tsdm_fl_inf > dl > dd > em:nth-child(1) > font:nth-child(2)',
    //     )
    //     ?.firstEndDeepText();
    // final replyCount = element
    //     .querySelector(
    //       'div.tsdm_fl_inf > dl > dd > em:nth-child(2) > font:nth-child(2)',
    //     )
    //     ?.firstEndDeepText();

    // final threadTodayCount = element
    //     .querySelector(
    //       'div.tsdm_fl_inf > dl > dd > em:nth-child(3) > font:nth-child(2)',
    //     )
    //     ?.firstEndDeepText();

    return _ForumInfo(
      forumID: int.parse(forumID ?? '-1'),
      url: url ?? '',
      name: name ?? '',
      iconUrl: iconUrl ?? '',
      threadCount: int.parse(threadCount ?? '-1'),
      replyCount: int.parse(replyCount ?? '-1'),
      threadTodayCount: int.parse(threadTodayCount ?? '-1'),
      // According to server web page rendering, these attributes are missing
      // in the forum pages.
      // Maybe they will add back someday.
      latestThreadTime: null,
      latestThreadTimeText: null,
      latestThreadUrl: null,
    );
  }

  bool isValid() {
    if (name.isEmpty ||
        url.isEmpty ||
        iconUrl.isEmpty ||
        threadCount == -1 ||
        replyCount == -1) {
      debug(
        'failed to build forum page: $name, $url, $iconUrl, $threadCount, $replyCount',
      );
      return false;
    }
    return true;
  }
}
