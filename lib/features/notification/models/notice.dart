part of 'models.dart';

/// TODO: Refactor with sealed class.
/// Different notice types.
enum NoticeType {
  /// Another user replied current user's thread or post.
  reply,

  /// Another user rated current user's thread or post.
  rate,

  /// Another user rated current user's thread or post using batch task.
  ///
  /// Usually the plugin is "Project Minerva" but do not reply on it.
  batchRate,

  /// Another mentioned current user in a post.
  mention,

  /// Another user invited the current user to take part in specified thread.
  invite,

  /// Another user has became the friend of current user.
  ///
  /// xxx 和您成为了好友
  newFriend,
}

/// A single notice for current user.
@MappableClass()
class Notice with NoticeMappable {
  /// Constructor.
  const Notice({
    required this.userAvatarUrl,
    required this.username,
    required this.userSpaceUrl,
    required this.noticeTime,
    required this.noticeTimeString,
    required this.noticeThreadUrl,
    required this.noticeThreadTitle,
    required this.redirectUrl,
    required this.ignoreCount,
    required this.noticeType,
    required this.score,
    required this.quotedMessage,
    required this.taskId,
  });

  /// User avatar.
  ///
  /// User is who triggered this notice.
  /// Following "user"s are the same.
  final String? userAvatarUrl;

  /// Username.
  final String? username;

  /// Link to that user's user space.
  final String? userSpaceUrl;

  /// [DateTime] format notice time.
  ///
  /// Use this instead of [noticeTimeString].
  final DateTime? noticeTime;

  /// String format notice time.
  ///
  /// May not be used, better to use [noticeTime];
  final String noticeTimeString;

  /// Url to the thread that contains this notice's reply.
  /// Following "thread"'s are the same.
  final String? noticeThreadUrl;

  /// Thread title.
  final String? noticeThreadTitle;

  /// Link directly to the notice related reply in thread.
  ///
  /// This is helpful when redirecting to the related post in thread, though
  /// not used yet.
  final String? redirectUrl;

  /// Number of ignored same notice.
  ///
  /// Will be null when there is no ignored notice.
  final int? ignoreCount;

  /// Type of current notice.
  final NoticeType noticeType;

  /// Score received.
  final String? score;

  /// Comment when scoring.
  final String? quotedMessage;

  /// Task id of batch operation.
  ///
  /// Only useful when NoticeType is batchRate.
  final String? taskId;

