part of 'models.dart';

extension _ParseExtension on uh.Element {
  static final _rateActionRe = RegExp("'rate', '(?<url>forum.php[^']*)',");

  String? _parseRateAction() {
    return _rateActionRe
        .firstMatch(attributes['onclick'] ?? '')
        ?.namedGroup('url');
  }
}

/// Post model.
///
/// Each [Post] contains a reply.
@MappableClass()
class Post with PostMappable {
  /// Constructor.
  const Post({
    required this.postID,
    required this.postFloor,
    required this.author,
    required this.publishTime,
    required this.data,
    required this.replyAction,
    required this.rateAction,
    required this.lastEditUsername,
    required this.lastEditTime,
    this.locked = const [],
    this.rate,
    this.packetUrl,
    this.editUrl,
    this.userBriefProfile,
  });

  /// Post ID.
  final String postID;

  /// Post floor number.
  /// Make it nullable to be compatible with all web page styles.
  final int? postFloor;

  /// Post author, can not be null, should have avatar.
  final User author;

  /// Post publish time.
  final DateTime? publishTime;

  // TODO: Confirm data display.
  /// Post data.
  final String data;

  /// `<div class="locked">` after `<div id="postmessage_xxx">`.
  /// Need purchase to see full thread content.
  final List<Locked> locked;

  /// `<dl id="ratelog_xxx">` in `<div class="pcb">`.
  /// Rate records on this post.
  ///
  /// Optional.
  final Rate? rate;

  /// Url to reply this post.
  final String? replyAction;

  /// Url to rate this post.
  final String? rateAction;

  /// 红包Url.
  ///
  /// Optional.
  final String? packetUrl;

  /// Url to edit this post.
  ///
  /// Generally this field is not null only when current user is the author
  /// of the post.
  ///
  /// Format: $HOME?mod=post&action=edit&fid=${fid}&tid=${tid}&pid=${pid}
  ///
  /// Though we can manually format this edit url, it is not available when
  /// the current user is not the author. So just parse the url and never
  /// manually format it.
  final String? editUrl;

  /// Name of user who last edited this post.
  final String? lastEditUsername;

  /// Time of last edited.
  final String? lastEditTime;

  /// Brief user profile of current post.
  ///
  /// May be null, maybe...
  final UserBriefProfile? userBriefProfile;

