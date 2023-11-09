import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/models/post.dart';
import 'package:tsdm_client/models/reply_parameters.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';
import 'package:tsdm_client/screens/thread/reply_bar.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/utils/show_dialog.dart';
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
            '$baseUrl/forum.php?mod=viewthread&tid=$threadID&extra=page%3D1&page=$pageNumber';

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

class _ThreadPageState extends ConsumerState<ThreadPage> {
  String? title;

  ReplyParameters? _replyParameters;

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
              child: NetworkList<Post>(
                widget._fetchUrl,
                title: widget.title ?? title ?? '',
                listBuilder: (document) {
                  final threadDataNode = document.querySelector('div#postlist');
                  if (threadDataNode == null) {
                    debug('thread postlist not found');
                    return <Post>[];
                  }

                  // Sometimes we do not know the web page title outside this widget,
                  // so here should use the title in html document as fallback.
                  //
                  // Note that the specified title (in widget constructor) is prior to
                  // this html document title, only use html title when that title is null.
                  if (widget.title == null && mounted) {
                    setState(() {
                      title = document.querySelector('title')?.text;
                    });
                  }

                  return Post.buildListFromThreadDataNode(threadDataNode);
                },
                widgetBuilder: (context, post) => PostCard(post),
                canFetchMorePages: true,
                replyFormHashCallback: (replyParameters) {
                  _replyParameters = replyParameters;
                },
                useDivider: true,
              ),
            ),
            ReplyBar(
              sendCallBack: (message) async {
                if (_replyParameters == null) {
                  return false;
                }
                final formData = {
                  'message': message,
                  'usesig': 1,
                  'posttime': _replyParameters!.postTime,
                  'formhash': _replyParameters!.formHash,
                  'subject': _replyParameters!.subject,
                };

                final resp = await ref.read(netClientProvider()).post(
                      formatReplyThreadUrl(
                          _replyParameters!.fid, widget.threadID),
                      data: formData,
                      options: Options(
                        headers: {
                          'Content-Type': 'application/x-www-form-urlencoded'
                        },
                      ),
                    );

                if (resp.statusCode != HttpStatus.ok) {
                  if (!context.mounted) {
                    return false;
                  }
                  await showMessageSingleButtonDialog(
                    context: context,
                    title: context.t.threadPage.sendReply,
                    message: context.t.threadPage
                        .replyFailed(err: '${resp.statusCode}'),
                  );
                }
                if (!context.mounted) {
                  return true;
                }
                final result = (resp.data as String).contains('回复发布成功');
                if (!result) {
                  await showMessageSingleButtonDialog(
                    context: context,
                    title: context.t.threadPage.sendReply,
                    message: context.t.threadPage
                        .replyFailed(err: resp.data as String),
                  );
                  return false;
                }
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(context.t.threadPage.replySuccess),
                ));
                return true;
              },
            ),
          ],
        ),
      );
}