  /// Build a [Notice] from html node [element] :
  /// div#ct > div.mn > div.bm.bw0 > div.xld.xlda > div.nts > div.cl
  ///
  /// This css selector may work in all web page styles.
  static Notice? fromClNode(uh.Element element) {
    final userAvatarUrl = element.querySelector('dd.avt > a > img')?.imageUrl();
    var userSpaceUrl =
        element.querySelector('dd.avt > a')?.firstHref()?.prependHost();

    final noticeNode = element.querySelector('dt > span > span');
    final noticeTime = noticeNode?.attributes['title']?.parseToDateTimeUtc8();
    final noticeTimeString = noticeNode?.firstEndDeepText();

    String? score;
    String? quotedMessage;
    String? taskId;

    // score:
    // <dd class="ntc_body" style="">
    //   您在主题
    //   <a href="...mod=redirect&goto=findpost&pid=xxx&ptid=&&&">${THREAD_TITLE}</a>
    //   的帖子被
    //   <a hrefe="...mod=userspace&uid=xxx">${USERNAME}</a>
    //   评价 xxx +xx
    //   <div class="quote">
    //     <blockquote>${REASON}</blockquote>
    //   </div>
    // </dd>
    //
    // mention:
    // <dd class="ntc_body" style="">
    //   您好！xxx邀请（在帖子中提到了您），具体内容（
    //   <a class="lit" href="...mod=redirecet&goto=findpost&pid=xxx&ptd=xxx">查看更多内容</a>
    //   ）
    //   <blockquote>${POST_DATA}</blockquote>
    //   您也可以直接回复：
    //   <a class="lit" href="...mode=post&action=reply&tid=xxx&repquote=xxx"></a>
    // </dd>
    //
    // batchRate:
    // <dd class="ntc_body" style="">
    //   您在主题 <a href="" target="_blank"> $ThreadTitle</a> 的帖子被 <a href="$UserSpace" target="_blank">$Username</a> 评分 $rate<br>
    //   <b>执行者：</b><a href="$UserSpace" target="_blank">$Username</a><br><b>理由：</b>$Reason<br><b>任务ID：</b>TaskID
    // </dd>
    final quoteNode = element.querySelector('dd.ntc_body > div.quote');
    final mentionNode = element.querySelector('dd.ntc_body > blockquote');
    final litNode = element.querySelector('dd.ntc_body > a.lit');
    late final NoticeType noticeType;
    if (quoteNode != null) {
      noticeType = NoticeType.rate;
      final n = element.querySelector('dd.ntc_body');
      score = n?.nodes[n.nodes.length - 2].text?.trim().replaceFirst('评分 ', '');
      quotedMessage = quoteNode.innerText;
    } else if (mentionNode != null) {
      noticeType = NoticeType.mention;
    } else if (litNode?.attributes['href']?.contains('&tid=') ?? false) {
      noticeType = NoticeType.invite;
    } else if (element.querySelectorAll('dd.ntc_body > a').length == 1) {
      noticeType = NoticeType.newFriend;
    } else if (element
            .querySelectorAll('dd.ntc_body > b')
            .lastOrNull
            ?.innerText
            .contains('任务ID') ??
        false) {
      noticeType = NoticeType.batchRate;
    } else {
      noticeType = NoticeType.reply;
    }

    String? username;
    String? noticeThreadUrl;
    String? noticeThreadTitle;
    String? redirectUrl;

    final a1Node = element.querySelector('dd.ntc_body > a:nth-child(1)');
    final a2Node = element.querySelector('dd.ntc_body > a:nth-child(2)');
    if (noticeType == NoticeType.reply || noticeType == NoticeType.invite) {
      username = a1Node?.firstEndDeepText();
      noticeThreadUrl = a2Node?.firstHref();
      noticeThreadTitle = a2Node?.firstEndDeepText();
      redirectUrl = element
          .querySelector('dd.ntc_body > a:nth-child(3)')
          ?.firstHref()
          ?.prependHost();
    } else if (noticeType == NoticeType.mention) {
      final n =
          element.querySelector('dd.ntc_body')?.nodes.firstOrNull?.text?.trim();
      const usernameBeginOffset = 3;
      final usernameEndOffset = n?.indexOf('邀请');
      username = usernameEndOffset == null
          ? ''
          : n?.substring(usernameBeginOffset, usernameEndOffset);
      redirectUrl = a1Node?.firstHref()?.prependHost();
      quotedMessage = mentionNode!.firstEndDeepText()?.trim();
    } else if (noticeType == NoticeType.newFriend) {
      username = a1Node?.firstEndDeepText();
      userSpaceUrl = a1Node?.attributes['href'];
    } else if (noticeType == NoticeType.batchRate) {
      noticeThreadTitle = a1Node?.firstEndDeepText();
      redirectUrl = a1Node?.firstHref()?.prependHost();
      // Here we should use `:last-of-type` but dart html package does not
      // support it, and we also dont want to use `querySelectorAll.lastOrNull`.
      //
      // Assume the user node is always the 5th child.
      final a3Node = element.querySelector('dd.ntc_body > a:nth-child(5)');
      userSpaceUrl = a3Node?.firstHref();
      username = a3Node?.firstEndDeepText();
      final n = element.querySelector('dd.ntc_body');
      score = n?.nodes.elementAtOrNull(4)?.text?.trim().replaceFirst('评分 ', '');
      taskId = n?.nodes.lastOrNull?.text?.trim();
      final bList = n?.querySelectorAll('b');
      if (bList?.length == 3) {
        quotedMessage = bList!.elementAt(1).nextNode?.text;
      }
    } else {
      noticeThreadTitle = a1Node?.firstEndDeepText();
      redirectUrl = a1Node?.firstHref()?.prependHost();
      // Fix user space url here.
      userSpaceUrl = a2Node?.firstHref();
      username = a2Node?.firstEndDeepText();
    }

    final ignoreCount = element
        .querySelector('dd.xg1.xw0')
        ?.firstEndDeepText()
        ?.split(' ')
        .elementAtOrNull(1)
        ?.parseToInt();

    // Validate
    if (noticeType == NoticeType.mention) {
      if (username == null || userSpaceUrl == null || redirectUrl == null) {
        talker.error(
          'failed to parse mention notice: $username, $userSpaceUrl, '
          '$noticeTime, $redirectUrl',
        );
        return null;
      }
    } else if (noticeType == NoticeType.newFriend) {
      if (username == null || userSpaceUrl == null) {
        talker.error('failed to parse new friend notice:'
            '$username, $userSpaceUrl');
        return null;
      }
    } else if (noticeType == NoticeType.batchRate) {
      if (username == null || userSpaceUrl == null || taskId == null) {
        talker.error('failed to parse batch rate notice: '
            '$username, $userSpaceUrl, $taskId');
        return null;
      }
    } else if (username == null ||
        userSpaceUrl == null ||
        noticeTime == null ||
        noticeThreadTitle == null ||
        redirectUrl == null) {
      talker.error(
        'failed to parse $noticeType notice: $username, $userSpaceUrl, '
        '$noticeTime, $noticeThreadUrl, $noticeThreadTitle, $redirectUrl',
      );
      return null;
    }

    return Notice(
      userAvatarUrl: userAvatarUrl,
      noticeTime: noticeTime,
      noticeTimeString: noticeTimeString ?? '',
      userSpaceUrl: userSpaceUrl,
      username: username,
      noticeThreadUrl: noticeThreadUrl,
      noticeThreadTitle: noticeThreadTitle,
      redirectUrl: redirectUrl,
      ignoreCount: ignoreCount,
      noticeType: noticeType,
      score: score,
      quotedMessage: quotedMessage,
      taskId: taskId,
    );
  }
}
