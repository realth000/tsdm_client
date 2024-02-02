import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/shared/models/user.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:universal_html/html.dart' as uh;

class _LatestThreadInfo {
  const _LatestThreadInfo({
    required this.title,
    required this.url,
    required this.threadID,
    required this.forumName,
    required this.forumUrl,
    required this.replyCount,
    required this.viewCount,
    required this.latestReplyAuthor,
    required this.latestReplyTime,
    required this.quotedMessage,
  });

  /// Thread title.
  final String title;

  /// Thread url.
  final String url;

  /// Thread id.
  final String threadID;

  /// Forum name in this thread.
  final String forumName;

  /// Forum url in this thread.
  final String forumUrl;

  /// Thread reply count.
  ///
  /// >= 0.
  final int replyCount;

  /// Thread view times.
  ///
  /// >= 0.
  final int viewCount;

  /// Author of the latest reply.
  ///
  /// Actually can not be null.
  final User? latestReplyAuthor;

  /// Time of latest reply, with hour level time.
  ///
  /// e.g. "2023-03-04 00:11:22".
  /// Actually can not be null.
  final DateTime? latestReplyTime;

  /// Quoted message of last replied user that only exists in reply list.
  final String? quotedMessage;
}

/// Latest thread model.
class LatestThread {
  /// Build from <li> node.
  LatestThread.fromLi(uh.Element element) : _info = _buildFromLiNode(element);

  final _LatestThreadInfo? _info;

  static final _re = RegExp(r'(?<count>\d+)');

  /// Thread title.
  String? get title => _info?.title;

  /// Thread url.
  String? get url => _info?.url;

  /// Thread id.
  String? get threadID => _info?.threadID;

  /// Forum name the thread belongs to.
  String? get forumName => _info?.forumName;

  /// Forum url the thread belongs to.
  String? get forumUrl => _info?.forumUrl;

  /// The user info of latest replied user.
  User? get latestReplyAuthor => _info?.latestReplyAuthor;

  /// Time of latest reply.
  DateTime? get latestReplyTime => _info?.latestReplyTime;

  /// Total replies count.
  int? get replyCount => _info?.replyCount;

  /// View times count.
  int? get viewCount => _info?.viewCount;

  /// Quoted message to show.
  String? get quotedMessage => _info?.quotedMessage;

  /// <div id="threadlist">
  ///   <ul>
  ///     <li>
  ///       <h3 class="xs3">${TITLE}</h3>
  ///       <p class="xg1"></p>
  ///       <p></p>
  ///       ...
  ///     </li>
  ///   </ul>
  /// </div>
  ///
  /// Parse from the "li" tag node.
  static _LatestThreadInfo? _buildFromLiNode(uh.Element element) {
    final titleNode = element.querySelector('h3 > a');
    final title = titleNode?.firstEndDeepText();
    final url = titleNode?.firstHref()?.prependHost();
    final threadID = url?.uriQueryParameter('tid');

    final statisticsText =
        element.querySelector('p:nth-child(2)')?.firstEndDeepText();
    final matches = _re.allMatches(statisticsText ?? '').toList();
    final replyCount =
        matches.elementAtOrNull(0)?.namedGroup('count')?.parseToInt();
    final viewCount =
        matches.elementAtOrNull(1)?.namedGroup('count')?.parseToInt();

    final quotedMessage =
        element.querySelector('p:nth-child(3)')?.firstEndDeepText();

    final infoNode = element.querySelector('p:nth-child(4)');
    final publishTime = infoNode
        ?.querySelector('span:nth-child(1)')
        ?.firstEndDeepText()
        ?.parseToDateTimeUtc8();
    final username =
        infoNode?.querySelector('span:nth-child(2) > a')?.firstEndDeepText();
    final userUrl = infoNode
        ?.querySelector('span:nth-child(2) > a')
        ?.firstHref()
        ?.prependHost();
    final forumName =
        infoNode?.querySelector('span:nth-child(3) > a')?.firstEndDeepText();
    final forumUrl = infoNode
        ?.querySelector('span:nth-child(3) > a')
        ?.firstHref()
        ?.prependHost();

    if (title == null ||
        url == null ||
        threadID == null ||
        replyCount == null ||
        viewCount == null ||
        quotedMessage == null ||
        publishTime == null ||
        username == null ||
        userUrl == null ||
        forumName == null ||
        forumUrl == null) {
      debug('''
failed to parse LatestThread node: {
  title=$title,
  threadID=$threadID,
  url=$url,
  forumName=$forumName,
  forumUrl=$forumUrl,
  replyCount=$replyCount;
  viewCount=$viewCount;
  latestReplyAuthorName=$username,
  latestReplyAuthorUrl=$userUrl,
  latestReplyTime=$publishTime,
  quotedMessage=$quotedMessage,
}
''');
      return null;
    }
    return _LatestThreadInfo(
      title: title,
      threadID: threadID,
      url: url,
      forumName: forumName,
      forumUrl: forumUrl,
      replyCount: replyCount,
      viewCount: viewCount,
      latestReplyAuthor: User(
        name: username,
        url: userUrl,
      ),
      latestReplyTime: publishTime,
      quotedMessage: quotedMessage,
    );
  }
}
