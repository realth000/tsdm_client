import 'package:flutter/foundation.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/models/locked.dart';
import 'package:tsdm_client/models/rate.dart';
import 'package:tsdm_client/models/user.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:universal_html/html.dart' as uh;

class _PostInfo {
  /// Constructor.
  _PostInfo({
    required this.postID,
    required this.postFloor,
    required this.author,
    required this.publishTime,
    required this.data,
    required this.replyAction,
    this.locked = const [],
    this.rate,
  });

  /// Post ID.
  String postID;

  /// Post floor number.
  /// Make it nullable to be compatible with all web page styles.
  int? postFloor;

  /// Post author, can not be null, should have avatar.
  User author;

  /// Post publish time.
  DateTime? publishTime;

  // TODO: Confirm data display.
  /// Post data.
  String data;

  /// `<div class="locked">` after `<div id="postmessage_xxx">`.
  /// Need purchase to see full thread content.
  List<Locked> locked;

  /// `<dl id="ratelog_xxx">` in `<div class="pcb">`.
  /// Rate records on this post.
  Rate? rate;

  /// Url to reply this post.
  String? replyAction;
}

/// Post model.
///
/// Each [Post] contains a reply.
@immutable
class Post {
  // [element] has id "post_$postID".
  Post.fromPostNode(uh.Element element)
      : _info = _buildPostFromElement(element);

  final _PostInfo _info;

  String get postID => _info.postID;

  int? get postFloor => _info.postFloor;

  User get author => _info.author;

  DateTime? get publishTime => _info.publishTime;

  String get data => _info.data;

  List<Locked> get locked => _info.locked;

  String? get replyAction => _info.replyAction;

  Rate? get rate => _info.rate;

  /// Build [Post] from [uh.Element].
  static _PostInfo _buildPostFromElement(uh.Element element) {
    final trRootNode = element.querySelector('table > tbody > tr');
    final postID = element.id.replaceFirst('post_', '');
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
    final postData =
        postDataNode?.querySelector('#postmessage_$postID')?.innerHtml;

    // Locked block in this post.
    //
    // Already purchased locked block has `<span>已购买人数: xx</span>`, here
    // only need not purchased ones.
    final locked = postDataNode
        ?.querySelectorAll('div.locked')
        .where((e) => e.querySelector('span') == null)
        .map(Locked.fromLockDivNode)
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
    Rate? rate;
    if (rateNode != null) {
      final r = Rate.fromRateLogNode(rateNode);
      if (r.isValid()) {
        rate = r;
      }
    }

    return _PostInfo(
      postID: postID,
      postFloor: postFloor,
      author: postAuthor,
      publishTime: postPublishTime,
      data: postData ?? '',
      locked: locked ?? [],
      replyAction: replyAction,
      rate: rate,
    );
  }

  /// Build a list of [Post] from the given [ThreadData] [uh.Element].
  ///
  /// [element]'s id is "postlist".
  static List<Post> buildListFromThreadDataNode(uh.Element element) {
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
        if (!post.isValid()) {
          debug('warning: post is empty');
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

  bool isValid() {
    if (postID.isEmpty || !author.isValid()) {
      debug('failed to parse post: $postID $author');
      return false;
    }
    return true;
  }
}
