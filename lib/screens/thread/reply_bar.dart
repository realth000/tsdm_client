import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';

class ReplyBar extends ConsumerStatefulWidget {
  const ReplyBar({required this.sendCallBack, super.key});

  final FutureOr<bool> Function(String message) sendCallBack;

  @override
  ConsumerState<ReplyBar> createState() => _ReplyBarState();
}

class _ReplyBarState extends ConsumerState<ReplyBar> {
  bool isExpanded = false;
  bool canSendReply = false;

  /// Indicate whether sending reply.
  bool isSendingReply = false;
  final _replyFocusNode = FocusNode();
  final _replyController = TextEditingController();

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
              padding: const EdgeInsets.only(left: 10, bottom: 10, right: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
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
                          hintText: context.t.threadPage.sendReplyHint,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
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
            padding: const EdgeInsets.only(
              left: 10,
              bottom: 10,
              right: 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  child: isSendingReply
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        )
                      : const Icon(Icons.send_outlined),
                  onPressed: canSendReply && !isSendingReply
                      ? () async {
                          setState(() {
                            isSendingReply = true;
                          });
                          final sendSuccess =
                              await widget.sendCallBack(_replyController.text);
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
