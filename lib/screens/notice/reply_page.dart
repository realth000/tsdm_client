import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/models/post.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/utils/show_toast.dart';
import 'package:tsdm_client/widgets/post_card.dart';
import 'package:tsdm_client/widgets/reply_bar.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

class ReplyPage extends ConsumerStatefulWidget {
  const ReplyPage({required this.url, super.key});

  final String url;

  @override
  ConsumerState<ReplyPage> createState() => _ReplyPageState();
}

class _ReplyPageState extends ConsumerState<ReplyPage> {
  final _replyBarController = ReplyBarController();

  // FIXME: Fix FormatException "null data" in redirect request.
  Future<Response<dynamic>> _fetchData(BuildContext context) async {
    var retryCount = 0;
    while (true) {
      // Allow Redirect to thread page url.
      //
      // NOTE: Here when running get request, "Accept-Encoding" shall not use
      // format "gzip" otherwise dart-io will throw exception: FormatException:
      // null data.
      final resp = await ref.read(netClientProvider()).get(widget.url);
      if (resp.statusCode == HttpStatus.ok) {
        return resp;
      }
      if (!context.mounted) {
        return emptyResponse;
      }
      if (retryCount >= 3) {
        debug('reached maximum retry limit');
        return emptyResponse;
      }
      await showRetryToast(context);
      retryCount += 1;
    }
  }

  Widget _buildBody(BuildContext context, uh.Document document) {
    final re = RegExp(r'pid=(?<pid>\d+)');
    final match = re.firstMatch(widget.url);
    final pid = match?.namedGroup('pid');
    if (pid == null) {
      debug('pid not found in url: ${widget.url}');
      return Container();
    }

    final postNode = document.querySelector('div#post_$pid');
    if (postNode == null) {
      debug('failed to build reply page: post node not found for pid $pid');
      return Container();
    }

    final postData = Post.fromPostNode(postNode);

    // Reply to notice.
    return Column(
      children: [
        SingleChildScrollView(
          child: PostCard(postData),
        ),
        ReplyBar(
          controller: _replyBarController,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.noticePage.replyPage.title),
      ),
      body: FutureBuilder(
        future: _fetchData(context),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('${snapshot.error}'),
            );
          }
          if (snapshot.hasData) {
            final data = snapshot.data!;
            final document = parseHtmlDocument(data.data as String);
            return _buildBody(context, document);
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
