import 'package:flutter/foundation.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/models/post.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:universal_html/html.dart' as uh;

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
  ThreadData.fromPostListNode(uh.Element element)
      : _info = _buildThreadData(element);

  final _ThreadDataInfo _info;

  String get threadID => _info.threadID;

  String get title => _info.title;

  int get replyCount => _info.replyCount;

  int get viewCount => _info.viewCount;

  List<Post> get postList => _info.postList;

  /// Build a [ThreadData] from [uh.Element].
  static _ThreadDataInfo _buildThreadData(uh.Element element) {
    final rootNode = element.querySelector('table > body > tr');
    final tdViewCount = rootNode
            ?.querySelector('td > div > span:nth-child(2)')
            ?.text
            ?.parseToInt() ??
        -1;
    final tdReplyCount = rootNode
            ?.querySelector('td > div > span:nth-child(5)')
            ?.text
            ?.parseToInt() ??
        -1;
    final tdTitle = rootNode?.querySelector('td:nth-child(2) > h1')?.text;
    final tdID = rootNode
        ?.querySelector('td:nth-child(2) > h1 > span > a#thread_subject')
        ?.attributes['href'];

    final tdPostList = <Post>[];

    var currentElement = rootNode?.nextElementSibling;
    while (currentElement != null) {
      // This while is a while (0), will not loop twice.
      if ((currentElement.attributes['id'] ?? '').startsWith('post_')) {
        // <tr>
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
