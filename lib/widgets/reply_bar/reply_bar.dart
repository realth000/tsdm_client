import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bbcode_editor/flutter_bbcode_editor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/features/chat/models/models.dart';
import 'package:tsdm_client/features/editor/widgets/rich_editor.dart';
import 'package:tsdm_client/features/editor/widgets/toolbar.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/utils/show_dialog.dart';
import 'package:tsdm_client/widgets/reply_bar/bloc/reply_bloc.dart';
import 'package:tsdm_client/widgets/reply_bar/models/reply_types.dart';

/// Widget provide reply functionality.
///
/// Actually is a wrapper for the real reply bar.
/// Wrapped so that a expandable reply bar can be set in page as bottom sheet.
class ReplyBar extends StatefulWidget {
  /// Constructor.
  const ReplyBar({
    required this.controller,
    required this.replyType,
    this.chatHistorySendTarget,
    this.chatSendTarget,
    this.disabledEditorFeatures = const {},
    this.fullScreenDisabledEditorFeatures = const {},
    this.fullScreen = false,
    super.key,
  });

  /// Controller passed from outside.
  final ReplyBarController controller;

  /// Usage type of [_ReplyBar].
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
  final Set<EditorFeatures> disabledEditorFeatures;

  /// Disabled bbcode editor features when reply bar set to full screen.
  ///
  /// Usually is less than [disabledEditorFeatures].
  ///
  /// Those disabled features' corresponding widget will be invisible.
  final Set<EditorFeatures> fullScreenDisabledEditorFeatures;

  /// Constraints max height?
  final bool fullScreen;

  @override
  State<ReplyBar> createState() => _ReplyBarWrapperState();
}

class _ReplyBarWrapperState extends State<ReplyBar> {
  /// Text controller to display head part of entered bbcode.
  final controller = TextEditingController();

  /// Flag indicating currently popping up the editor or not.
  ///
  /// Use this flag to keep only one editor popup.
  ///
  /// So the text in editor is persistent.
  bool _showingEditor = false;

  Future<void> showEditor() async {
    if (_showingEditor) {
      // Now we already have an editor, not now override with another one.
      return;
    }

    // Here we actually want to ensure the editor is shown when user set hint
    // text: which means user want to reply to something.
    //
    // The debounce check above only filters duplicate editor, it's safe.

    final c = showBottomSheet(
      context: context,
      shape: const UnderlineInputBorder(), // Remove border
      builder: (_) => _ReplyBar(
        controller: widget.controller,
        outerTextController: controller,
        replyType: widget.replyType,
        chatHistorySendTarget: widget.chatHistorySendTarget,
        chatSendTarget: widget.chatSendTarget,
        disabledEditorFeatures: widget.disabledEditorFeatures,
        fullScreenDisabledEditorFeatures:
            widget.fullScreenDisabledEditorFeatures,
        fullScreen: widget.fullScreen,
      ),
    );

    _showingEditor = true;
    await c.closed;
    _showingEditor = false;
  }

  @override
  void initState() {
    super.initState();
    widget.controller.onSetHintText = showEditor;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: edgeInsetsL10T10R10B10,
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: showEditor,
      ),
    );
  }
}

/// Widget provides the reply feature.
class _ReplyBar extends StatefulWidget {
  /// Constructor.
  const _ReplyBar({
    required this.controller,
    required this.replyType,
    required this.outerTextController,
    this.chatHistorySendTarget,
    this.chatSendTarget,
    this.disabledEditorFeatures = const {},
    this.fullScreenDisabledEditorFeatures = const {},
    this.fullScreen = false,
  });

  /// Controller passed from outside.
  final ReplyBarController controller;

  /// Text controller in the wrapper widget to show current entered text.
  final TextEditingController outerTextController;

  /// Usage type of [_ReplyBar].
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
  final Set<EditorFeatures> disabledEditorFeatures;

  /// Disabled bbcode editor features when reply bar set to full screen.
  ///
  /// Usually is less than [disabledEditorFeatures].
  ///
  /// Those disabled features' corresponding widget will be invisible.
  final Set<EditorFeatures> fullScreenDisabledEditorFeatures;

  /// Constraints max height?
  final bool fullScreen;

  @override
  State<_ReplyBar> createState() => _ReplyBarState();
}

final class _ReplyBarState extends State<_ReplyBar> with LoggerMixin {
  /// Indicate current thread is closed.
  bool _closed = false;

  /// Allow reply bar full screen.
  ///
  /// Will not restrict reply bar height when set to true.
  late bool fullScreen;