  /// Build [Post] from [element] that has attribute id "post_$postID".
  static Post? fromPostNode(uh.Element element) {
    final trRootNode = element.querySelector('table > tbody > tr');
    final postID = element.id.replaceFirst('post_', '');
    if (postID.isEmpty) {
      debug('failed to build post: empty post ID');
      return null;
    }
    // <td class="pls">
    final postInfoNode =
        trRootNode?.querySelector('td:nth-child(1) > div#ts_avatar_$postID');
    // <td class="plc tsdm_ftc">
    final postAuthorName =
        postInfoNode?.querySelector('div')?.firstEndDeepText();
    final postAuthorUrl =
        postInfoNode?.querySelector('div.avatar > a')?.attributes['href'];
    final postAuthorUid = postAuthorUrl?.split('uid=').elementAtOrNull(1);
    final postAuthorAvatarNode =
        postInfoNode?.querySelector('div.avatar > a > img');
    final postAuthorAvatarUrl =
        postAuthorAvatarNode?.attributes['data-original'] ??
            postAuthorAvatarNode?.attributes['src'];
    final postAuthor = User(
      name: postAuthorName ?? '',
      uid: postAuthorUid,
      url: postAuthorUrl?.prependHost() ?? '',
      avatarUrl: postAuthorAvatarUrl,
    );

    if (postAuthor.isNotValid()) {
      debug('failed to build post: invalid author: $postAuthor');
      return null;
    }

    final postDataNode = trRootNode?.querySelector('td:nth-child(2)');
    final postPublishTimeNode =
        postDataNode?.querySelector('#authorposton$postID');
    // Recent post can grep [publishTime] in the the "title" attribute
    // in first child.
    // Otherwise fallback split time string.
    final postPublishTime = postPublishTimeNode
            ?.querySelector('span')
            ?.attributes['title']
            ?.parseToDateTimeUtc8() ??
        postPublishTimeNode?.text?.substring(4).parseToDateTimeUtc8();
    // Sometimes the #postmessage_ID ID does not match postID.
    // e.g. tid=1184238
    // Use div.pcb to match it.
    //
    // Some threads have poll area in it, causing dom structure from:
    // <div class="pcb">
    //   <div class="t_fsz">
    //     <table cellspacing="0" cellpadding="0">
    //       Post Data
    //     </table>
    //   </div>
    // </div>
    //
    // to:
    //
    // <div class="pcb">
    //   <div class="pcbs">
    //     <table cellspacing="0" cellpadding="0">
    //       Post Data
    //     </table>
    //     <form id="poll" name="poll">
    //     </form>
    //   </div>
    // </div>
    //
    // Now we only search for the <div class="pcb"> node.
    final postData = postDataNode?.querySelector('div.pcb')?.innerHtml ??
        postDataNode?.querySelector('div.pcbs')?.innerHtml;

    // Locked block in this post.
    //
    // Already purchased locked block has `<span>已购买人数: xx</span>`, here
    // only need not purchased ones.
    //
    // Should not build locked with points which must be built in "postmessage"
    // munching.
    final locked = postDataNode
        ?.querySelectorAll('div.locked')
        .where((e) => e.querySelector('span') == null)
        .map(
          (e) => Locked.fromLockDivNode(
            e,
            allowWithPoints: false,
            allowWithReply: false,
          ),
        )
        .toList();

    final postFloor = postDataNode
        ?.querySelector('div.pi > strong > a > em')
        ?.firstEndDeepText()
        ?.parseToInt();

    // Some users have style overflow in signature so the following selector not
    // works:
    //
    // 'table > tbody > tr:nth-child(2) > td.tsdm_replybar > div.po > '
    //           'div > em > a[href*="action=reply"]',
    //
    // Should use a more permissive one.
    final replyAction = element
        .querySelector(
          'table > tbody > tr:nth-child(2) > td.tsdm_replybar div.pob em > '
          'a[href*="action=reply"]',
        )
        ?.firstHref();

    final rateNode = postDataNode?.querySelector('div.pct > div.pcb > dl.rate');
    final rate = Rate.fromRateLogNode(rateNode);
    final packetUrl = postDataNode
        ?.querySelector('div.pct > div#ts_packet > a')
        ?.attributes['href']
        ?.prependHost();

    // Parse rate action:
    // * If current post is the first floor in thread, rate action node is in <div id="fj">...</div>.
    // * If current post is not the first floor, rate action is in <div class="pob cl"><p>...</p></div>
    // Allow to be empty.
    String? rateAction;
    rateAction = element
        .querySelector('table  div.pob.cl p > a[onclick*="action=rate"]')
        ?._parseRateAction()
        ?.prependHost();

    rateAction ??= element
        .querySelector('div#fj > a[onclick*="action=rate"]')
        ?._parseRateAction()
        ?.prependHost();

    rateAction?.prependHost();

    // Url to edit the post is also in the `<div id=fj>` node.
    // We can only find it by the content text "编辑"。
    final editUrl = element
        .querySelectorAll('div#fj > a')
        .firstWhereOrNull((e) => e.firstEndDeepText() == '编辑')
        ?.attributes['href']
        ?.prependHost();

    // Check for last edit status.
    final lastEditText =
        element.querySelector('i.pstatus')?.innerText.trim().split(' ');
    String? lastEditUsername;
    String? lastEditTime;
    // 本帖最后由 $username 于 xxxx-xx-xx xx:xx:xx 编辑
    // 0         1         2 3          4        5
    if (lastEditText != null) {
      lastEditText.removeLast(); // 编辑
      final time = lastEditText.removeLast();
      final date = lastEditText.removeLast();
      lastEditText
        ..removeLast() // 于
        ..removeAt(0); // 本帖最后由
      final name = lastEditText.join(' ');
      lastEditUsername = name;
      lastEditTime = '$date $time';
    }

    // User profile
    final userProfileNode =
        element.querySelector('table > tbody > tr:nth-child(1) > td.pls');
    UserBriefProfile? userBriefProfile;
    if (userProfileNode != null) {
      userBriefProfile =
          UserBriefProfile.buildFromUserProfileNode(userProfileNode);
    } else {
      debug('post $postID: user profile node not found');
    }

    return Post(
      postID: postID,
      postFloor: postFloor,
      author: postAuthor,
      publishTime: postPublishTime,
      data: postData ?? '',
      locked: locked ?? [],
      replyAction: replyAction,
      rate: rate,
      rateAction: rateAction,
      packetUrl: packetUrl,
      editUrl: editUrl,
      lastEditUsername: lastEditUsername,
      lastEditTime: lastEditTime,
      userBriefProfile: userBriefProfile,
    );
  }

  /// Build a list of [Post] from the given [ThreadData] [uh.Element].
  ///
  /// [element]'s id is "postlist".
  static List<Post> buildListFromThreadDataNode(uh.Element? element) {
    if (element == null) {
      return [];
    }
    final threadDataRootNode =
        // Style 5
        element.querySelector('div.bm > div') ??
            // Some normal styles.
            element.childAtOrNull(2);
    var currentElement = threadDataRootNode;
    final tdPostList = <Post>[];
    while (currentElement != null) {
      // This while is a while (0), will not loop twice.
      if ((currentElement.attributes['id'] ?? '').startsWith('post_')) {
        // Build post here.
        final post = Post.fromPostNode(currentElement);
        if (post == null) {
          debug('warning: post is empty');
          continue;
        }
        tdPostList.add(post);
      }
      currentElement = currentElement.nextElementSibling;
    }
    if (tdPostList.isEmpty) {
      debug('warning: post list is empty');
    }
    return tdPostList;
  }
}
