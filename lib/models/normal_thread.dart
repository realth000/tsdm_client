import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/models/css_types.dart';
import 'package:tsdm_client/models/thread_type.dart';
import 'package:tsdm_client/models/user.dart';
import 'package:tsdm_client/utils/css_parser.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:universal_html/html.dart' as uh;

extension _ParseThreadState on uh.Element {
  /// Parse the [ThreadState] represented by the image node.
  ///
  /// Return an empty set if current node is not <img> node.
  ///
  /// Till now a <img> node may only have one state, but not for sure, so returns a set of state.
  Set<ThreadState> _parseThreadStateFromImg() {
    final ret = <ThreadState>{};

    if (tagName != 'IMG') {
      return ret;
    }

    final src = attributes['src'];

    /// FIXME: Better checking state.
    if (src != null) {
      if (src.contains('folder_lock')) {
        ret.add(ThreadState.closed);
      } else if (src.contains('poll')) {
        ret.add(ThreadState.poll);
      } else if (src.contains('reward')) {
        ret.add(ThreadState.rewarded);
      } else if (src.contains('pin_3')) {
        ret.add(ThreadState.pinnedGlobally);
      } else if (src.contains('pin_2')) {
        ret.add(ThreadState.pinnedInType);
      } else if (src.contains('pin_1')) {
        ret.add(ThreadState.pinnedInForum);
      }
    }

    final alt = attributes['alt'];
    switch (alt) {
      case 'agree':
        ret.add(ThreadState.agreed);
      case 'digest':
        ret.add(ThreadState.digested);
      case 'attach_img':
        ret.add(ThreadState.pictureAttached);
    }

    return ret;
  }
}

/// Thread state shown on thread entry.
///
/// The definition of "state" is not clear, just added some related info that can be displayed at the trailing of
/// UI which going to display later.
enum ThreadState {
  /// Closed and can not reply.
  closed(Icons.lock_outline),

  /// Rated by other user.
  agreed(Icons.thumb_up_outlined),

  /// Has attached pictures.
  pictureAttached(Icons.image_outlined),

  /// Marked as essential thread.
  digested(Icons.recommend_outlined),

  /// Globally pinned across the forum.
  pinnedGlobally(Icons.looks_3_outlined),

  /// Pinned in current thread type.
  pinnedInType(Icons.looks_two_outlined),

  /// Pinned in current subreddit.
  pinnedInForum(Icons.looks_one_outlined),

  /// Has poll (also called "rate").
  poll(Icons.poll_outlined),

  /// Asks for help and provides reward.
  rewarded(Icons.live_help_outlined);

  const ThreadState(this.icon);

  final IconData icon;
}

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
    required this.css,
    required this.stateSet,
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
  final DateTime? publishDate;

  /// Author of the latest reply.
  ///
  /// If no reply in thread, also is the [author].
  final User latestReplyAuthor;

  /// Time of latest reply, with hour level time.
  ///
  /// e.g. "2023-03-04 00:11:22".
  final DateTime? latestReplyTime;

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

  /// Css decoration on thread entry.
  final CssTypes? css;

  /// List of thread state.
  ///
  /// For example, a thread can be rated and marked pinned at the same time.
  final Set<ThreadState> stateSet;
}

@immutable
class NormalThread {
  NormalThread.fromTBody(uh.Element element) : _info = _buildFromTBody(element);

  final _NormalThreadInfo _info;

  String get title => _info.title;

  String get url => _info.url;

  String get threadID => _info.threadID;

  User get author => _info.author;

  DateTime? get publishDate => _info.publishDate;

  User get latestReplyAuthor => _info.latestReplyAuthor;

  DateTime? get latestReplyTime => _info.latestReplyTime;

  String get iconUrl => _info.iconUrl;

  ThreadType? get threadType => _info.threadType;

  int get replyCount => _info.replyCount;

  int get viewCount => _info.viewCount;

  int? get price => _info.price;

  CssTypes? get css => _info.css;

  Set<ThreadState> get stateSet => _info.stateSet;

