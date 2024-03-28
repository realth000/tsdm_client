import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/widgets/reply_bar/bloc/reply_bloc.dart';

/// Widget provides the reply feature.
class ReplyBar extends StatefulWidget {
  /// Constructor.
  const ReplyBar({required this.controller, super.key});

  /// Controller passed from outside.
  final ReplyBarController controller;

  @override
  State<ReplyBar> createState() => _ReplyBarState();
}

class _ReplyBarState extends State<ReplyBar> {
  /// Indicate current thread is closed.
  bool _closed = false;

  late final StreamSubscription<AuthenticationStatus> _authStatusSub;

  /// Indicate whether have current login user.
  ///
  /// Should disable when no user login.
  bool _hasLogin = false;

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

  // /// Check reply request result in response [resp].
  // /// Return true if success.
  // Future<bool> _checkReplyResult(Response<dynamic> resp) async {
  //   if (resp.statusCode != HttpStatus.ok) {
  //     if (!context.mounted) {
  //       return false;
  //     }
  //     await showMessageSingleButtonDialog(
  //       context: context,
  //       title: context.t.threadPage.sendReply,
  //       message: context.t.threadPage.replyFailed(err: '${resp.statusCode}'),
  //     );
  //   }
  //   if (!context.mounted) {
  //     _hintText = null;
  //     return true;
  //   }
  //   final result = (resp.data as String).contains('回复发布成功');
  //   if (!result) {
  //     await showMessageSingleButtonDialog(
  //       context: context,
  //       title: context.t.threadPage.sendReply,
  //       message: context.t.threadPage.replyFailed(err: resp.data as String),
  //     );
  //     return false;
  //   }
  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //     content: Text(context.t.threadPage.replySuccess),
  //   ),);
  //   setState(() {
  //     _hintText = null;
  //   });
  //   return true;
  // }

  /// Post reply to thread tid/fid.
  /// This will add a post in thread, as reply to that thread.
  Future<void> _sendReplyThreadMessage() async {
    if (_replyParameters == null || _replyController.text.isEmpty) {
      return;
    }

    context.read<ReplyBloc>().add(
          ReplyToThreadRequested(
            replyParameters: _replyParameters!,
            replyMessage: _replyController.text,
          ),
        );
  }

  /// Post reply to another post in thread tid/fid.
  /// This will add a post in that thread, as a reply to another post.
  Future<void> _sendReplyPostMessage() async {
    if (_replyParameters == null || _replyAction == null) {
      debug('failed to reply to post: reply action not set');
      return;
    }

    if (_replyController.text.isEmpty) {
      debug('failed to reply to post: reply message is empty');
      return;
    }

    context.read<ReplyBloc>().add(
          ReplyToPostRequested(
            replyParameters: _replyParameters!,
            replyAction: _replyAction!,
            replyMessage: _replyController.text,
          ),
        );
  }

