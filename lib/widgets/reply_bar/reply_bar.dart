import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bbcode_editor/flutter_bbcode_editor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/features/chat/models/models.dart';
import 'package:tsdm_client/features/editor/widgets/toolbar.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/image_cache_provider/image_cache_provider.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/utils/show_dialog.dart';
import 'package:tsdm_client/widgets/annimate/animated_visibility.dart';
import 'package:tsdm_client/widgets/cached_image/cached_image_provider.dart';
import 'package:tsdm_client/widgets/reply_bar/bloc/reply_bloc.dart';
import 'package:tsdm_client/widgets/reply_bar/models/reply_types.dart';

/// Widget provides the reply feature.
class ReplyBar extends StatefulWidget {
  /// Constructor.
  const ReplyBar({
    required this.controller,
    required this.replyType,
    this.chatHistorySendTarget,
    this.chatSendTarget,
    this.disableEditorFeatures = const [],
    super.key,
  });

  /// Controller passed from outside.
  final ReplyBarController controller;

  /// Usage type of [ReplyBar].
  ///
  /// Different usages have different state and logic.
  final ReplyTypes replyType;

  /// Send target url and parameters when in chat history.
  final ChatHistorySendTarget? chatHistorySendTarget;

  /// Send url parameters when in chat page.
  final ChatSendTarget? chatSendTarget;

  /// Disable all bbcode editor features exists in this list.
  ///
  /// Those disabled features' corresponding widget will be invisible.
  final List<EditorFeatures> disableEditorFeatures;

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

  /// Parameters to reply to thread or post.
  ReplyParameters? _replyParameters;

  /// Url in "action" attribute when post reply.
  ///
  /// * In [ReplyTypes.thread], is the url to get the reply page, not the
  ///   target to post a reply.
  /// * In [ReplyTypes.chatHistory], is the url to post a reply.
  String? _replyAction;

  /////////// Editor Feature ///////////

  /// Enable using testing bbcode editor.
  bool useExperimentalEditor = false;

  /// After switch editor mode, if we have the following condition before
  /// switching:
  ///
  /// * Editor has focus.
  /// * Editor cursor at the end of text.
  ///
  /// Should keep focus and cursor at the end of text.
  bool hasCursorAtEnd = false;

  /// Rich editor focus node.
  final focusNode = FocusNode();

  /// Show text attribute control button or not.
  bool showTextAttributeButtons = false;

  /// Rich editor controller.
  final _replyRichController = BBCodeEditorController()..editorVisible = false;

  /// Method to update [_hintText].
  /// Use this method to update text and ui by calling [setState].
  void _setHintText(String hintText) {
    setState(() {
      _hintText = hintText;
    });
  }

  void _onRichEditorSelectionChanged() {
    setState(() {
      canSendReply = _replyRichController.isNotEmpty;
    });
    _updateCursorPos();
  }

