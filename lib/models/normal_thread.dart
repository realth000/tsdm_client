import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:html/dom.dart';

import '../utils/html_element.dart';
import '../utils/prefix_url.dart';
import '../utils/time.dart';
import 'thread_author.dart';
import 'thread_type.dart';

part 'normal_thread.freezed.dart';

/// Model of normal thread;
@freezed
class NormalThread with _$NormalThread {
  /// Freezed constructor.
  const factory NormalThread({
    /// Thread title.
    required String title,

    /// Thread url.
    required String url,

    /// Thread author, contains username and user page url.
    required ThreadAuthor author,

    /// Thread publish date, without publish hour level time.
    ///
    /// e.g. "2023-03-04".
    required DateTime publishDate,

    /// Author of the latest reply.
    ///
    /// If no reply in thread, also is the [author].
    required ThreadAuthor latestReplyAuthor,

    /// Time of latest reply, with hour level time.
    ///
    /// e.g. "2023-03-04 00:11:22".
    required DateTime latestReplyTime,

    /// Icon url of this thread.
    ///
    /// May be null.
    required String iconUrl,

    /// Thread type: 动漫音乐、其他...
    ///
    /// May be null.
    required ThreadType? threadType,

    /// Thread reply count.
    ///
    /// >= 0.
    required int replyCount,

    /// Thread view times.
    ///
    /// >= 0.
    required int viewCount,

    /// Thread price.
    ///
    /// May be null, >= 0.
    required int? price,
  }) = _NormalThread;
}

/// Build a [NormalThread] model with the given [Element]
///
/// <tbody id="normalthread_xxxxxxx" class="tsdm_normalthread" name="tsdm_normalthread">
NormalThread? buildNormalThreadFromElement(Element threadElement) {
  if (threadElement.children.length != 1) {
    return null;
  }
  final trRoot = threadElement.children.first;
  final iconNode = trRoot.getElementsByClassName('icn').firstOrNull;
  final titleNode = trRoot.getElementsByClassName('new').firstOrNull;
  final replyCountNode = trRoot.getElementsByClassName('num').firstOrNull;
  final userNodeList = trRoot.getElementsByClassName('by');
  final authorNode = userNodeList.elementAtOrNull(0);
  final lastReplyNode = userNodeList.elementAtOrNull(1);

  final threadIconUrl =
      iconNode?.childAtOrNull(0)?.childAtOrNull(0)?.attributes['src'];
  final threadTypeUrl = titleNode?.childAtOrNull(1)?.firstHref();
  final threadTypeName = titleNode?.childAtOrNull(1)?.firstEndDeepText();
  final threadUrl =
      titleNode?.getElementsByClassName('xst').firstOrNull?.attributes['href'];
  final threadTitle =
      titleNode?.getElementsByClassName('xst').firstOrNull?.firstChild?.text;
  final threadPrice =
      titleNode?.getElementsByClassName('xw1').firstOrNull?.firstChild?.text;
  final threadAuthorUrl = authorNode?.childAtOrNull(0)?.firstHref();
  final threadAuthorName = authorNode?.childAtOrNull(0)?.firstEndDeepText();
  final threadPublishDate = authorNode?.childAtOrNull(1)?.firstEndDeepText();
  final threadReplyCount = replyCountNode?.childAtOrNull(0)?.firstEndDeepText();
  final threadViewCount = replyCountNode?.childAtOrNull(1)?.firstEndDeepText();

  final threadLastReplyAuthorUrl = lastReplyNode?.childAtOrNull(0)?.firstHref();
  final threadLastReplyAuthorName =
      lastReplyNode?.childAtOrNull(0)?.firstEndDeepText();
  final threadLastReplyTime = lastReplyNode
      ?.childAtOrNull(1)
      ?.firstChild
      ?.firstChild
      ?.attributes['title'];
  if (threadTitle == null ||
      threadUrl == null ||
      threadIconUrl == null ||
      threadAuthorUrl == null ||
      threadAuthorName == null ||
      threadPublishDate == null ||
      threadLastReplyAuthorUrl == null ||
      threadLastReplyAuthorName == null ||
      threadLastReplyTime == null) {
    return null;
  }
  return NormalThread(
    title: threadTitle,
    url: addUrlPrefix(threadUrl),
    author: ThreadAuthor(
      name: threadAuthorName,
      url: threadAuthorUrl,
    ),
    publishDate: DateTime.parse(formatTimeStringWithUTC8(threadPublishDate)),
    latestReplyAuthor: ThreadAuthor(
      name: threadLastReplyAuthorName,
      url: threadLastReplyAuthorUrl,
    ),
    latestReplyTime:
        DateTime.parse(formatTimeStringWithUTC8(threadLastReplyTime)),
    iconUrl: addUrlPrefix(threadIconUrl),
    threadType: parseThreadType(threadTypeName, threadTypeUrl),
    replyCount: threadReplyCount != null ? int.parse(threadReplyCount) : 0,
    viewCount: threadViewCount != null ? int.parse(threadViewCount) : 0,
    price: threadPrice != null ? int.parse(threadPrice) : null,
  );
}
