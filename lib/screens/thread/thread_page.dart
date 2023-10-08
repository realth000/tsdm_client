import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/models/post.dart';
import 'package:tsdm_client/models/thread_data.dart';
import 'package:tsdm_client/states/consumer_window_state.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/widgets/network_list.dart';
import 'package:tsdm_client/widgets/post_card.dart';

/// Thread page.
class ThreadPage extends ConsumerStatefulWidget {
  /// Constructor.
  const ThreadPage({
    required this.threadID,
    required this.pageNumber,
    this.title,
    super.key,
  }) : _fetchUrl =
            'https://www.tsdm39.com/forum.php?mod=viewthread&tid=$threadID&extra=page%3D1&page=$pageNumber';

  final String? title;

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
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.title ?? context.t.appName)),
        body: NetworkList<Post>(
          widget._fetchUrl,
          listBuilder: (document) {
            final threadDataNode = document.getElementById('postlist');
            if (threadDataNode == null) {
              debug('thread postlist not found');
              return <Post>[];
            }
            return buildPostListFromThreadElement(threadDataNode);
          },
          widgetBuilder: (context, post) => PostCard(post),
        ),
      );
}
