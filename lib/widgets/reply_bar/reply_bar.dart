import 'dart:async';

import 'package:chat_bottom_container/chat_bottom_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbcode_editor/flutter_bbcode_editor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/features/authentication/repository/models/models.dart';
import 'package:tsdm_client/features/chat/models/models.dart';
import 'package:tsdm_client/features/editor/widgets/rich_editor.dart';
import 'package:tsdm_client/features/editor/widgets/toolbar.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/utils/platform.dart';
import 'package:tsdm_client/widgets/reply_bar/bloc/reply_bloc.dart';
import 'package:tsdm_client/widgets/reply_bar/models/reply_types.dart';

enum _BottomPanelType { none, keyboard, toolbar }

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

  Future<void> showEditor() async {
    if (widget.controller._showingEditor) {
      // Now we already have an editor, not now override with another one.
      return;
    }

    // Here we actually want to ensure the editor is shown when user set hint
    // text: which means user want to reply to something.
    //
    // The debounce check above only filters duplicate editor, it's safe.

    final c = showBottomSheet(
      context: context,
      shape: InputBorder.none,
      builder:
          (_) => _ReplyBar(
            controller: widget.controller,
            outerTextController: controller,
            replyType: widget.replyType,
            chatHistorySendTarget: widget.chatHistorySendTarget,
            chatSendTarget: widget.chatSendTarget,
            disabledEditorFeatures: widget.disabledEditorFeatures,
            fullScreenDisabledEditorFeatures: widget.fullScreenDisabledEditorFeatures,
            fullScreen: widget.fullScreen,
          ),
    );

    widget.controller._showingEditor = true;
    await c.closed;
    widget.controller._showingEditor = false;
  }

  @override
  void initState() {
    super.initState();
    widget.controller.onSetHintText = showEditor;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.dispose();
    });
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasLogin = context.select<AuthenticationRepository, bool>((repo) => repo.currentUser != null);
    final closed = context.select<ReplyBloc, bool>((bloc) => bloc.state.closed);

    Future<void> Function()? onTapCallback;

    if (!hasLogin) {
      controller.text = context.t.threadPage.needLogin;
      onTapCallback = null;
    } else if (closed &&
        // Never close in chat page.
        (widget.replyType != ReplyTypes.chat && widget.replyType != ReplyTypes.chatHistory)) {
      controller.text = context.t.threadPage.closed;
      onTapCallback = null;
    } else {
      onTapCallback = showEditor;
    }

    return BlocConsumer<ReplyBloc, ReplyState>(
      listener: (_, state) {
        // Clear the outer controller text.
        if (state.status == ReplyStatus.success) {
          controller.clear();
          widget.controller._hintText = null;
          widget.controller._replyAction = null;
        }
      },
      buildWhen: (prev, curr) => prev.status != curr.status,
      builder: (context, state) {
        final loading = state.status == ReplyStatus.loading;
        return ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          child: Padding(
            padding: edgeInsetsL12T12R12B12,
            child: TextField(
              controller: controller,
              readOnly: true,
              enabled: onTapCallback != null,
              decoration: InputDecoration(
                hintText: context.t.threadPage.sendReplyHint,
                border: const UnderlineInputBorder(),
                suffix: loading ? sizedCircularProgressIndicator : null,
              ),
              onTap: onTapCallback,
            ),
          ),
        );
      },
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

  // FIXME: Bad practise. widget controller injected from outside and may
  // dispose earlier than the inner widget is anti-pattern and unstable.
  // Try another implementation to achieve syncing text to outside field.
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
  final panelController = ChatBottomPanelContainerController<_BottomPanelType>();
  _BottomPanelType panelType = _BottomPanelType.none;

  /// Indicate current thread is closed.
  bool _closed = false;

  /// Allow reply bar full screen.
  ///
  /// Will not restrict reply bar height when set to true.
  late bool fullScreen;

  late final StreamSubscription<AuthStatus> _authStatusSub;

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
  late BBCodeEditorController _replyRichController;

  /// Flag indicating whether can send the converted bbcode in reply bar to
  /// the outside controller.
  bool _canSyncBBCodeOnDispose = true;

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

  // FIXME: Bad practise.
  /// Manually dispose the reply bar widget.
  ///
  /// This function is called when user rebuilt the outer page including:
  ///
  /// * Refresh thread page.
  /// * Change the thread page index.
  ///
  /// In the situations above, the `_ReplyBar` which placed as a bottom sheet
  /// did not auto-disposed somehow so the only way to close it is calling
  /// [ReplyBarController.dispose], which triggered an incorrect but worked
  /// dispose order:
  ///
  /// 1. The outer page (thread page) disposed.
  /// 2. In the `dispose` method of outer page, called `dispose` of
  ///  `ReplyBarController` finally triggered a manual dispose.
  ///
  /// So here everything inside the outer page is disposed, especially the
  /// outer text controller. Here set [_canSyncBBCodeOnDispose] to false to
  /// avoid using the outer text controller after it disposed.
  void _manuallyDispose() {
    _canSyncBBCodeOnDispose = false;
    context.pop();
  }

  void _clearTextAndHint() {
    setState(() {
      _hintText = null;
      _replyAction = null;
    });
    // Clear saved hint text in controller so text not restore
    // when next time opens.
    widget.controller._hintText = null;
    // Clear reply action to prevent the action applied again when user reopened
    // reply bar without any reply target.
    widget.controller._replyAction = null;
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
      ReplyToThreadRequested(replyParameters: _replyParameters!, replyMessage: _replyRichController.toBBCode()),
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
      case ReplyTypes.thread || ReplyTypes.notice:
        {
          if (_replyAction == null && _replyParameters == null) {
            error(
              'failed to send reply: null action and '
              'parameters',
            );
            return;
          }
          _replyAction == null ? await _sendReplyThreadMessage() : await _sendReplyPostMessage();
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
      child: RichEditor(
        // Initial text is the text passed from outside.
        controller: _replyRichController,
        editorFocusNode: focusNode,
      ),
    );
  }

  /// A row above the reply text area to display some info if needed.
  ///
  /// Currently showing the floor user is replying to (if any), and a button to
  /// set to reply to thread (not any floor).
  Widget _buildHintTextRow(BuildContext context) {
    if (_hintText == null || _closed || !_hasLogin) {
      // The size here is actually a padding on the top of editor body.
      // But it's here.
      return sizedBoxW4H4;
    }
    final outlineColor = Theme.of(context).colorScheme.outline;
    return Padding(
      padding: edgeInsetsL12T4R12,
      child: Row(
        children: [
          Text(_hintText!, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: outlineColor)),
          const Spacer(),
          IconButton(icon: Icon(Icons.clear_outlined, color: outlineColor, size: 16), onPressed: _clearTextAndHint),
        ],
      ),
    );
  }

  Widget _buildDesktopToolbar(BuildContext context, ReplyState state) {
    if (isMobile) {
      return sizedBoxEmpty;
    }
    return EditorToolbar(
      bbcodeController: _replyRichController,
      disabledFeatures: fullScreen ? widget.fullScreenDisabledEditorFeatures : widget.disabledEditorFeatures,
      editorFocusNode: focusNode,
    );
  }

  Widget _buildMobileToolbar(BuildContext context, ReplyState state) {
    if (!isMobile) {
      return sizedBoxEmpty;
    }
    return ChatBottomPanelContainer<_BottomPanelType>(
      controller: panelController,
      inputFocusNode: focusNode,
      otherPanelWidget: (type) {
        return switch (type) {
          null => sizedBoxEmpty,
          _BottomPanelType.none => sizedBoxEmpty,
          _BottomPanelType.keyboard => sizedBoxEmpty,
          _BottomPanelType.toolbar => EditorToolbar(
            bbcodeController: _replyRichController,
            disabledFeatures: fullScreen ? widget.fullScreenDisabledEditorFeatures : widget.disabledEditorFeatures,
            editorFocusNode: focusNode,
          ),
        };
      },
      onPanelTypeChange: (p, data) {
        switch (p) {
          case ChatBottomPanelType.none:
            panelType = _BottomPanelType.none;
          case ChatBottomPanelType.keyboard:
            panelType = _BottomPanelType.keyboard;
            // TODO: Remove the setState after tricky removed.
            // Some button in editor that use a popup menu does not reset
            // fullScreen flag as we are doing some tricky thing in toolbar.
            //
            // Font size button overridden with an empty font size button
            // option is so:
            //
            // QuillToolbarFontSizeButtonOptions(afterButtonPressed: () {}),
            //
            // Manually set to false.
            if (fullScreen) {
              setState(() {
                fullScreen = false;
              });
            }
          case ChatBottomPanelType.other:
            switch (data) {
              case null:
                panelType = _BottomPanelType.none;
              case _BottomPanelType.none:
                panelType = _BottomPanelType.none;
              case _BottomPanelType.keyboard:
                panelType = _BottomPanelType.keyboard;
              case _BottomPanelType.toolbar:
                panelType = _BottomPanelType.toolbar;
            }
        }
      },
      panelBgColor: Theme.of(context).colorScheme.surfaceContainerLow,
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
            padding: edgeInsetsL12T4R12B4,
            child: Listener(
              onPointerUp:
                  // Only collapse editor toolbar on mobile platforms.
                  isMobile
                      ? (_) {
                        setState(() {
                          fullScreen = false;
                        });
                      }
                      : null,
              child: _buildRichEditor(context),
            ),
          ),
        ),

        _buildDesktopToolbar(context, state),
        Padding(
          padding: edgeInsetsL12R12B12,
          child: Row(
            children: [
              // Only control expand or collapse on mobile platforms.
              // For desktop, always expand the toolbar.
              if (isMobile)
                IconButton(
                  icon: const Icon(Icons.expand),
                  selectedIcon: Icon(Icons.expand_outlined, color: Theme.of(context).primaryColor),
                  isSelected: fullScreen,
                  onPressed: () {
                    setState(() {
                      fullScreen = !fullScreen;
                    });
                    if (fullScreen) {
                      panelController.updatePanelType(ChatBottomPanelType.other, data: _BottomPanelType.toolbar);
                    } else {
                      panelController.updatePanelType(ChatBottomPanelType.keyboard);
                    }
                  },
                ),
              const Spacer(),
              FilledButton.tonal(onPressed: () => context.pop(), child: const Icon(Icons.unfold_less)),
              sizedBoxW8H8,
              // Send Button
              FilledButton(
                onPressed:
                    (canSendReply && !isSendingReply && !_closed && _hasLogin) ? () async => _sendMessage() : null,
                child: isSendingReply ? sizedCircularProgressIndicator : const Icon(Icons.send),
              ),
            ],
          ),
        ),
        _buildMobileToolbar(context, state),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    widget.controller._bind = this;
    final authRepo = context.read<AuthenticationRepository>();
    _hasLogin = authRepo.currentUser != null;
    _replyRichController = buildBBCodeEditorController(initialText: widget.outerTextController.text);
    _replyRichController.addListener(_checkEditorContent);
    _authStatusSub = authRepo.status.listen((status) {
      setState(() {
        status is AuthStatusAuthed ? _hasLogin = true : _hasLogin = false;
      });
    });
    fullScreen = widget.fullScreen;
    focusNode.requestFocus();
  }

  @override
  void dispose() {
    _replyFocusNode.dispose();
    _authStatusSub.cancel();
    final text = _replyRichController.toBBCode();
    if (_canSyncBBCodeOnDispose) {
      // Only save text that intend to reply when that text is not empty.
      //
      // Only send text to outside controller if could do so: In some situation
      // the `widget.outerTextController` may already disposed if the
      // `_ReplyBar` is manually disposed (by calling _manuallyDispose()).
      // Use the [_canSyncBBCodeOnDispose] to avoid that.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.outerTextController.text = text;
      });
    }
    _replyRichController
      ..removeListener(_checkEditorContent)
      ..dispose();
    widget.controller._unbind(clearParameters: false);
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReplyBloc, ReplyState>(
      listener: (context, state) {
        // Clear text one time when user send request succeed.
        if (state.status == ReplyStatus.success && state.needClearText) {
          _replyRichController.clearWithoutRequestingFocus();
          // Reset flag because we only want to clear the sent text.
          context.read<ReplyBloc>().add(ReplyResetClearTextStateTriggered());
          _clearTextAndHint();
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
          } else if (state.status == ReplyStatus.failure) {
            // Last reply action is failed, only clear pending state.
            isSendingReply = false;
            // When failed to reply, we did NOT clear any text so is ready for
            // next try.
            canSendReply = true;
          }

          // Should update close state of the current reply bar because we may
          // not send reply to closed threads.
          _closed = switch (widget.replyType) {
            ReplyTypes.thread || ReplyTypes.notice => state.closed,
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

  /// Flag indicating currently popping up the editor or not.
  ///
  /// Use this flag to keep only one editor popup.
  ///
  /// So the text in editor is persistent.
  bool _showingEditor = false;

  /// Flag indicating whe editor is expanded or not.
  bool get showingEditor => _showingEditor;

  /// All values temporarily saved here MUST be cleared when [_unbind] called.
  ///
  /// Temporary value that saves before [_state] bind.
  /// Because sometimes we bind these values before bind a state.
  /// Defer sync values in [_state] till we have a state by called [_bind].
  String? _replyAction;
  bool? _closed;
  String? _hintText;

  // Internal _bind setter.
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
  ///
  /// Clear [_replyAction], [_hintText] and [_closed].
  /// when [clearParameters] is true.
  /// Set [clearParameters] to false when you want to reserve these parameters.
  void _unbind({bool clearParameters = true}) {
    // Clear state.
    _state = null;

    // Clear temporarily saved values.
    if (clearParameters) {
      _replyAction = null;
      _hintText = null;
      _closed = null;
    }
  }

  /// Set reply action url to current state. Call this when user try to reply
  /// to another post, before user writes the reply or sends it.
  ///
  // ignore: avoid_setters_without_getters
  set replyAction(String? replyAction) {
    // Save the reply action no matter state already constructed or not.
    //
    // Since the reply bar became more stateless in pre-release of v1, here the
    // reply action assignment will override with an outdated value if user
    // changed the post to reply when reply bar is in expanded state:
    //
    // 1. User clicked a floor #1, reply bar expanded and _state?._replyAction
    //   set to #1.
    // 2. User clicked another floor #2, reply bar still in expand state and
    //   _state._replyAction set to #2.
    // 3. User closed reply bar and state disposed.
    // 4. User reopened the reply bar without clicking any floor, from here it
    //   is expected to keep the same reply action which is held the last time
    //   which is #2 in this case, but the setter of _replyAction set it back
    //   to #2.
    //
    // save the reply action value no matter state is contructed or not, because
    // the controller class is a value storage lives longer than state itself.
    _replyAction = replyAction;
    if (_state == null) {
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
    // Save the hint text no matter state already constructed or not.
    // See setter `replyAction` for the reason.
    _hintText = hintText;
    if (_state == null) {
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

  // FIXME: Bad practise/anti-pattern. This method here only proves that current
  // implementation of syncing text through reply bar and the dispose process is
  // broken and need refactor. Currently the dispose order is complex and does
  // not following a correct child-to-parent order.
  /// Close the bound reply bar.
  void dispose() => _state?._manuallyDispose();
}
