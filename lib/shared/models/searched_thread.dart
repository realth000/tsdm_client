import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/shared/models/user.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:universal_html/html.dart' as uh;

class _SearchedThreadInfo {
  _SearchedThreadInfo({
    required this.tid,
    required this.title,
    required this.url,
    required this.author,
    required this.publishTime,
    required this.forumName,
    required this.forumUrl,
  });

  final int tid;

  /// Thread title.
  final String title;

  /// Thread url.
  final String url;

  /// Thread author, including username and user space url.
  final User author;

  /// Thread publish date.
  final DateTime publishTime;

  /// Forum name this thread belongs to.
  final String forumName;

  /// Forum url this thread belongs to.
  final String forumUrl;

  @override
  String toString() {
    return 'SearchThread{ id=$tid, title=$title, url=$url, author=$author, publishTime=$publishTime, forumName=$forumName, forumUrl=$forumUrl }';
  }
}

/// Thread in search result.
class SearchedThread {
  /// Build a [SearchedThread] from [element] <div class="ts_se_rs">.
  SearchedThread.fromDivNode(uh.Element element)
      : _info = _buildFromDivNode(element);

  final _SearchedThreadInfo? _info;

  int? get threadID => _info?.tid;

  String? get title => _info?.title;

  String? get url => _info?.url;

  User? get author => _info?.author;

  DateTime? get publishTime => _info?.publishTime;

  String? get forumName => _info?.forumName;

  String? get forumUrl => _info?.forumUrl;

  bool get isValid => _info != null;

  /// Build [_SearchThreadInfo from [element] <div class="ts_se_rs">.
  static _SearchedThreadInfo? _buildFromDivNode(uh.Element element) {
    final threadTitleNode = element.querySelector('p:nth-child(1) > a');
    final title = threadTitleNode?.firstEndDeepText();
    final url = threadTitleNode?.firstHref();

    final userNode = element.querySelector('p:nth-child(2) > a');
    final username = userNode?.firstEndDeepText();
    final userUrl = userNode?.firstHref();

    final publishTime = element
        .querySelector('p:nth-child(2) > span.dateshow')
        ?.firstEndDeepText()
        ?.trim()
        .substring(2)
        .parseToDateTimeUtc8();

    final forumNode =
        element.querySelector('p:nth-child(2) > span.fid > a.forum_l');
    final forumName = forumNode?.firstEndDeepText();
    final forumUrl = forumNode?.firstHref();

    if (title == null ||
        url == null ||
        username == null ||
        userUrl == null ||
        publishTime == null ||
        forumName == null ||
        forumUrl == null) {
      debug(
          'invalid searched thread: $title, $url, $username, $userUrl, $publishTime, $forumName, $forumUrl');
      return null;
    }

    final re = RegExp(r'tid=(?<tid>\d+)');
    final tid = re.firstMatch(url)!.namedGroup('tid')?.parseToInt();

    return _SearchedThreadInfo(
      tid: tid!,
      title: title,
      url: url,
      author: User(name: username, url: userUrl),
      publishTime: publishTime,
      forumName: forumName,
      forumUrl: forumUrl,
    );
  }

  @override
  String toString() {
    return '$_info';
  }
}
