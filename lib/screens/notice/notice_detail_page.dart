import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/models/notice.dart';
import 'package:tsdm_client/models/post.dart';
import 'package:tsdm_client/models/reply_parameters.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/utils/show_toast.dart';
import 'package:tsdm_client/widgets/post_card.dart';
import 'package:tsdm_client/widgets/reply_bar.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

/// Show details for a single notice, also provides interaction:
/// * Reply to the notice if notice type is [NoticeType.reply] or [NoticeType.mention].
class NoticeDetailPage extends ConsumerStatefulWidget {
  const NoticeDetailPage({
    required this.url,
    required this.noticeType,
    super.key,
  });

  final NoticeType noticeType;
  final String url;

  @override
  ConsumerState<NoticeDetailPage> createState() => _NoticeDetailPage();
}

class _NoticeDetailPage extends ConsumerState<NoticeDetailPage> {
  final _replyBarController = ReplyBarController();

  ReplyParameters? _parseParameters(uh.Document document, String tid) {
    final inputNodeList = document.querySelectorAll('input');
    if (inputNodeList.isEmpty) {
      debug('failed to get reply form hash: input not found');
      return null;
    }

    String? fid;
    String? postTime;
    String? formHash;
    String? subject;
    for (final node in inputNodeList) {
      if (!node.attributes.containsKey('name')) {
        continue;
      }
      final name = node.attributes['name'];
      final value = node.attributes['value'];
      switch (name) {
        case 'srhfid':
          fid = value;
        case 'posttime':
          postTime = value;
        case 'formhash':
          formHash = value;
        case 'subject':
          subject = value;
      }
    }

    if (fid == null ||
        postTime == null ||
        formHash == null ||
        subject == null) {
      debug(
          'failed to get reply form hash: fid=$fid postTime=$postTime formHash=$formHash subject=$subject');
      return null;
    }
    return ReplyParameters(
      fid: fid,
      tid: tid,
      postTime: postTime,
      formHash: formHash,
      subject: subject,
    );
  }

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
      return Center(
          child: Text(context.t.noticePage.noticeDetailPage.postNotFound));
    }
    final postData = Post.fromPostNode(postNode);

    // Only show post date (hide reply bar) if notice is rate type.
    if (widget.noticeType == NoticeType.rate) {
      return SingleChildScrollView(
        child: PostCard(postData),
      );
    }

    // Parse thread id.
    final tidRe = RegExp(r'ptid=(?<ptid>\d+)');
    final tidMatch = tidRe.firstMatch(widget.url);
    final tid = tidMatch?.namedGroup('ptid');
    ReplyParameters? parameters;
    if (tid != null) {
      parameters = _parseParameters(document, tid);
      if (parameters != null) {
        _replyBarController
          ..replyParameters = parameters
          ..replyAction = postData.replyAction;
        debug('update reply action and parameters');
      } else {
        debug('parameters not found');
      }
    } else {
      debug('ptid not found');
    }

    // Reply to notice.
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: PostCard(postData),
          ),
        ),
        if (parameters != null)
          ReplyBar(
            controller: _replyBarController,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (widget.noticeType) {
      NoticeType.reply => context.t.noticePage.noticeDetailPage.titleReply,
      NoticeType.rate => context.t.noticePage.noticeDetailPage.titleRate,
      NoticeType.mention => context.t.noticePage.noticeDetailPage.titleMention,
    };
    return Scaffold(
      appBar: AppBar(title: Text(title)),
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
