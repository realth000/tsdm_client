import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/models/reply_parameters.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/utils/show_dialog.dart';
import 'package:universal_html/parsing.dart';

class ReplyBar extends ConsumerStatefulWidget {
  const ReplyBar({required this.controller, super.key});

  final ReplyBarController controller;

  @override
  ConsumerState<ReplyBar> createState() => _ReplyBarState();
}

class _ReplyBarState extends ConsumerState<ReplyBar> {
  bool isExpanded = false;
  bool canSendReply = false;

  /// Hint text in text field.
  /// When reply to thread, use default hint.
  /// When reply to another post, show that post's info.
  String? _hintText;

  /// Indicate whether sending reply.
  bool isSendingReply = false;
  final _replyFocusNode = FocusNode();
  final _replyController = TextEditingController();

  /// Parameters to reply to thread.
  ReplyParameters? _replyParameters;

  /// Url to get the reply page, not the target to post a reply.
  String? _replyAction;

  /// Method to update [_hintText].
  /// Use this method to update text and ui by calling [setState].
  void _setHintText(String hintText) {
    setState(() {
      _hintText = hintText;
    });
  }

  /// Check reply request result in response [resp].
  /// Return true if success.
  Future<bool> _checkReplyResult(Response<dynamic> resp) async {
    if (resp.statusCode != HttpStatus.ok) {
      if (!context.mounted) {
        return false;
      }
      await showMessageSingleButtonDialog(
        context: context,
        title: context.t.threadPage.sendReply,
        message: context.t.threadPage.replyFailed(err: '${resp.statusCode}'),
      );
    }
    if (!context.mounted) {
      _hintText = null;
      return true;
    }
    final result = (resp.data as String).contains('回复发布成功');
    if (!result) {
      await showMessageSingleButtonDialog(
        context: context,
        title: context.t.threadPage.sendReply,
        message: context.t.threadPage.replyFailed(err: resp.data as String),
      );
      return false;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(context.t.threadPage.replySuccess),
    ));
    setState(() {
      _hintText = null;
    });
    return true;
  }

  /// Post reply to thread tid/fid.
  /// This will add a post in thread, as reply to that thread.
  Future<bool> _sendReplyThreadMessage() async {
    if (_replyParameters == null) {
      return false;
    }
    final formData = {
      'message': _replyController.text,
      'usesig': 1,
      'posttime': _replyParameters!.postTime,
      'formhash': _replyParameters!.formHash,
      'subject': _replyParameters!.subject,
    };

    final resp = await ref.read(netClientProvider()).post(
          formatReplyThreadUrl(_replyParameters!.fid, _replyParameters!.tid),
          data: formData,
          options: Options(
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          ),
        );

    return _checkReplyResult(resp);
  }

  /// Post reply to another post in thread tid/fid.
  /// This will add a post in that thread, as a reply to another post.
  Future<bool> _sendReplyPostMessage() async {
    if (_replyAction == null) {
      debug('failed to reply to post: reply action not set');
      return false;
    }

    if (_replyController.text.isEmpty) {
      debug('failed to reply to post: reply message is empty');
      return false;
    }

    /// First fetch the reply window.
    final replyWindowUrl = '$baseUrl/${_replyAction!}/$replyPostWindowSuffix';
    final replyWindowResp =
        await ref.read(netClientProvider()).get(replyWindowUrl);
    if (replyWindowResp.statusCode != HttpStatus.ok) {
      debug(
          'failed to reply to post: error getting fast reply window: ${replyWindowResp.statusCode}');
      return false;
    }

    final replyWindowDoc = parseHtmlDocument(replyWindowResp.data as String);
    final inputList = replyWindowDoc.querySelectorAll('input');

    String? formHash;
    String? handleKey;
    String? noticeAuthor;
    String? noticeTrimStr;
    String? noticeAuthorMsg;
    String? replyUid;
    String? repPid;
    String? repPost;

    for (final d in inputList) {
      final name = d.attributes['name'];
      final value = d.attributes['value'];
      if (name == null || value == null) {
        continue;
      }
      switch (name) {
        case 'formhash':
          formHash = value;
        case 'handlekey':
          handleKey = value;
        case 'noticeauthor':
          noticeAuthor = value;
        case 'noticetrimstr':
          noticeTrimStr = value;
        case 'noticeauthormsg':
          noticeAuthorMsg = value;
        case 'replyuid':
          replyUid = value;
        case 'reppid':
          repPid = value;
        case 'reppost':
          repPost = value;
      }
    }

    if (formHash == null ||
        handleKey == null ||
        noticeAuthor == null ||
        noticeTrimStr == null ||
        noticeAuthorMsg == null ||
        replyUid == null ||
        repPid == null ||
        repPost == null) {
      debug(
          'failed to post message: $formHash, $handleKey, $noticeAuthor, $noticeTrimStr, $noticeAuthorMsg, $replyUid, $repPid, $repPost');
      return false;
    }

    /// Parse parameters used in post request.

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
      'message': _replyController.text,
    };

    final resp = await ref.read(netClientProvider()).post(
          formatReplyPostUrl(_replyParameters!.fid, _replyParameters!.tid),
          data: formData,
          options: Options(
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          ),
        );

    return _checkReplyResult(resp);
  }

  @override
  void initState() {
    super.initState();
    widget.controller._bind = this;
  }

  @override
  void dispose() {
    _replyFocusNode.dispose();
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Flexible(
            fit: isExpanded ? FlexFit.tight : FlexFit.loose,
            child: Padding(
              padding: edgeInsetsL10R10B10,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: edgeInsetsL10T5R5B5,
                      child: TextField(
                        controller: _replyController,
                        onChanged: (value) {
                          setState(() {
                            canSendReply = value.isNotEmpty;
                          });
                        },
                        focusNode: _replyFocusNode,
                        maxLines: isExpanded ? null : 10,
                        minLines: isExpanded ? null : 1,
                        decoration: InputDecoration(
                          hintText:
                              _hintText ?? context.t.threadPage.sendReplyHint,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: edgeInsetsT10,
                    child: IconButton(
                      icon: Icon(
                        isExpanded
                            ? Icons.close_fullscreen_outlined
                            : Icons.open_in_full_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          isExpanded = !isExpanded;
                          // Reset focus to the text field.
                          _replyFocusNode.requestFocus();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Send Button
          Padding(
            padding: edgeInsetsL10R10B10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  child: isSendingReply
                      ? sizedCircularProgressIndicator
                      : const Icon(Icons.send_outlined),
                  onPressed: canSendReply && !isSendingReply
                      ? () async {
                          setState(() {
                            isSendingReply = true;
                          });
                          final sendSuccess = _replyAction == null
                              ? await _sendReplyThreadMessage()
                              : await _sendReplyPostMessage();
                          setState(() {
                            isSendingReply = false;
                          });
                          if (sendSuccess) {
                            _replyController.clear();
                          }
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReplyBarController {
  _ReplyBarState? _state;

  // ignore: avoid_setters_without_getters
  set _bind(_ReplyBarState state) => _state = state;

  /// Set reply parameters to current state.
  /// These are parameters used in reply to a thread, not a post.
  ///
  // ignore: avoid_setters_without_getters
  set replyParameters(ReplyParameters replyParameters) =>
      _state?._replyParameters = replyParameters;

  /// Set reply action url to current state. Call this when user try to reply
  /// to another post, before user writes the reply or sends it.
  ///
  // ignore: avoid_setters_without_getters
  set replyAction(String? replyAction) => _state?._replyAction = replyAction;

  void setHintText(String hintText) {
    _state?._setHintText(hintText);
  }

  void requestFocus() => _state?._replyFocusNode.requestFocus();
}