  /// Build a [NormalThread] model with the given [uh.Element]
  ///
  /// <tbody id="normalthread_xxxxxxx" class="tsdm_normalthread" name="tsdm_normalthread">
  static _NormalThreadInfo _buildFromTBody(uh.Element threadElement) {
    final stateSet = <ThreadState>{};

    final threadIconNode = threadElement.querySelector('tr > td > a > img');
    if (threadIconNode != null) {
      stateSet.addAll(threadIconNode._parseThreadStateFromImg());
    }
    final threadIconUrl = threadIconNode?.attributes['src']?.prependHost();

    final threadTypeNode =
        threadElement.querySelector('tr > th > em > a:nth-child(1)');
    final threadTypeUrl = threadTypeNode?.attributes['href'];
    final threadTypeName = threadTypeNode?.firstEndDeepText();

    final threadUrlNode = threadElement.querySelector('tr > th > span > a');
    final threadUrl = threadUrlNode?.attributes['href'];
    final threadTitle = threadUrlNode?.firstEndDeepText()?.trim();
    final css = parseCssString(threadUrlNode?.attributes['style'] ?? '');

    final threadPrice = threadElement
        .querySelector('tr > th > span.xw1')
        ?.firstEndDeepText()
        ?.parseToInt();

    final threadAuthorNode = threadElement.querySelector('tr > td.by');
    final threadAuthorUrl =
        threadAuthorNode?.querySelector('cite > a')?.attributes['href'];
    final threadAuthorUid = threadAuthorUrl?.split('uid=').elementAtOrNull(1);
    final threadAuthorName =
        threadAuthorNode?.querySelector('cite > a')?.firstEndDeepText()?.trim();
    final threadPublishDate = threadAuthorNode
        ?.querySelector('em > span')
        ?.firstEndDeepText()
        ?.trim();

    final threadStatisticsNode = threadElement.querySelector('tr > td.num');
    final threadReplyCount = threadStatisticsNode
        ?.querySelector('a.xi2')
        ?.firstEndDeepText()
        ?.parseToInt();
    final threadViewCount = threadStatisticsNode
        ?.querySelector('em')
        ?.firstEndDeepText()
        ?.parseToInt();

    final threadLastReplyNode =
        threadElement.querySelector('tr > td.by:nth-child(5)');
    final threadLastReplyAuthorUrl =
        threadLastReplyNode?.querySelector('cite > a')?.attributes['href'];
    // We only have username here.
    final threadLastReplyAuthorName =
        threadLastReplyNode?.querySelector('cite > a')?.firstEndDeepText();
    final threadLastReplyTime =
        // Within 7 days.
        threadLastReplyNode
                ?.querySelector('em > a > span')
                ?.attributes['title'] ??
            // 7 days ago.
            threadLastReplyNode?.querySelector('em > a')?.firstEndDeepText();

    final threadID = threadUrl?.uriQueryParameter('tid');

    // Parse thread state from images following title text.
    final stateList = threadElement
        .querySelectorAll('tr > th > img')
        .map((e) => e._parseThreadStateFromImg())
        .toList()
        .flattened
        .toList();
    stateSet.addAll(stateList);

    return _NormalThreadInfo(
      title: threadTitle ?? '',
      url: threadUrl ?? '',
      threadID: threadID ?? '',
      author: User(
        name: threadAuthorName ?? '',
        uid: threadAuthorUid,
        url: threadAuthorUrl ?? '',
      ),
      publishDate: threadPublishDate?.parseToDateTimeUtc8(),
      latestReplyAuthor: User(
        name: threadLastReplyAuthorName ?? '',
        url: threadLastReplyAuthorUrl ?? '',
      ),
      latestReplyTime: threadLastReplyTime?.parseToDateTimeUtc8(),
      iconUrl: threadIconUrl ?? '',
      threadType: parseThreadType(threadTypeName, threadTypeUrl),
      replyCount: threadReplyCount ?? 0,
      viewCount: threadViewCount ?? 0,
      price: threadPrice,
      css: css,
      stateSet: stateSet,
    );
  }

  bool isValid() {
    if (title.isEmpty ||
        url.isEmpty ||
        iconUrl.isEmpty ||
        threadID.isEmpty ||
        !author.isValid() ||
        publishDate == null ||
        !latestReplyAuthor.isValid() ||
        latestReplyTime == null) {
      debug(
        'failed to parse normal thread page: $title, $url, $iconUrl, $author, $publishDate, $latestReplyAuthor, $latestReplyTime',
      );
      return false;
    }

    return true;
  }
}
