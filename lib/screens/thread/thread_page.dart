import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/post.dart';
import '../../models/thread_data.dart';
import '../../states/consumer_window_state.dart';
import '../../widgets/network_list.dart';
import '../../widgets/post_card.dart';

/// Thread page.
class ThreadPage extends ConsumerStatefulWidget {
  /// Constructor.
  const ThreadPage({
    required this.threadID,
    required this.pageNumber,
    super.key,
  }) : _fetchUrl =
            'https://www.tsdm39.net/forum.php?mod=viewthread&tid=$threadID&extra=page%3D1&page=$pageNumber';

  /// Thread ID, tid.
  final String threadID;

  /// Thread Url
  final String _fetchUrl;

  /// Thread current page number.
  final String pageNumber;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ThreadPageState();
}

class _ThreadPageState extends ConsumerWindowState<ThreadPage> {
  @override
  Widget build(BuildContext context) => NetworkList<Post>(
        widget._fetchUrl,
        listBuilder: (document) {
          final threadAllData = <Post>[];
          final threadDataNode = document.getElementById('postlist');
          if (threadDataNode == null) {
            return <Post>[];
          }
          return buildPostListFromThreadElement(threadDataNode);
        },
        widgetBuilder: <Post>(context, post) => PostCard(post),
      );
}