  late final StreamSubscription<AuthenticationStatus> _authStatusSub;

  /// Indicate whether have current login user.
  ///
  /// Should disable when no user login.
  bool _hasLogin = false;

  bool canSendReply = false;

  /// Hint text in text field.
  /// When reply to thread, use default hint.
  /// When reply to another post, show that post's info.
  String? _hintText;

  /// Indicate whether sending reply.
  bool isSendingReply = false;
  final _replyFocusNode = FocusNode();

  /// Parameters to reply to thread or post.
  ReplyParameters? _replyParameters;

  /// Url in "action" attribute when post reply.
  ///
  /// * In [ReplyTypes.thread], is the url to get the reply page, not the
  ///   target to post a reply.
  /// * In [ReplyTypes.chatHistory], is the url to post a reply.
  String? _replyAction;

  /////////// Editor Feature ///////////

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
  final _replyRichController = BBCodeEditorController();

  /// Method to update [_hintText].
  /// Use this method to update text and ui by calling [setState].
  void _setHintText(String hintText) {
    setState(() {
      _hintText = hintText;
    });
    // User set hint text means want to reply to something, then the editor pop
    // up, here should also request focus.
    focusNode.requestFocus();
  }

  void _checkEditorContent() {
    final empty = _replyRichController.isEmpty;
    if (empty && canSendReply) {
      setState(() {
        canSendReply = false;
      });
    } else if (!empty && !canSendReply) {
      setState(() {
        canSendReply = true;
      });
    }
  }

  /// Post reply to thread tid/fid.
  /// This will add a post in thread, as reply to that thread.
  Future<void> _sendReplyThreadMessage() async {
    if (_replyParameters == null) {
      return;
    }
    if (_replyRichController.isEmpty) {
      error('refuse to send post to thread: empty rich text message');
      return;
    }
    context.read<ReplyBloc>().add(
          ReplyToThreadRequested(
            replyParameters: _replyParameters!,
            replyMessage: _replyRichController.toBBCode(),
          ),
        );
  }

  /// Post reply to another post in thread tid/fid.
  /// This will add a post in that thread, as a reply to another post.
  Future<void> _sendReplyPostMessage() async {
    if (_replyParameters == null || _replyAction == null) {
      error('failed to reply to post: reply action not set');
      return;
    }

    if (_replyRichController.isEmpty) {
      error('failed to reply to post: reply message is empty');
      return;
    }

    context.read<ReplyBloc>().add(
          ReplyToPostRequested(
            replyParameters: _replyParameters!,
            replyAction: _replyAction!,
            replyMessage: _replyRichController.toBBCode(), // data,
          ),
        );
  }

  /// Send message in chat history reply type.
  Future<void> _sendChatHistoryMessage() async {
    if (widget.chatHistorySendTarget == null) {
      error('failed to reply in chat history type: send target is null');
      return;
    }

    if (_replyRichController.isEmpty) {
      error('failed to reply chat history: reply message is empty');
      return;
    }

    context.read<ReplyBloc>().add(
          ReplyChatHistoryRequested(
            targetUrl: widget.chatHistorySendTarget!.targetUrl,
            formHash: widget.chatHistorySendTarget!.formHash,
            message: _replyRichController.toBBCode(),
          ),
        );
  }

