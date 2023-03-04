import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:html/dom.dart';

import '../utils/html_element.dart';
import '../utils/time.dart';

part 'forum.freezed.dart';

/// Data model for sub forums.
@freezed
class Forum with _$Forum {
  /// Freezed constructor.
  const factory Forum({
    required String name,
    required String url,
    required String iconUrl,
    required int threadCount,
    required int replyCount,
    required String? latestThreadUrl,
    required DateTime? latestThreadTime,
    required int? threadTodayCount,
  }) = _Forum;
}

/// Build a [Forum] model with the given [Element]
///
/// <td class="fl_g" width="24.9%">
Forum? buildForumFromElement(Element element) {
  if (element.children.length != 2) {
    return null;
  }
  final forumIconUrl = element
      .childAtOrNull(0)
      ?.childAtOrNull(0)
      ?.childAtOrNull(0)
      ?.attributes['src'];

  // <dl>
  final forumRootNode = element.childAtOrNull(1)?.childAtOrNull(0);
  // <a href="forum.php?mod=forumdisplay&amp;fid=8">新番下载</a>
  final forumInfoNode = forumRootNode?.childAtOrNull(0)?.childAtOrNull(0);
  final forumUrl = forumInfoNode?.firstHref();
  final forumName = forumInfoNode?.text;
  final forumThreadTodayCount = forumRootNode
      ?.childAtOrNull(0)
      ?.childAtOrNull(1)
      ?.text
      .trim()
      .replaceAll('(', '')
      .replaceAll(')', '');
  final forumThreadCount = forumRootNode
      ?.childAtOrNull(1)
      ?.childAtOrNull(0)
      ?.text
      .split(' ')
      .elementAtOrNull(1);
  final forumReplyCount = forumRootNode
      ?.childAtOrNull(1)
      ?.childAtOrNull(1)
      ?.text
      .split(' ')
      .elementAtOrNull(1);
  final forumLatestThreadUrl = forumRootNode?.childAtOrNull(2)?.firstHref();
  final forumLatestThreadTime = forumRootNode
      ?.childAtOrNull(2)
      ?.childAtOrNull(0)
      ?.childAtOrNull(0)
      ?.attributes['title'];
  if (forumName == null ||
      forumUrl == null ||
      forumIconUrl == null ||
      forumThreadCount == null ||
      forumReplyCount == null) {
    return null;
  }
  return Forum(
    name: forumName,
    url: forumUrl,
    iconUrl: forumIconUrl,
    threadCount: int.parse(forumThreadCount),
    replyCount: int.parse(forumReplyCount),
    latestThreadUrl: forumLatestThreadUrl,
    latestThreadTime: forumLatestThreadTime != null
        ? DateTime.parse(formatTimeString(forumLatestThreadTime))
        : null,
    threadTodayCount:
        forumThreadTodayCount != null ? int.parse(forumThreadTodayCount) : null,
  );
}
