import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:html/dom.dart';
import 'package:tsdm_client/utils/html_element.dart';

import 'post.dart';

part 'thread_data.freezed.dart';

/// Data of each thread.
@freezed
class ThreadData with _$ThreadData {
  /// Constructor.
  const factory ThreadData({
    /// Thread ID.
    required String threadID,

    /// Thread title.
    required String title,

    /// Total reply count.
    required int replyCount,

    /// Total view times count.
    required int viewCount,

    /// [Post] list.
    required List<Post> postList,
  }) = _ThreadData;
}

/// Build a [ThreadData] from [Element].
ThreadData? buildThreadDataFromElement(Element element) {
  final threadDataRootNode = element.childAtOrNull(0);
  late final int tdReplyCount;
  late final int tdViewCount;
  final tmpElementList = threadDataRootNode
      ?.getElementsByClassName('pls ptm pbm')
      .elementAtOrNull(0)
      ?.getElementsByClassName('xi1');
  if (tmpElementList == null || tmpElementList.length != 2) {
    return null;
  }
  tdViewCount = int.parse(tmpElementList[0].text);
  tdReplyCount = int.parse(tmpElementList[1].text);
  final tdTitle = threadDataRootNode
      ?.getElementsByClassName('ts')
      .elementAtOrNull(0)
      ?.childAtOrNull(0)
      ?.text
      .trim();
  final tdID =
      threadDataRootNode?.querySelector('#thread_subject')?.attributes['href'];

  final tdPostList = <Post>[];

  var currentElement = threadDataRootNode?.nextElementSibling;
  while (currentElement != null) {
    // This while is a while (0), will not loop twice.
    while ((currentElement.attributes['id'] ?? '').startsWith('post_')) {
      // <tr>
      final postRootNode =
          currentElement.childAtOrNull(0)?.childAtOrNull(0)?.childAtOrNull(0);
      if (postRootNode == null) {
        break;
      }
      // Build post here.
      final post = buildPostFromElement(postRootNode);
      if (post == null) {
        break;
      }
      tdPostList.add(post);
      break;
    }
    currentElement = currentElement.nextElementSibling;
  }
  if (tdID == null || tdTitle == null) {
    return null;
  }

  return ThreadData(
    threadID: tdID,
    title: tdTitle,
    replyCount: tdReplyCount,
    viewCount: tdViewCount,
    postList: tdPostList,
  );
}

/// Build a list of [Post] from the given [ThreadData] [Element].
List<Post> buildPostListFromThreadElement(Element element) {
  final threadDataRootNode = element.childAtOrNull(0);
  var currentElement = threadDataRootNode?.nextElementSibling;
  final tdPostList = <Post>[];
  while (currentElement != null) {
    // This while is a while (0), will not loop twice.
    while ((currentElement.attributes['id'] ?? '').startsWith('post_')) {
      // <tr>
      final postRootNode =
          currentElement.childAtOrNull(0)?.childAtOrNull(0)?.childAtOrNull(0);
      if (postRootNode == null) {
        break;
      }
      // Build post here.
      final post = buildPostFromElement(postRootNode);
      if (post == null) {
        break;
      }
      tdPostList.add(post);
      break;
    }
    currentElement = currentElement.nextElementSibling;
  }
  return tdPostList;
}