  Widget _buildContent(BuildContext context, ReplyState state) {
    return SafeArea(
      top: isExpanded,
      child: Column(
        mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (_hintText != null && !_closed && _hasLogin)
            Padding(
              padding: edgeInsetsL20R20,
              child: Row(
                children: [
                  Text(
                    _hintText!,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Expanded(child: Container()),
                  IconButton(
                    icon: const Icon(Icons.clear_outlined),
                    onPressed: () {
                      setState(() {
                        _hintText = null;
                        _replyAction = null;
                      });
                    },
                  ),
                ],
              ),
            ),
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
                        enabled: !_closed && _hasLogin,
                        maxLines: isExpanded ? null : 10,
                        minLines: isExpanded ? null : 1,
                        decoration: InputDecoration(
                          hintText: _closed
                              ? context.t.threadPage.closed
                              : _hasLogin
                                  ? context.t.threadPage.sendReplyHint
                                  : context.t.threadPage.needLogin,
                        ),
                      ),
                    ),
                  ),
                  // if (false)
                  //   Padding(
                  //     padding: edgeInsetsT10,
                  //     child: IconButton(
                  //       icon: Icon(
                  //         isExpanded
                  //             ? Icons.close_fullscreen_outlined
                  //             : Icons.open_in_full_outlined,
                  //       ),
                  //       onPressed: () {
                  //         setState(() {
                  //           isExpanded = !isExpanded;
                  //           // Reset focus to the text field.
                  //           _replyFocusNode.requestFocus();
                  //         });
                  //       },
                  //     ),
                  //   ),
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
                  onPressed:
                      (canSendReply && !isSendingReply && !_closed && _hasLogin)
                          ? () async {
                              if (_replyAction == null &&
                                  _replyParameters == null) {
                                debug(
                                  'failed to send reply: null action and '
                                  'parameters',
                                );
                                return;
                              }
                              debug(
                                'ReplyBar: send reply $_replyAction, '
                                '$_replyParameters',
                              );
                              _replyAction == null
                                  ? await _sendReplyThreadMessage()
                                  : await _sendReplyPostMessage();
                            }
                          : null,
                  child: isSendingReply
                      ? sizedCircularProgressIndicator
                      : const Icon(Icons.send_outlined),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    widget.controller._bind = this;
    final authRepo = context.read<AuthenticationRepository>();
    _hasLogin = authRepo.currentUser != null;
    _authStatusSub = authRepo.status.listen(
      (status) {
        setState(() {
          status == AuthenticationStatus.authenticated
              ? _hasLogin = true
              : _hasLogin = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _replyFocusNode.dispose();
    _replyController.dispose();
    _authStatusSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReplyBloc, ReplyState>(
      listener: (context, state) {
        // Clear text one time when user send request succeed.
        if (state.status == ReplyStatus.success && state.needClearText) {
          _replyController.clear();
          // Reset flag because we only want to clear the sent text.
          context.read<ReplyBloc>().add(ReplyResetClearTextStateTriggered());
        }
      },
      child: BlocBuilder<ReplyBloc, ReplyState>(
        builder: (context, state) {
          if (state.status == ReplyStatus.loading) {
            // Now is pending reply actions.
            isSendingReply = true;
            canSendReply = false;
          } else if (state.status == ReplyStatus.success) {
            // Last reply is succeed, clear reply message.
            isSendingReply = false;
          } else if (state.status == ReplyStatus.failed) {
            // Last reply action is failed, only clear pending state.
            isSendingReply = false;
          }

          // Should update close state of the current reply bar because we may
          // not send reply to closed threads.
          _closed = state.closed;
          _replyParameters = state.replyParameters;

          return _buildContent(context, state);
        },
      ),
    );
  }
}

/// Controller of [ReplyBar].
///
/// Used to fill parameters and update state.
class ReplyBarController {
  _ReplyBarState? _state;

  /// Temporary value that saves before [_state] bind.
  /// Because sometimes we bind these values before bind a state.
  /// Defer sync values in [_state] till we have a state by called [_bind].
  String? _replyAction;
  bool? _closed;

  // ignore: avoid_setters_without_getters
  set _bind(_ReplyBarState state) {
    _state = state;
    if (_replyAction != null) {
      _state!._replyAction = _replyAction;
      debug('update reply action');
    }
    if (_closed != null) {
      _state!._closed = _closed!;
    }
  }

  /// Set reply action url to current state. Call this when user try to reply
  /// to another post, before user writes the reply or sends it.
  ///
  // ignore: avoid_setters_without_getters
  set replyAction(String? replyAction) {
    if (_state == null) {
      _replyAction = replyAction;
      return;
    }
    _state!._replyAction = replyAction;
    debug('update reply parameters');
  }

  /// Thread closed or not.
  bool get closed => _state?._closed ?? _closed ?? false;

  set closed(bool closed) {
    if (_state == null) {
      _closed = closed;
      return;
    }
    _state!._closed = closed;
  }

  /// Set the hint text.
  void setHintText(String hintText) {
    _state?._setHintText(hintText);
  }

  /// Let the [ReplyBar] get the focus.
  void requestFocus() {
    if (_closed ?? false) {
      _state?._replyFocusNode.requestFocus();
    }
  }
}
