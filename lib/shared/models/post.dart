import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/shared/models/locked.dart';
import 'package:tsdm_client/shared/models/rate.dart';
import 'package:tsdm_client/shared/models/user.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:universal_html/html.dart' as uh;

extension _ParseExtension on uh.Element {
  static final _rateActionRe = RegExp(r"'rate', '(?<url>forum.php[^']*)',");

  String? _parseRateAction() {
    return _rateActionRe
        .firstMatch(attributes['onclick'] ?? '')
        ?.namedGroup('url');
  }
}

/// Post model.
///
/// Each [Post] contains a reply.
class Post extends Equatable {
  /// Constructor.
  const Post({
    required this.postID,
    required this.postFloor,
    required this.author,
    required this.publishTime,
    required this.data,
    required this.replyAction,
    required this.rateAction,
    this.locked = const [],
    this.rate,
    this.packetUrl,
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

  // [element] has id "post_$postID".
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
    final postData = postDataNode?.querySelector('div.t_fsz')?.innerHtml;

    // Locked block in this post.
    //
    // Already purchased locked block has `<span>已购买人数: xx</span>`, here
    // only need not purchased ones.
    //
    // Should not build locked with points which must be built in "postmessage" munching.
    final locked = postDataNode
        ?.querySelectorAll('div.locked')
        .where((e) => e.querySelector('span') == null)
        .map((e) => Locked.fromLockDivNode(
              e,
              allowWithPoints: false,
              allowWithReply: false,
              allowWithAuthor: false,
            ))
        .toList();

    final postFloor = postDataNode
        ?.querySelector('div.pi > strong > a > em')
        ?.firstEndDeepText()
        ?.parseToInt();

    final replyAction = element
        .querySelector(
            'table > tbody > tr:nth-child(2) > td.tsdm_replybar > div.po > div > em > a')
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
        .querySelector('table  div.pob.cl > p')
        ?.querySelectorAll('a')
        .firstWhereOrNull((e) => e.firstEndDeepText() == '评分')
        ?._parseRateAction()
        ?.prependHost();

    rateAction ??= element
        .querySelectorAll('div#fj > a')
        .firstWhereOrNull((e) => e.firstEndDeepText() == '评分')
        ?._parseRateAction()
        ?.prependHost();

    rateAction?.prependHost();

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

  @override
  List<Object?> get props => [
        postID,
        postFloor,
        author,
        publishTime,
        data,
        replyAction,
        rateAction,
        locked,
        rate,
        packetUrl,
      ];
}
