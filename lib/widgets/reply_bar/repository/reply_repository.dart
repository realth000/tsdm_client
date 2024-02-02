import 'dart:io';

import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/models/reply_parameters.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/widgets/reply_bar/exceptions/exceptions.dart';
import 'package:universal_html/parsing.dart';

/// Repository of reply.
class ReplyRepository {
  /// Reply to a post.
  ///
  /// # Exception
  ///
  /// * **HttpRequestFailedException** when http request failed.
  /// * **ReplyToPostFetchParameterFailedException** when failed to fetch
  ///   parameters in reply window.
  /// * **ReplyToPostResultFailedException** when reply finished but no
  ///   successful result found in response.
  Future<void> replyToPost({
    required ReplyParameters replyParameters,
    required String replyAction,
    required String replyMessage,
  }) async {
    final netClient = getIt.get<NetClientProvider>();
    final replyWindowUrl = '$baseUrl/$replyAction/$replyPostWindowSuffix';
    final replyWindowResp = await netClient.get(replyWindowUrl);

    if (replyWindowResp.statusCode != HttpStatus.ok) {
      throw HttpRequestFailedException(replyWindowResp.statusCode!);
    }

    final replyWindowDoc = parseHtmlDocument(replyWindowResp.data as String);
    final formHash = replyWindowDoc
        .querySelector('input[name="formhash"]')
        ?.attributes['value'];
    final handleKey = replyWindowDoc
        .querySelector('input[name="handlekey"]')
        ?.attributes['value'];
    final noticeAuthor = replyWindowDoc
        .querySelector('input[name="noticeauthor"]')
        ?.attributes['value'];
    final noticeTrimStr = replyWindowDoc
        .querySelector('input[name="noticetrimstr"]')
        ?.attributes['value'];
    final noticeAuthorMsg = replyWindowDoc
        .querySelector('input[name="noticeauthormsg"]')
        ?.attributes['value'];
    final replyUid = replyWindowDoc
        .querySelector('input[name="replyuid"]')
        ?.attributes['value'];
    final repPid = replyWindowDoc
        .querySelector('input[name="reppid"]')
        ?.attributes['value'];
    final repPost = replyWindowDoc
        .querySelector('input[name="reppost"]')
        ?.attributes['value'];
    if (formHash == null ||
        handleKey == null ||
        noticeAuthor == null ||
        noticeTrimStr == null ||
        noticeAuthorMsg == null ||
        replyUid == null ||
        repPid == null ||
        repPost == null) {
      debug(
        'failed to fetch reply to post parameters: formHash=$formHash, '
        'handleKey=$handleKey, noticeAuthor=$noticeAuthor',
      );
      debug(
        'failed to fetch reply to post parameters: '
        'noticeAuthorMsg=$noticeAuthorMsg, replyuid=$replyUid, '
        'reppid=$repPid, reppost=$repPost',
      );
      throw ReplyToPostFetchParameterFailedException();
    }

    final formData = <String, String>{
      'formhash': formHash,
      'handlekey': handleKey,
      'noticeauthor': noticeAuthor,
      'noticetrimstr': noticeTrimStr,
      'noticeauthormsg': noticeAuthorMsg,
      'replyuid': replyUid,
      'reppid': repPid,
      'reppost': repPost,
      // TODO: Build subject instead of const empty string.
      'subject': '',
      // TODO: Support reply with rich text.
      'message': replyMessage,
    };

    final resp = await netClient.postForm(
      formatReplyPostUrl(replyParameters.fid, replyParameters.tid),
      data: formData,
    );

    if (!(resp.data as String).contains('回复发布成功')) {
      debug('failed to reply to post: resp data not succeed: ${resp.data}');
      throw ReplyToPostResultFailedException();
    }
  }

  /// Post reply to thread tid/fid.
  /// This will add a post in thread, as reply to that thread.
  ///
  /// # Exception
  ///
  /// * **HttpRequestFailedException** when http request failed.
  /// * **ReplyToThreadResultFailedException** when reply finished but no
  /// successful result found in response.
  Future<void> replyToThread({
    required ReplyParameters replyParameters,
    required String replyMessage,
  }) async {
    final formData = <String, dynamic>{
      'message': replyMessage,
      'usesig': 1,
      'posttime': replyParameters.postTime,
      'formhash': replyParameters.formHash,
      'subject': replyParameters.subject,
    };
    final resp = await getIt.get<NetClientProvider>().postForm(
          formatReplyThreadUrl(replyParameters.fid, replyParameters.tid),
          data: formData,
        );

    if (resp.statusCode != HttpStatus.ok) {
      throw HttpRequestFailedException(resp.statusCode!);
    }
    if (!(resp.data as String).contains('回复发布成功')) {
      throw ReplyToThreadResultFailedException();
    }
  }
}
