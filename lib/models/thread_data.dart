import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as dom;
import 'package:tsdm_client/models/post.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/utils/html_element.dart';

@immutable
class _ThreadDataInfo {
  /// Constructor.
  const _ThreadDataInfo({
    required this.threadID,
    required this.title,
    required this.replyCount,
    required this.viewCount,
    required this.postList,
  });

  /// Thread ID.
  final String threadID;

  /// Thread title.
  final String title;

  /// Total reply count.
  final int replyCount;

  /// Total view times count.
  final int viewCount;

  /// [Post] list.
  final List<Post> postList;
}

/// Data of each thread.
@immutable
class ThreadData {
  /// [element] is "postlist".
  ThreadData.fromPostListNode(dom.Element element)
      : _info = _buildThreadData(element);

  final _ThreadDataInfo _info;

  String get threadID => _info.threadID;

  String get title => _info.title;

  int get replyCount => _info.replyCount;

  int get viewCount => _info.viewCount;

  List<Post> get postList => _info.postList;

  /// Build a [ThreadData] from [dom.Element].
  static _ThreadDataInfo _buildThreadData(dom.Element element) {
    final threadDataRootNode = element.childAtOrNull(0);
    late final int tdReplyCount;
    late final int tdViewCount;
    final tmpElementList = threadDataRootNode
        ?.getElementsByClassName('pls ptm pbm')
        .elementAtOrNull(0)
        ?.getElementsByClassName('xi1');
    // if (tmpElementList == null || tmpElementList.length != 2) {
    //   debug('failed to parse thread data: $tmpElementList');
    //   return null;
    // }
    tdViewCount = int.parse(tmpElementList?[0].text ?? '-1');
    tdReplyCount = int.parse(tmpElementList?[1].text ?? '-1');
    final tdTitle = threadDataRootNode
        ?.getElementsByClassName('ts')
        .elementAtOrNull(0)
        ?.childAtOrNull(0)
        ?.text
        .trim();
    final tdID = threadDataRootNode
        ?.querySelector('#thread_subject')
        ?.attributes['href'];

    final tdPostList = <Post>[];

    var currentElement = threadDataRootNode?.nextElementSibling;
    while (currentElement != null) {
      // This while is a while (0), will not loop twice.
      if ((currentElement.attributes['id'] ?? '').startsWith('post_')) {
        // <tr>
        // final postRootNode =
        //     currentElement.childAtOrNull(0)?.childAtOrNull(0)?.childAtOrNull(0);
        final postRootNode = currentElement;
        // Build post here.
        final post = Post.fromPostNode(postRootNode);
        if (post.isValid()) {
          tdPostList.add(post);
        }
      }
      currentElement = currentElement.nextElementSibling;
    }

    return _ThreadDataInfo(
      threadID: tdID ?? '',
      title: tdTitle ?? '',
      replyCount: tdReplyCount,
      viewCount: tdViewCount,
      postList: tdPostList,
    );
  }

  bool isValid() {
    if (threadID.isEmpty || title.isEmpty) {
      debug('failed to parse thread data: $threadID $title');
      return false;
    }
    return true;
  }
}
