import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as dom;
import 'package:tsdm_client/models/user.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/utils/html_element.dart';
import 'package:tsdm_client/utils/prefix_url.dart';
import 'package:tsdm_client/utils/time.dart';

class _PostInfo {
  /// Constructor.
  _PostInfo({
    required this.postID,
    required this.author,
    required this.publishTime,
    required this.data,
  });

  /// Post ID.
  String postID;

  /// Post author, can not be null, should have avatar.
  User author;

  /// Post publish time.
  DateTime publishTime;

  // TODO: Confirm data display.
  /// Post data.
  String data;
}

/// Post model.
///
/// Each [Post] contains a reply.
@immutable
class Post {
  // [element] has id "post_$postID".
  Post.fromPostNode(dom.Element element)
      : _info = _buildPostFromElement(element);

  final _PostInfo _info;

  String get postID => _info.postID;

  User get author => _info.author;

  DateTime get publishTime => _info.publishTime;

  String get data => _info.data;

  /// Build [Post] from [dom.Element].
  static _PostInfo _buildPostFromElement(dom.Element element) {
    final trRootNode =
        element.childAtOrNull(0)?.childAtOrNull(0)?.childAtOrNull(0);
    final postID = trRootNode
        ?.childAtOrNull(0)
        ?.attributes['id']
        ?.replaceFirst('userinfo_', '');
    // <td class="pls">
    final postInfoNode =
        trRootNode?.childAtOrNull(0)?.querySelector('#ts_avatar_$postID');
    // <td class="plc tsdm_ftc">
    final postDataNode = trRootNode?.childAtOrNull(1);

    final postAuthorName = postInfoNode?.childAtOrNull(0)?.text;
    final postAuthorUrl =
        postInfoNode?.childAtOrNull(2)?.childAtOrNull(0)?.attributes['href'];
    final postAuthorUid = postAuthorUrl?.split('uid=').elementAtOrNull(1);
    final tmpNode1 =
        postInfoNode?.childAtOrNull(2)?.childAtOrNull(0)?.childAtOrNull(0);
    final postAuthorAvatarUrl =
        tmpNode1?.attributes['data-original'] ?? tmpNode1?.attributes['src'];
    final postAuthor = User(
      name: postAuthorName ?? '',
      uid: postAuthorUid,
      url: postAuthorUrl == null ? '' : addUrlPrefix(postAuthorUrl),
      avatarUrl: postAuthorAvatarUrl,
    );
    final tmpNode2 = postDataNode?.querySelector('#authorposton$postID');
    // Recent post can grep [publishTime] in the the "title" attribute
    // in first child.
    // Otherwise fallback split time string.
    final postPublishTime = tmpNode2?.childAtOrNull(0)?.attributes['title'] ??
        tmpNode2?.text.split(' ').elementAtOrNull(1);
    final postData =
        postDataNode?.querySelector('#postmessage_$postID')?.innerHtml;
    // postDataNode?.getElementsByClassName('pcb').elementAtOrNull(0)?.innerHtml;
    // if (postPublishTime == null || postData == null) {
    //   debug('failed to parse post: $postPublishTime $postData');
    //   return _PostInfo(
    //
    //   );
    // }
    return _PostInfo(
      postID: postID ?? '',
      author: postAuthor,
      publishTime: postPublishTime == null
          ? DateTime.utc(0)
          : DateTime.parse(formatTimeStringWithUTC8(postPublishTime)),
      data: postData ?? '',
    );
  }

  /// Build a list of [Post] from the given [ThreadData] [dom.Element].
  ///
  /// [element]'s id is "postlist".
  static List<Post> buildListFromThreadDataNode(dom.Element element) {
    final threadDataRootNode = element.childAtOrNull(2);
    var currentElement = threadDataRootNode;
    final tdPostList = <Post>[];
    while (currentElement != null) {
      // This while is a while (0), will not loop twice.
      if ((currentElement.attributes['id'] ?? '').startsWith('post_')) {
        final postRootNode = currentElement;
        // Build post here.
        final post = Post.fromPostNode(postRootNode);
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
