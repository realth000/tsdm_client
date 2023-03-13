import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:html/dom.dart';

import '../utils/html_element.dart';
import '../utils/prefix_url.dart';
import '../utils/time.dart';
import 'user.dart';

part 'post.freezed.dart';

/// Post model.
///
/// Each [Post] contains a reply.
@freezed
class Post with _$Post {
  /// Constructor.
  const factory Post({
    /// Post ID.
    required String postID,

    /// Post author, can not be null, should have avatar.
    required User author,

    /// Post publish time.
    required DateTime publishTime,

    // TODO: Confirm data display.
    /// Post data.
    required String data,
  }) = _Post;
}

/// Build [Post] from [Element].
Post? buildPostFromElement(Element element) {
  final postID =
      element.childAtOrNull(0)?.attributes['id']?.replaceFirst('userinfo_', '');
  // <td class="pls">
  final postInfoNode =
      element.childAtOrNull(0)?.querySelector('#ts_avatar_$postID');
  // <td class="plc tsdm_ftc">
  final postDataNode = element.childAtOrNull(1);

  final postAuthorName = postInfoNode?.childAtOrNull(0)?.text;
  final postAuthorUrl =
      postInfoNode?.childAtOrNull(2)?.childAtOrNull(0)?.attributes['href'];
  final postAuthorUid = postAuthorUrl?.split('uid=').elementAtOrNull(1);
  final tmpNode1 =
      postInfoNode?.childAtOrNull(2)?.childAtOrNull(0)?.childAtOrNull(0);
  final postAuthorAvatarUrl =
      tmpNode1?.attributes['data-original'] ?? tmpNode1?.attributes['src'];
  if (postID == null ||
      postAuthorName == null ||
      postAuthorUid == null ||
      postAuthorUrl == null ||
      postAuthorAvatarUrl == null) {
    return null;
  }
  final postAuthor = User(
    name: postAuthorName,
    uid: postAuthorUid,
    url: addUrlPrefix(postAuthorUrl),
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
  if (postPublishTime == null || postData == null) {
    return null;
  }
  return Post(
    postID: postID,
    author: postAuthor,
    publishTime: DateTime.parse(formatTimeStringWithUTC8(postPublishTime)),
    data: postData,
  );
}