  /// Post reply to thread tid/fid.
  /// This will add a post in thread, as reply to that thread.
  Future<void> _sendReplyThreadMessage() async {
    if (_replyParameters == null) {
      return;
    }
    if (useExperimentalEditor) {
      if (_replyRichController.isEmpty) {
        debug('refuse to send post to thread: empty rich text message');
        return;
      }
    } else {
      if (_replyController.text.isEmpty) {
        debug('refuse to send post to thread: empty text');
        return;
      }
    }

    final String data;
    if (useExperimentalEditor) {
      data = _replyRichController.data ?? '<null>';
    } else {
      data = _replyController.text;
    }

    context.read<ReplyBloc>().add(
          ReplyToThreadRequested(
            replyParameters: _replyParameters!,
            replyMessage: data,
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

    final String data;
    if (useExperimentalEditor) {
      if (_replyRichController.isEmpty) {
        debug('failed to reply to post: reply message is empty');
        return;
      }
      data = _replyRichController.data ?? '<null>';
    } else {
      if (_replyController.text.isEmpty) {
        debug('failed to reply to post: reply message is empty');
        return;
      }
      data = _replyController.text;
    }

    context.read<ReplyBloc>().add(
          ReplyToPostRequested(
            replyParameters: _replyParameters!,
            replyAction: _replyAction!,
            replyMessage: data,
          ),
        );
  }

  /// Send message in chat history reply type.
  Future<void> _sendChatHistoryMessage() async {
    if (widget.chatHistorySendTarget == null) {
      debug('failed to reply in chat history type: send target is null');
      return;
    }

    final String data;
    if (useExperimentalEditor) {
      if (_replyRichController.isEmpty) {
        debug('failed to reply chat history: reply message is empty');
        return;
      }
      data = _replyRichController.data ?? '<null>';
    } else {
      if (_replyController.text.isEmpty) {
        debug('failed to reply chat history: reply message is empty');
        return;
      }
      data = _replyController.text;
    }

    context.read<ReplyBloc>().add(
          ReplyChatHistoryRequested(
            targetUrl: widget.chatHistorySendTarget!.targetUrl,
            formHash: widget.chatHistorySendTarget!.formHash,
            message: data,
          ),
        );
  }

  Future<void> _sendChatMessage() async {
    if (widget.chatSendTarget == null) {
      debug('failed to reply in chat: send target is null');
      return;
    }

    final String data;
    if (useExperimentalEditor) {
      if (_replyRichController.isEmpty) {
        debug('failed to reply chat: reply message is empty');
        return;
      }
      data = _replyRichController.data ?? '<null>';
    } else {
      if (_replyController.text.isEmpty) {
        debug('failed to reply chat: reply message is empty');
        return;
      }
      data = _replyController.text;
    }

    context.read<ReplyBloc>().add(
          ReplyChatRequested(widget.chatSendTarget!.touid, {
            'pmsubmit': widget.chatSendTarget!.pmsubmit,
            'touid': widget.chatSendTarget!.touid,
            'formhash': widget.chatSendTarget!.formHash,
            'handlekey': widget.chatSendTarget!.handleKey,
            'message': data,
            'messageappand': widget.chatSendTarget!.messageAppend,
          }),
        );
  }

  /// Send message, according to [ReplyTypes].
  Future<void> _sendMessage() async {
    switch (widget.replyType) {
      case ReplyTypes.thread:
        {
          if (_replyAction == null && _replyParameters == null) {
            debug(
              'failed to send reply: null action and '
              'parameters',
            );
            return;
          }
          _replyAction == null
              ? await _sendReplyThreadMessage()
              : await _sendReplyPostMessage();
        }
      case ReplyTypes.chatHistory:
        {
          await _sendChatHistoryMessage();
        }
      case ReplyTypes.chat:
        {
          await _sendChatMessage();
        }
    }
  }

  /// Update [hasCursorAtEnd] when editor content changes.
  ///
  /// Now the plain text does not have a callback when cursor moved, only have
  /// one when tapped or text changed.
  void _updateCursorPos() {
    if (useExperimentalEditor) {
      hasCursorAtEnd = _replyRichController.selectionEndPosition?.offset ==
          _replyRichController.documentEndPosition?.offset;
    } else {
      hasCursorAtEnd = _replyController.value.selection.baseOffset ==
          _replyController.text.length;
    }
  }

  /// Build an editor with bbcode support.
  Widget _buildRichEditor(BuildContext context) {
    return InputDecorator(
      isFocused: focusNode.hasFocus,
      decoration: const InputDecoration(),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 100,
        ),
        child: Column(
          children: [
            Expanded(
              child: BBCodeEditor(
                controller: _replyRichController,
                // This empty scroll controller prevents the text field as the
                // "primary" scrollable widget in page, so that app bar color
                // will not change when this text fields scrolls.
                // Only a workaround but it works.
                // TODO: Make this prevent elegant.
                scrollController: ScrollController(),
                focusNode: focusNode,
                emojiBuilder: (code) async {
                  // code is supposed in
                  // {:${group_id}_${emoji_id}:}
                  // format.
                  final emojiCache = await getIt
                      .get<ImageCacheProvider>()
                      .getEmojiCacheFromRawCode(code);
                  return emojiCache;
                },
                imageBuilder: (String url) => CachedImageProvider(url, context),
                urlLauncher: (url) async => context.dispatchAsUrl(url),
                // TODO: Check if need url encoding.
                // Seems unnecessary.
                mentionUserLauncher: (username) => context.dispatchAsUrl(
                  '$usernameProfilePage$username',
                ),
                autoFocus: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a plain text editor.
  Widget _buildPlainEditor(BuildContext context) {
    return TextField(
      // This empty scroll controller prevents the text field as the "primary"
      // scrollable widget in page, so that app bar color will not change when
      // this text fields scrolls.
      // Only a workaround but it works.
      // TODO: Make this prevent elegant.
      scrollController: ScrollController(),
      focusNode: _replyFocusNode,
      controller: _replyController,
      onTap: _updateCursorPos,
      onChanged: (value) {
        setState(() {
          canSendReply = value.isNotEmpty;
        });
        _updateCursorPos();
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
    );
  }

  Widget _buildContent(BuildContext context, ReplyState state) {
    void Function()? switchEditorCallback;
    if (!_closed && _hasLogin) {
      switchEditorCallback = () {
        setState(() {
          useExperimentalEditor = !useExperimentalEditor;
          _replyRichController.editorVisible = useExperimentalEditor;
          if (useExperimentalEditor) {
            // Reserve the current value because it may change when we check
            // after the delayed future (see bellow).
            final reservedHasCursorAtEnd = hasCursorAtEnd;
            // Sync normal editor data to rich editor.
            _replyRichController.data = _replyController.text;
            canSendReply = _replyRichController.isNotEmpty;

            // TODO: Use without delayed future.
            //
            // Keep if we have cursor at end.
            //
            // Note that here we want to move the cursor to the end of document,
            // but when getting cursor position, an initialized renderer inside
            // AppFlowy editor is required.
            // addPostFrameCallback does not work here, maybe because in that
            // moment the initial text content is not ready in editor, but what
            // we want is move cursor to the end of initial text.
            //
            // As a workaround, add some delay before moving cursor position.
            // Not a good solution but works.
            Future.delayed(const Duration(milliseconds: 300), () {
              // Use the reserved `hasCursorAtEnd` value.
              if (reservedHasCursorAtEnd &&
                  _replyRichController.documentEndPosition != null) {
                _replyRichController.cursorPosition =
                    _replyRichController.documentEndPosition!;
                hasCursorAtEnd = true;
              }
            });
          } else if (_replyRichController.data != null) {
            _replyController.text = _replyRichController.data!;
            canSendReply = _replyController.text.isNotEmpty;

            // Keep if we have cursor at end
            if (hasCursorAtEnd) {
              _replyFocusNode.requestFocus();
              _replyController.selection = TextSelection.fromPosition(
                TextPosition(offset: _replyController.text.length),
              );
            }
          }
        });
      };
    }

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
                      child: useExperimentalEditor
                          ? _buildRichEditor(context)
                          : _buildPlainEditor(context),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Rich editor toolbar
          Padding(
            padding: edgeInsetsL10R10B10,
            child: Row(
              children: [
                Expanded(
                  child: EditorToolbar(
                    bbcodeController: _replyRichController,
                    disabledFeatures: widget.disableEditorFeatures,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: edgeInsetsL10R10B10,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.science_outlined),
                  isSelected: useExperimentalEditor,
                  onPressed: switchEditorCallback,
                ),
                AnimatedVisibility(
                  visible: useExperimentalEditor,
                  child: IconButton(
                    icon: Icon(
                      Icons.info_outline,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () async {
                      await showMessageSingleButtonDialog(
                        context: context,
                        title: context.t.bbcodeEditor.experimentalInfoTitle,
                        message: context.t.bbcodeEditor.experimentalInfoDetail,
                      );
                    },
                  ),
                ),
                const Spacer(),
                // Send Button
                FilledButton(
                  onPressed:
                      (canSendReply && !isSendingReply && !_closed && _hasLogin)
                          ? () async => _sendMessage()
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
    // Set callback to update text empty or not state.
    _replyRichController.onSelectionChanged = _onRichEditorSelectionChanged;
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
          _replyRichController.clear();
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
            // When failed to reply, we did NOT clear any text so is ready for
            // next try.
            canSendReply = true;
          }

          // Should update close state of the current reply bar because we may
          // not send reply to closed threads.
          _closed = switch (widget.replyType) {
            ReplyTypes.thread => state.closed,
            ReplyTypes.chatHistory || ReplyTypes.chat => false,
          };
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