  Future<void> _sendChatMessage() async {
    if (widget.chatSendTarget == null) {
      error('failed to reply in chat: send target is null');
      return;
    }

    if (_replyRichController.isEmpty) {
      error('failed to reply chat: reply message is empty');
      return;
    }

    context.read<ReplyBloc>().add(
          ReplyChatRequested(widget.chatSendTarget!.touid, {
            'pmsubmit': widget.chatSendTarget!.pmsubmit,
            'touid': widget.chatSendTarget!.touid,
            'formhash': widget.chatSendTarget!.formHash,
            'handlekey': widget.chatSendTarget!.handleKey,
            'message': _replyRichController.toBBCode(),
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
            error(
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

  /// Build an editor with bbcode support.
  Widget _buildRichEditor(BuildContext context) {
    return InputDecorator(
      isFocused: focusNode.hasFocus,
      decoration: const InputDecoration(),
      child: IntrinsicHeight(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: fullScreen ? double.infinity : 100,
          ),
          child: RichEditor(
            // Initial text is the text passed from outside.
            initialText: widget.outerTextController.text,
            controller: _replyRichController,
            focusNode: focusNode,
          ),
        ),
      ),
    );
  }

  Widget _buildHintTextRow(BuildContext context) {
    if (_hintText == null || _closed || !_hasLogin) {
      return const SizedBox.shrink();
    }
    final outlineColor = Theme.of(context).colorScheme.outline;
    return Padding(
      padding: edgeInsetsL10T10R10,
      child: Row(
        children: [
          Text(
            _hintText!,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: outlineColor,
                ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.clear_outlined,
              color: outlineColor,
              size: 16,
            ),
            onPressed: () {
              setState(() {
                _hintText = null;
                _replyAction = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ReplyState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Reply hint row.
        _buildHintTextRow(context),

        // Editor.
        Flexible(
          child: Padding(
            padding: edgeInsetsL10T10R10B10,
            child: _buildRichEditor(context),
          ),
        ),

        // Rich editor toolbar
        Padding(
          padding: edgeInsetsL10R10B10,
          child: Row(
            children: [
              Expanded(
                child: EditorToolbar(
                  bbcodeController: _replyRichController,
                  disabledFeatures: fullScreen
                      ? widget.fullScreenDisabledEditorFeatures
                      : widget.disabledEditorFeatures,
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
              IconButton(
                icon: const Icon(Icons.expand),
                selectedIcon: Icon(
                  Icons.expand_outlined,
                  color: Theme.of(context).primaryColor,
                ),
                isSelected: fullScreen,
                onPressed: () {
                  setState(() {
                    fullScreen = !fullScreen;
                  });
                },
              ),
              const Spacer(),
              FilledButton.tonal(
                onPressed: () => context.pop(),
                child: const Icon(Icons.close_outlined),
              ),
              sizedBoxW30H30,
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
    );
  }

  @override
  void initState() {
    super.initState();
    widget.controller._bind = this;
    final authRepo = context.read<AuthenticationRepository>();
    _hasLogin = authRepo.currentUser != null;
    _replyRichController.addListener(_checkEditorContent);
    _authStatusSub = authRepo.status.listen(
      (status) {
        setState(() {
          status == AuthenticationStatus.authenticated
              ? _hasLogin = true
              : _hasLogin = false;
        });
      },
    );
    fullScreen = widget.fullScreen;
    focusNode.requestFocus();
  }

  @override
  void dispose() {
    _replyFocusNode.dispose();
    _authStatusSub.cancel();
    final text = _replyRichController.toBBCode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.outerTextController.text = text;
    });
    _replyRichController
      ..removeListener(_checkEditorContent)
      ..dispose();
    // Mark controller state is disposed.
    widget.controller._unbind();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReplyBloc, ReplyState>(
      listener: (context, state) {
        // Clear text one time when user send request succeed.
        if (state.status == ReplyStatus.success && state.needClearText) {
          // TODO: Implement
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
final class ReplyBarController with LoggerMixin {
  _ReplyBarState? _state;

  void Function()? _onSetHintTextCallback;

  /// All values temporarily saved here MUST be cleared when [_unbind] called.
  ///
  /// Temporary value that saves before [_state] bind.
  /// Because sometimes we bind these values before bind a state.
  /// Defer sync values in [_state] till we have a state by called [_bind].
  String? _replyAction;
  bool? _closed;
  String? _hintText;

  // ignore: avoid_setters_without_getters
  set _bind(_ReplyBarState state) {
    _state = state;
    // All values temporarily saved here MUST be cleared when `_unbind` called.
    if (_replyAction != null) {
      _state!._replyAction = _replyAction;
      debug('update reply action');
    }
    if (_closed != null) {
      _state!._closed = _closed!;
    }
    if (_hintText != null) {
      _state!._hintText = _hintText;
    }
  }

  /// Unbind state.
  ///
  /// This function is called when state got disposed.
  /// So that all actions triggered after state disposal and before next state
  /// init is:
  ///
  /// 1. Saved temporarily in controller.
  /// 2. Applied to new state when next state init.
  void _unbind() {
    // Clear state.
    _state = null;

    // Clear temporarily saved values.
    _replyAction = null;
    _closed = null;
    _hintText = null;
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
    _onSetHintTextCallback?.call();
    if (_state == null) {
      _hintText = hintText;
      return;
    }
    _state!._setHintText(hintText);
  }

  /// Function to call when [setHintText] called.
  ///
  /// Use this to popup editor.
  ///
  // ignore: avoid_setters_without_getters
  set onSetHintText(void Function() callback) {
    _onSetHintTextCallback = callback;
  }

  /// Let the [ReplyBar] get the focus.
  void requestFocus() {
    if (_closed ?? false) {
      _state?._replyFocusNode.requestFocus();
    }
  }
}
