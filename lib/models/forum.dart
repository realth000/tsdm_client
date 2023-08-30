import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:html/dom.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/utils/html_element.dart';
import 'package:tsdm_client/utils/prefix_url.dart';
import 'package:tsdm_client/utils/time.dart';

part '../generated/models/forum.freezed.dart';

/// Data model for sub forums.
@freezed
class Forum with _$Forum {
  /// Freezed constructor.
  const factory Forum({
    required int forumID,
    required String name,
    required String url,
    required String iconUrl,
    required int threadCount,
    required int replyCount,
    required String? latestThreadUrl,
    required DateTime? latestThreadTime,
    required String? latestThreadTimeText,
    required int? threadTodayCount,
  }) = _Forum;
}

/// Build a [Forum] model with the given [Element]
///
/// <td class="fl_g" width="24.9%">
Forum? buildForumFromElement(Element element) {
  if (element.children.length != 3) {
    return null;
  }
  final forumIconUrl = element
          .childAtOrNull(1)
          ?.childAtOrNull(1)
          ?.childAtOrNull(0)
          ?.attributes['data-original'] ??
      element
          .childAtOrNull(1)
          ?.childAtOrNull(1)
          ?.childAtOrNull(0)
          ?.attributes['src'];

  // <dl>
  final forumRootNode = element.childAtOrNull(2);
  // <a href="forum.php?mod=forumdisplay&amp;fid=8">新番下载</a>
  final forumInfoNode = forumRootNode?.childAtOrNull(0)?.childAtOrNull(0);
  final forumUrl = forumInfoNode?.firstHref();
  final forumName = forumInfoNode?.text;
  final forumThreadTodayCount =
      forumRootNode?.childAtOrNull(1)?.childAtOrNull(2)?.childAtOrNull(1)?.text;
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
  // print(
  //     'AAAA $forumName forumLatestThreadTime$forumLatestThreadTime ${DateTime.parse(formatTimeString(forumLatestThreadTime ?? '2023-03-06'))}');
  final forumLatestThreadTimeText =
      forumRootNode?.childAtOrNull(2)?.childAtOrNull(0)?.childAtOrNull(0)?.text;
  if (forumName == null ||
      forumUrl == null ||
      forumIconUrl == null ||
      forumThreadCount == null ||
      forumReplyCount == null) {
    debug(
        'failed to build forum page: $forumName $forumUrl $forumIconUrl $forumThreadCount $forumReplyCount ');
    return null;
  }
  final forumIDString = Uri.parse(forumUrl).queryParameters['fid'];
  if (forumIDString == null) {
    debug('failed to build forum page: $forumIDString');
    return null;
  }
  return Forum(
    name: forumName,
    url: addUrlPrefix(forumUrl),
    iconUrl: forumIconUrl,
    threadCount: int.parse(forumThreadCount),
    replyCount: int.parse(forumReplyCount),
    latestThreadUrl: forumLatestThreadUrl != null
        ? addUrlPrefix(forumLatestThreadUrl)
        : null,
    latestThreadTime: forumLatestThreadTime != null
        ? DateTime.parse(formatTimeStringWithUTC8(forumLatestThreadTime))
        : null,
    latestThreadTimeText: forumLatestThreadTimeText,
    threadTodayCount:
        forumThreadTodayCount != null ? int.parse(forumThreadTodayCount) : null,
    forumID: int.parse(forumIDString),
  );
}
