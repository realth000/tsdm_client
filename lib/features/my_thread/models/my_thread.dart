import 'package:equatable/equatable.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/shared/models/user.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:universal_html/html.dart' as uh;

/// Current user's thread model in user's info page.
class MyThread extends Equatable {
  const MyThread({
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

  const MyThread.empty()
      : title = '',
        url = '',
        threadID = '',
        forumName = '',
        forumUrl = '',
        replyCount = -1,
        viewCount = -1,
        latestReplyAuthor = null,
        latestReplyTime = null,
        quotedMessage = null;

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

  /// <tbody>
  ///   <tr>
  ///     <td class="icn">...</td>
  ///     <th>
  ///       <a href="">${THREAD_TITLE}</a>
  ///       <span class="tps">...</span>
  ///     </th>
  ///     <td></td>
  ///     <td class="num"></td>
  ///     <td class="by"></td>
  ///   </tr>
  /// </tbody>
  static MyThread? fromTr(uh.Element element) {
    final titleNode = element.querySelector('th:nth-child(2) > a');
    final title = titleNode?.firstEndDeepText()?.trim();
    final url = titleNode?.firstHref();
    final threadID =
        url?.uriQueryParameter('tid') ?? url?.uriQueryParameter('ptid');

    final forumNode = element.querySelector('td:nth-child(3) > a');
    final forumName = forumNode?.firstEndDeepText();
    final forumUrl = forumNode?.firstHref();

    final replyCount =
        element.querySelector('td.num > a')?.firstEndDeepText()?.parseToInt();
    final viewCount =
        element.querySelector('td.num > em')?.firstEndDeepText()?.parseToInt();

    final latestReplyNode = element.querySelector('td.by');
    final latestReplyAuthorName =
        latestReplyNode?.querySelector('cite > a')?.firstEndDeepText();
    final latestReplyAuthorUrl =
        latestReplyNode?.querySelector('cite > a')?.firstHref();
    final latestReplyTime =
        // Within 7 days.
        latestReplyNode
                ?.querySelector('em > a > span')
                ?.attributes['title']
                ?.parseToDateTimeUtc8() ??
            // More than 7 days ago.
            latestReplyNode
                ?.querySelector('em > a')
                ?.firstEndDeepText()
                ?.parseToDateTimeUtc8();
    String? quotedMessage;
    if (element.classes.contains('bw0_all')) {
      quotedMessage =
          element.nextElementSibling?.querySelector('td.xg1')?.innerText.trim();
    }

    if (title == null ||
        threadID == null ||
        url == null ||
        forumName == null ||
        forumUrl == null ||
        replyCount == null ||
        viewCount == null ||
        latestReplyAuthorName == null ||
        latestReplyAuthorUrl == null ||
        latestReplyTime == null) {
      debug('''
failed to parse MyThread node: {
  title=$title,
  threadID=$threadID,
  url=$url,
  forumName=$forumName,
  forumUrl=$forumUrl,
  replyCount=$replyCount;
  viewCount=$viewCount;
  latestReplyAuthorName=$latestReplyAuthorName,
  latestReplyAuthorUrl=$latestReplyAuthorUrl,
  latestReplyTime=$latestReplyTime,
}
''');
      return null;
    }

    return MyThread(
      title: title,
      threadID: threadID,
      url: url,
      forumName: forumName,
      forumUrl: forumUrl,
      replyCount: replyCount,
      viewCount: viewCount,
      latestReplyAuthor: User(
        name: latestReplyAuthorName,
        url: latestReplyAuthorUrl,
      ),
      latestReplyTime: latestReplyTime,
      quotedMessage: quotedMessage,
    );
  }

  @override
  List<Object?> get props => [
        title,
        threadID,
        url,
        forumName,
        forumUrl,
        replyCount,
        viewCount,
        latestReplyAuthor,
        latestReplyTime,
        quotedMessage,
      ];
}
