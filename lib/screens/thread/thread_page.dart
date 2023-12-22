import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/models/post.dart';
import 'package:tsdm_client/models/user.dart';
import 'package:tsdm_client/screens/thread/post_list.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/widgets/post_card.dart';
import 'package:tsdm_client/widgets/reply_bar.dart';

/// Thread page.
class ThreadPage extends ConsumerStatefulWidget {
  /// Constructor.
  const ThreadPage({
    required this.threadID,
    required this.pageNumber,
    this.title,
    this.threadType,
    super.key,
  }) : _fetchUrl =
            '$baseUrl/forum.php?mod=viewthread&tid=$threadID&extra=page%3D1&page=$pageNumber';

  final String? title;

  /// Thread ID, tid.
  final String threadID;

  /// Thread Url
  final String _fetchUrl;

  /// Thread current page number.
  final String pageNumber;

  /// Thread type.
  ///
  /// Sometimes we do not know the thread type before we load it, redirect from
  /// homepage, for example. So it's a nullable String.
  final String? threadType;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ThreadPageState();
}

/// TODO: Refactor all callbacks and communicate in [ReplyBar] and [PostList].
class _ThreadPageState extends ConsumerState<ThreadPage> {
  String? title;

  final _replyBarController = ReplyBarController();

  /// Flag indicating current page has [Post] or not.
  var _hasPost = false;

  Future<void> replyPostCallback(
      User user, int? postFloor, String? replyAction) async {
    if (replyAction == null) {
      return;
    }

    _replyBarController
      ..replyAction = replyAction
      ..setHintText(
          '${context.t.threadPage.sendReplyHint} ${user.name} ${postFloor == null ? "" : "#$postFloor"}')
      ..requestFocus();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        // Title priority:
        // 1. `widget.title`: Specified title in widget constructor.
        // 2. `title`: Title found in html document.
        // 3. `context.t.appName`: Default application name.
        // appBar: AppBar(title: Text(widget.title ?? title ?? '')),
        body: Column(
          children: [
            Expanded(
              child: PostList<Post>(
                widget.threadID,
                widget._fetchUrl,
                title: title ?? '',
                widget.threadID,
                widget.threadType,
                listBuilder: (document) {
                  final threadDataNode = document.querySelector('div#postlist');
                  if (threadDataNode == null) {
                    debug('thread postlist not found');
                    return <Post>[];
                  }
                  if (!mounted) {
                    return <Post>[];
                  }
                  setState(() {
                    _hasPost = true;
                  });

                  // Sometimes we do not know the web page title outside this widget,
                  // so here should use the title in html document as fallback.
                  //
                  // Use the title in html document to ensure displaying the full thread title.
                  if (mounted) {
                    setState(() {
                      title =
                          document.querySelector('title')?.text?.trimTitle();
                    });
                  }

                  return Post.buildListFromThreadDataNode(threadDataNode);
                },
                widgetBuilder: (context, post) => PostCard(
                  post,
                  replyCallback: replyPostCallback,
                ),
                canFetchMorePages: true,
                replyFormHashCallback: (replyParameters) {
                  _replyBarController.replyParameters = replyParameters;
                },
                useDivider: true,
              ),
            ),
            if (_hasPost)
              ReplyBar(
                controller: _replyBarController,
              ),
          ],
        ),
      );
}
