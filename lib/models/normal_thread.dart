import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as dom;
import 'package:tsdm_client/models/thread_type.dart';
import 'package:tsdm_client/models/user.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/utils/html_element.dart';
import 'package:tsdm_client/utils/prefix_url.dart';
import 'package:tsdm_client/utils/time.dart';

@immutable
class _NormalThreadInfo {
  const _NormalThreadInfo({
    required this.title,
    required this.url,
    required this.threadID,
    required this.author,
    required this.publishDate,
    required this.latestReplyAuthor,
    required this.latestReplyTime,
    required this.iconUrl,
    required this.threadType,
    required this.replyCount,
    required this.viewCount,
    required this.price,
  });

  /// Thread title.
  final String title;

  /// Thread url.
  final String url;

  /// Thread id.
  final String threadID;

  /// Thread author, contains username and user page url.
  final User author;

  /// Thread publish date, without publish hour level time.
  ///
  /// e.g. "2023-03-04".
  final DateTime publishDate;

  /// Author of the latest reply.
  ///
  /// If no reply in thread, also is the [author].
  final User latestReplyAuthor;

  /// Time of latest reply, with hour level time.
  ///
  /// e.g. "2023-03-04 00:11:22".
  final DateTime latestReplyTime;

  /// Icon url of this thread.
  ///
  /// May be null.
  final String iconUrl;

  /// Thread type: 动漫音乐、其他...
  ///
  /// May be null.
  final ThreadType? threadType;

  /// Thread reply count.
  ///
  /// >= 0.
  final int replyCount;

  /// Thread view times.
  ///
  /// >= 0.
  final int viewCount;

  /// Thread price.
  ///
  /// May be null, >= 0.
  final int? price;
}

@immutable
class NormalThread {
  NormalThread.fromTBody(dom.Element element)
      : _info = _buildFromTBody(element);

  final _NormalThreadInfo _info;

  String get title => _info.title;

  String get url => _info.url;

  String get threadID => _info.threadID;

  User get author => _info.author;

  DateTime get publishDate => _info.publishDate;

  User get latestReplyAuthor => _info.latestReplyAuthor;

  DateTime get latestReplyTime => _info.latestReplyTime;

  String get iconUrl => _info.iconUrl;

  ThreadType? get threadType => _info.threadType;

  int get replyCount => _info.replyCount;

  int get viewCount => _info.viewCount;

  int? get price => _info.price;

  /// Build a [NormalThread] model with the given [dom.Element]
  ///
  /// <tbody id="normalthread_xxxxxxx" class="tsdm_normalthread" name="tsdm_normalthread">
  static _NormalThreadInfo _buildFromTBody(dom.Element threadElement) {
    final trRoot = threadElement.children.first;
    final iconNode = trRoot.getElementsByClassName('icn').firstOrNull;
    final titleNode = trRoot.childAtOrNull(1);
    final replyCountNode = trRoot.getElementsByClassName('num').firstOrNull;
    final userNodeList = trRoot.getElementsByClassName('by');
    final authorNode = userNodeList.elementAtOrNull(0);
    final lastReplyNode = userNodeList.elementAtOrNull(1);

    final threadIconUrl =
        iconNode?.childAtOrNull(0)?.childAtOrNull(0)?.attributes['src'];
    final threadTypeUrl = titleNode?.childAtOrNull(1)?.firstHref();
    final threadTypeName = titleNode?.childAtOrNull(1)?.firstEndDeepText();
    final threadUrl = titleNode
        ?.getElementsByClassName('xst')
        .firstOrNull
        ?.attributes['href'];
    final threadTitle =
        titleNode?.getElementsByClassName('xst').firstOrNull?.firstChild?.text;
    final threadPrice =
        titleNode?.getElementsByClassName('xw1').firstOrNull?.firstChild?.text;
    final threadAuthorUrl = authorNode?.childAtOrNull(0)?.firstHref();
    final threadAuthorUid = threadAuthorUrl?.split('uid=').elementAtOrNull(1);
    final threadAuthorName = authorNode?.childAtOrNull(0)?.firstEndDeepText();
    final threadPublishDate = authorNode?.childAtOrNull(1)?.firstEndDeepText();
    final threadReplyCount =
        replyCountNode?.childAtOrNull(0)?.firstEndDeepText();
    final threadViewCount =
        replyCountNode?.childAtOrNull(1)?.firstEndDeepText();

    final threadLastReplyAuthorUrl =
        lastReplyNode?.childAtOrNull(0)?.firstHref();
    // We only have username here.
    // final threadLastReplyAuthorUid =
    //     threadLastReplyAuthorUrl?.split('uid=').elementAtOrNull(1);
    final threadLastReplyAuthorName =
        lastReplyNode?.childAtOrNull(0)?.firstEndDeepText();
    final threadLastReplyTime = lastReplyNode
            ?.childAtOrNull(1)
            ?.firstChild
            ?.firstChild
            ?.attributes['title'] // Within 7 days.
        ??
        lastReplyNode?.childAtOrNull(1)?.firstEndDeepText(); // 7 days ago
    final threadID = threadUrl == null
        ? null
        : Uri.parse(addUrlPrefix(threadUrl)).queryParameters['tid'];
    return _NormalThreadInfo(
      title: threadTitle ?? '',
      url: threadUrl == null ? '' : addUrlPrefix(threadUrl),
      threadID: threadID ?? '',
      author: User(
        name: threadAuthorName ?? '',
        uid: threadAuthorUid,
        url: threadAuthorUrl ?? '',
      ),
      publishDate: threadPublishDate == null
          ? DateTime.utc(0)
          : DateTime.parse(formatTimeStringWithUTC8(threadPublishDate)),
      latestReplyAuthor: User(
        name: threadLastReplyAuthorName ?? '',
        url: threadLastReplyAuthorUrl ?? '',
      ),
      latestReplyTime: threadLastReplyTime == null
          ? DateTime.utc(0)
          : DateTime.parse(formatTimeStringWithUTC8(threadLastReplyTime)),
      iconUrl: threadIconUrl == null ? '' : addUrlPrefix(threadIconUrl),
      threadType: parseThreadType(threadTypeName, threadTypeUrl),
      replyCount: threadReplyCount != null ? int.parse(threadReplyCount) : 0,
      viewCount: threadViewCount != null ? int.parse(threadViewCount) : 0,
      price: threadPrice != null ? int.parse(threadPrice) : null,
    );
  }

  bool isValid() {
    if (title.isEmpty ||
        url.isEmpty ||
        iconUrl.isEmpty ||
        threadID.isEmpty ||
        !author.isValid() ||
        publishDate.year == 0 ||
        !latestReplyAuthor.isValid() ||
        latestReplyTime.year == 0) {
      debug(
        'failed to parse normal thread page: $title, $url, $iconUrl, $author, $publishDate, $latestReplyAuthor, $latestReplyTime',
      );
      return false;
    }

    return true;
  }
}
