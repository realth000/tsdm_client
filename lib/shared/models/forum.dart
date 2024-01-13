import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:universal_html/html.dart' as uh;

/// Data model for subreddit.
final class Forum extends Equatable {
  const Forum({
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

  bool get isExpanded =>
      latestThreadTitle != null && latestThreadUserName != null;

  /// Build a [Forum] model from <tr class="fl_row"> node.
  ///
  /// This function build from expanded style forums.
  static Forum? fromFlRowNode(uh.Element element) {
    /// Build from '<tr class="fl_row">' of '<tr>' (only the first row in table)
    /// node [element] inside table, with expanded layout.
    final titleNode = element.querySelector('td:nth-child(2) > h2 > a') ??
        // Theme 旅行者
        element.querySelector('td:nth-child(1) > h2 > a');
    final name = titleNode?.firstEndDeepText();
    final url = titleNode?.firstHref();
    final forumID = url?.split('fid=').lastOrNull?.parseToInt();
    if (name == null || forumID == null || url == null) {
      debug(
          'failed to build forum: name or fid or url not found: name=$name, fid=$forumID, url=$url');
      return null;
    }

    // Allow empty.
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

    if (threadCount == null || replyCount == null) {
      debug('failed to build forum: threadCount or replyCount not found');
      return null;
    }

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

    return Forum(
      forumID: forumID,
      url: url,
      name: name,
      iconUrl: iconUrl ?? '',
      threadCount: threadCount,
      replyCount: replyCount,
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

  @override
  List<Object?> get props => [forumID];
}
