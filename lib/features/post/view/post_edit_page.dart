import 'package:chat_bottom_container/chat_bottom_container.dart';
import 'package:dart_bbcode_parser/dart_bbcode_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbcode_editor/flutter_bbcode_editor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tsdm_client/constants/constants.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/features/editor/widgets/rich_editor.dart';
import 'package:tsdm_client/features/editor/widgets/toolbar.dart';
import 'package:tsdm_client/features/post/bloc/post_edit_bloc.dart';
import 'package:tsdm_client/features/post/models/models.dart';
import 'package:tsdm_client/features/post/repository/post_edit_repository.dart';
import 'package:tsdm_client/features/post/widgets/input_price_dialog.dart';
import 'package:tsdm_client/features/post/widgets/select_perm_dialog.dart';
import 'package:tsdm_client/features/settings/bloc/settings_bloc.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/utils/platform.dart';
import 'package:tsdm_client/utils/retry_button.dart';
import 'package:tsdm_client/utils/show_bottom_sheet.dart';
import 'package:tsdm_client/utils/show_dialog.dart';
import 'package:tsdm_client/utils/show_toast.dart';
import 'package:tsdm_client/widgets/section_switch_list_tile.dart';
import 'package:tsdm_client/widgets/selectable_list_tile.dart';

/// Default thread title text length (bytes size in utf-8 encoding).
///
/// Actually this value should be provided by the server. Only use this value
/// if not found.
const _defaultThreadTitleMaxlength = 210;

/// Enum indicating the way to save data, or call it post data to server.
///
/// When publishing a new thread or editing thread draft, user can choose one of
/// the following save method.
///
/// * Save in draft.
/// * Publish as new thread (no longer a draft).
///
/// So here is going to have two buttons for each method.
///
/// Use this enum to display different widget style so that user knows which
/// method was chosen.
enum _UploadMethod {
  /// No upload action triggered yet.
  notYet,

  /// Publish new thread action triggered.
  publish,

  /// Save thread in draft action triggered.
  saveDraft,
}

enum _BottomPanelType { none, keyboard, toolbar }

/// Page lets the user to edit a post.
///
/// This is a full screen page, as an alternative choice to edit a post.
///
/// Not only edit the post:
///
/// * Edit an existing post.
/// * Write a new thread. Because the "thread" is a special post that at the
///   first floor.
/// * Edit existing thread.
///
/// Though writing a new thread looks like a different reason, it is the same
/// with editing a new post.
///
/// # Pop back
///
/// This page is allowed to pop when editing, which means:
///
/// * The user is writing something new, new post or new thread.
/// * The user want to write the post without this page (e.g. in a `ReplyBar`).
///
/// Here we need to ensure:
///
/// * Pop the edit page safely.
/// * Pass the latest edit content back to where user enter this page.
///
/// So when pop back: let the route return value to be a valid object
/// representing the latest edit content.
///
/// Note that this kind of return value is NEVER going to happen when editing
/// something already existed (e.g. edit post and thread) because the all edit
/// ability MUST be in the page. And in this situation we need to notify
/// the user "You are going to leave this page and everything you edited will
/// lost".
class PostEditPage extends StatefulWidget {
  /// Constructor.
  const PostEditPage({required this.editType, required this.fid, required this.tid, required this.pid, super.key});

  /// Reason to enter [PostEditPage].
  ///
  /// This page is used by multiple reasons:
  ///
  /// * Write a new post.
  /// * Edit an existing post.
  final PostEditType editType;

  /// Forum id of the post.
  final String fid;

  /// Thread id of the post.
  final String? tid;

  /// Post id of the post.
  final String? pid;

  @override
  State<PostEditPage> createState() => _PostEditPageState();
}

class _PostEditPageState extends State<PostEditPage> with LoggerMixin {
  final panelController = ChatBottomPanelContainerController<_BottomPanelType>();
  _BottomPanelType panelType = _BottomPanelType.none;

  /// Allow reply bar full screen.
  ///
  /// Will not restrict reply bar height when set to true.
  late bool fullScreen;

  /// Show text attribute control button or not.
  bool showTextAttributeButtons = false;

  final focusNode = FocusNode();

  /// Key of the form.
  final formKey = GlobalKey<FormState>();

  /// User selected [ThreadType] value.
  PostEditThreadType? threadType;

  /// Text controller of thread type form field.
  ///
  /// This text is only a visible text, actual used thread type value is saved
  /// in [threadType].
  final threadTypeController = TextEditingController();

  /// Text controller of thread title form field.
  final threadTitleController = TextEditingController();

  /// Rest length that user can input.
  ///
  /// Thread title has a max length limited by server.
  /// Use this field to record how many bytes of char user can input.
  int threadTitleRestLength = 0;

  /// Text controller of thread data form field.
  final dataController = TextEditingController();

  // TODO: Do NOT use bool flag.
  /// Flag to control only init state when first build in loaded state.
  ///
  /// This is ugly.
  bool init = false;

  /// Additional options used here.
  ///
  /// Here we copy and save the additional options in state to here. This avoid
  /// updating state when user just changed an option. Only apply these options
  /// to state when posting the data to server.
  ///
  /// Key is option's attribute name.
  /// Value is the option itself.
  Map<String, PostEditContentOption>? additionalOptionsMap;

  /// Optional permission set to access this thread.
  ///
  /// Only used when editing thread, not other floors' posts.
  String? perm;

  /// Optional price set to this thread.
  ///
  /// Only used when editing thread, not other floors' posts.
  int? price;

  late BBCodeEditorController bbcodeController;

  bool initialized = false;

  // BBCode text attribute status.
  Color? foregroundColor;
  Color? backgroundColor;
  int? fontSizeLevel;

  /// Enum indicating which upload method user has triggered.
  ///
  /// Only used when:
  ///
  /// * Drafting a new thread.
  /// * Editing thread draft.
  _UploadMethod uploadMethod = _UploadMethod.notYet;

  static String _formatDataUrl({required String fid, required String tid, required String pid}) {
    return '$baseUrl/forum.php?mod=post&action=edit&fid=$fid&tid=$tid&pid=$pid';
  }

  Future<void> _onFinish(BuildContext context, PostEditState state, {bool saveDraft = false}) async {
    if (widget.editType.isEditingDraft) {
      final tr = context.t.postEditPage.threadPublish;
      final ret = await showQuestionDialog(
        context: context,
        title: tr.title,
        richMessage: tr.warningBeforePost.body(
          forumName: TextSpan(
            text: state.forumName ?? '<unknown>',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          threadTitle: TextSpan(
            text: threadTitleController.text,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          threadType: TextSpan(
            text: threadTypeController.text,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          warning: TextSpan(
            text: tr.warningBeforePost.warning,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      );
      if (ret != true) {
        return;
      }
    }
    if (!context.mounted) {
      return;
    }

    final event = switch (widget.editType) {
      PostEditType.editPost || PostEditType.editDraft => PostEditCompleteEditRequested(
        formHash: state.content!.formHash,
        postTime: state.content!.postTime,
        delattachop: state.content?.delattachop ?? '0',
        page: state.content!.page!,
        wysiwyg: state.content!.wysiwyg,
        fid: widget.fid,
        // Not null when editing post
        tid: widget.tid!,
        // Not null when editing post
        pid: widget.pid!,
        threadType: threadType,
        threadTitle: threadTitleController.text,
        data: bbcodeController.toBBCode(),
        options: additionalOptionsMap?.values.toList() ?? [],
        save: saveDraft ? '1' : '',
        perm: perm,
        price: price,
      ),
      PostEditType.newThread => ThreadPubPostThread(
        ThreadPublishInfo(
          formHash: state.content!.formHash,
          postTime: state.content!.postTime,
          delAttachOp: state.content?.delattachop ?? '0',
          wysiwyg: state.content?.wysiwyg ?? '0',
          fid: widget.fid,
          threadType: threadType,
          checkbox: '0',
          subject: threadTitleController.text,
          message: bbcodeController.toBBCode(),
          perm: perm,
          price: price,
          save: saveDraft ? '1' : '',
          options: additionalOptionsMap?.values.toList() ?? [],
        ),
      ),
    };
    if (saveDraft) {
      uploadMethod = _UploadMethod.saveDraft;
    } else {
      uploadMethod = _UploadMethod.publish;
    }
    context.read<PostEditBloc>().add(event);
    return;
  }

  // TODO: Fix duplicate with same logic in thread page.
  Widget _buildMobileToolbar(BuildContext context, PostEditState state) {
    return ChatBottomPanelContainer<_BottomPanelType>(
      controller: panelController,
      inputFocusNode: focusNode,
      otherPanelWidget: (type) {
        return switch (type) {
          null => sizedBoxEmpty,
          _BottomPanelType.none => sizedBoxEmpty,
          _BottomPanelType.keyboard => sizedBoxEmpty,
          _BottomPanelType.toolbar => Align(
            child: EditorToolbar(
              bbcodeController: bbcodeController,
              disabledFeatures: fullScreen ? defaultFullScreenDisabledEditorFeatures : defaultEditorDisabledFeatures,
              editorFocusNode: focusNode,
            ),
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

  /// Show a modal bottom sheet to let user select a thread type.
  ///
  /// Note that the content data `state.content.threadTypeList` MUST be
  /// guaranteed to have values before calling this function.
  Future<void> _showSelectThreadTypeBottomSheet(BuildContext context, PostEditState state) async {
    await showCustomBottomSheet<void>(
      context: context,
      title: context.t.postEditPage.editPostTitle,
      childrenBuilder:
          (context) =>
              state.content!.threadTypeList!
                  .map(
                    (e) => SelectableListTile(
                      title: Text(e.name),
                      selected: e.name == threadTypeController.text,
                      onTap: () {
                        threadType = e;
                        threadTypeController.text = e.name;
                        context.pop();
                      },
                    ),
                  )
                  .toList(),
    );
  }

  /// Show a bottom sheet to let user configure the additional options provided
  /// by the server side.
  ///
  /// Options are a list of checkbox.
  ///
  /// Note that the additional options map MUST NOT a null value.
  Future<void> _showAdditionalOptionBottomSheet(BuildContext context, PostEditState state) async {
    await showCustomBottomSheet<void>(
      context: context,
      title: context.t.postEditPage.additionalOptions,
      childrenBuilder:
          (context) =>
              additionalOptionsMap!.values
                  .map(
                    (e) => StatefulBuilder(
                      builder: (context, setState) {
                        return SectionSwitchListTile(
                          title: Text(e.readableName),
                          value: additionalOptionsMap![e.name]!.checked,
                          onChanged:
                              e.disabled
                                  ? null
                                  : (value) => setState(() {
                                    additionalOptionsMap![e.name] = e.copyWith(checked: value);
                                  }),
                        );
                      },
                    ),
                  )
                  .toList(),
    );
  }

  Widget _buildTitleRow(BuildContext context, PostEditState state) {
    final tr = context.t.postEditPage;

    final ret = <Widget>[];
    if (state.content?.threadTypeList?.isNotEmpty ?? false) {
      ret.add(
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 100),
          child: TextFormField(
            key: formKey,
            controller: threadTypeController,
            decoration: InputDecoration(labelText: tr.threadType, suffixIcon: const Icon(Icons.arrow_drop_down)),
            readOnly: true,
            onTap: () async => _showSelectThreadTypeBottomSheet(context, state),
            // Only auto focus to title field when writing new thread.
            validator: (v) {
              if (widget.editType.isEditingPost) {
                // Skip check when editing post, post have no thread type.
                return null;
              }

              // Thread type should not be null nor no more than zero.
              if (v == null ||
                  threadType == null ||
                  threadType!.typeID == null ||
                  ((threadType!.typeID?.parseToInt() ?? -1) <= 0)) {
                return tr.threadTypeShouldNotBeEmpty;
              }
              return null;
            },
          ),
        ),
      );
    }

    // Always add title no matter thread type presents or not.
    // All thread floors have a legal "subject" here.
    ret.add(
      Expanded(
        child: TextFormField(
          controller: threadTitleController,
          decoration: InputDecoration(
            labelText: tr.title,
            suffixText: ' $threadTitleRestLength',
            suffixIcon: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed:
                  () async => showMessageSingleButtonDialog(
                    context: context,
                    title: tr.whyTitleDialog.title,
                    message: tr.whyTitleDialog.detail,
                  ),
            ),
          ),
          onChanged: (value) {
            setState(() {
              threadTitleRestLength =
                  (state.content?.threadTitleMaxLength ?? _defaultThreadTitleMaxlength) - value.parseUtf8Length;
            });
          },
          validator: (v) {
            if (widget.editType.isEditingPost) {
              // Skip check when editing post, post have no thread type.
              return null;
            }
            if (v == null) {
              return tr.titleShouldNotBeEmpty;
            }
            final titleLength = v.parseUtf8Length;
            if (titleLength <= 0) {
              return tr.titleShouldNotBeEmpty;
            }
            if (titleLength >= (state.content?.threadTitleMaxLength ?? _defaultThreadTitleMaxlength)) {
              return tr.titleTooLong;
            }
            return null;
          },
        ),
      ),
    );
    if (ret.isEmpty) {
      return Container();
    }
    return Padding(padding: edgeInsetsL8R8.add(edgeInsetsT8), child: Row(children: ret.insertBetween(sizedBoxW24H24)));
  }

  /// Build the row to control a
  Widget _buildControlRow(BuildContext context, PostEditState state) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                sizedBoxW4H4,
                // Only control expand or collapse on mobile platforms.
                // For desktop, always expand the toolbar.
                if (isMobile)
                  IconButton(
                    icon: const Icon(Icons.expand),
                    tooltip: context.t.bbcodeEditor.toolbar,
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
                if (additionalOptionsMap != null)
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: context.t.bbcodeEditor.additionalOptions,
                    onPressed: () async => _showAdditionalOptionBottomSheet(context, state),
                  ),
                if (state.content?.permList?.isNotEmpty ?? false)
                  Badge(
                    label: Text('$perm'),
                    offset: const Offset(-4, 4),
                    isLabelVisible: perm != null && perm!.isNotEmpty,
                    child: IconButton(
                      icon: const Icon(Icons.lock_open_outlined),
                      selectedIcon: const Icon(Icons.lock_outline),
                      isSelected: perm != null && perm!.isNotEmpty,
                      tooltip: context.t.bbcodeEditor.readPerm,
                      onPressed: () async {
                        final selectedPerm = await showSelectPermDialog(context, state.content!.permList!, perm);
                        if (selectedPerm == null || !context.mounted) {
                          return;
                        }
                        setState(() {
                          perm = selectedPerm;
                        });
                      },
                    ),
                  ),
                if (price != null)
                  Badge(
                    label: Text('$price'),
                    textStyle: Theme.of(context).textTheme.labelSmall,
                    offset: const Offset(-4, 4),
                    isLabelVisible: price != null && price != 0,
                    child: IconButton(
                      icon: const Icon(Icons.money_off_outlined),
                      tooltip: context.t.postEditPage.priceDialog.entryTooltip,
                      selectedIcon: const Icon(Icons.attach_money_outlined),
                      isSelected: price != null && price != 0,
                      onPressed: () async {
                        // TODO: show a dialog to set price.
                        final inputPrice = await showInputPriceDialog(context, price, state.content?.maxPrice);
                        if (inputPrice != null) {
                          setState(() {
                            price = inputPrice;
                          });
                        }
                      },
                    ),
                  ),
                sizedBoxW4H4,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, PostEditState state) {
    if (state.status == PostEditStatus.initial || state.status == PostEditStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == PostEditStatus.failedToLoad) {
      return buildRetryButton(context, () {
        switch (widget.editType) {
          case PostEditType.editPost || PostEditType.editDraft:
            context.read<PostEditBloc>().add(
              PostEditLoadDataRequested(
                _formatDataUrl(
                  fid: widget.fid,
                  // Not null when editing post
                  tid: widget.tid!,
                  // Not null when editing post
                  pid: widget.pid!,
                ),
              ),
            );
          case PostEditType.newThread:
            context.read<PostEditBloc>().add(ThreadPubFetchInfoRequested(fid: widget.fid));
        }
      });
    }

    if (!initialized) {
      final data = state.content?.data;
      if (data != null) {
        if (context.read<SettingsBloc>().state.settingsMap.enableEditorBBCodeParser) {
          final delta = parseBBCodeTextToDelta(data);
          bbcodeController.setDocumentFromDelta(delta);
        } else {
          bbcodeController.setDocumentFromRawText(data);
        }
      }
      initialized = true;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleRow(context, state),
        sizedBoxW4H4,
        // Post data editor.
        // Now we don't restrict the thread type and thread title, so it's better to focus on content area.
        Expanded(
          child: Padding(
            padding: isMobile ? edgeInsetsL16R16 : edgeInsetsL4R4,
            child: RichEditor(autoFocus: true, controller: bbcodeController, editorFocusNode: focusNode),
          ),
        ),
        if (isDesktop)
          // Expand and can not replace with Align.
          Row(
            children: [
              Expanded(
                child: ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  child: Padding(
                    padding: edgeInsetsL4R4.add(edgeInsetsT4),
                    child: EditorToolbar(
                      bbcodeController: bbcodeController,
                      disabledFeatures: defaultFullScreenDisabledEditorFeatures,
                      editorFocusNode: focusNode,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          child: Padding(padding: edgeInsetsR4.add(edgeInsetsB4), child: _buildControlRow(context, state)),
        ),
        if (isMobile) _buildMobileToolbar(context, state),
      ],
    );
  }

  Future<void> _onListen(BuildContext context, PostEditState state) async {
    if (state.status == PostEditStatus.failedToLoad) {
      showSnackBar(context: context, message: context.t.postEditPage.failedToLoadData);
    } else if (state.status == PostEditStatus.failedToUpload) {
      showSnackBar(context: context, message: state.errorText ?? context.t.general.failedToLoad);
    } else if (state.status == PostEditStatus.success) {
      // Some action succeeded.
      if (widget.editType.isEditingPost) {
        // Edit post.
        showSnackBar(context: context, message: context.t.postEditPage.editSuccess);
        context.pop();
        return;
      } else if (widget.editType.isEditingDraft) {
        // Writing new post.
        //
        // Ask for a redirect to just published thread page.
        if (state.redirectTid != null) {
          // Could redirect to new thread page.
          final tr = context.t.postEditPage.threadPublish.afterPostDialog;
          final result = await showQuestionDialog(context: context, title: tr.title, message: tr.message);
          if (!context.mounted) {
            return;
          }
          if (result ?? false) {
            context.pushReplacementNamed(ScreenPaths.threadV1, queryParameters: {'tid': state.redirectTid});
            return;
          }
        }

        context.pop();
      }
    } else if (state.status == PostEditStatus.editing && !init) {
      threadTypeController.text = state.content?.threadType?.name ?? '  ';
      threadTitleController.text = state.content?.threadTitle ?? '';
      // Update the length of chars user can still input.
      // Bytes of chars for title in utf-8 encoding.
      threadTitleRestLength =
          (state.content?.threadTitleMaxLength ?? _defaultThreadTitleMaxlength) -
          threadTitleController.text.parseUtf8Length;
      dataController.text = state.content?.data ?? '';
      if (state.content?.options != null) {
        additionalOptionsMap = Map.fromEntries(state.content!.options!.map((e) => MapEntry(e.name, e)));
      }

      setState(() {
        threadType ??= state.content?.threadType;
        // Automatically select the first thread type like the server
        // does.
        //
        // Usually the first type is a hint to choose type with 0 as
        // value.
        threadType ??= state.content?.threadTypeList?.firstOrNull;
        threadTypeController.text = threadType?.name ?? '';
        perm = state.content?.permList?.where((e) => e.selected).lastOrNull?.perm;
        price = state.content?.price;
      });

      init = true;
    } else if (state.status == PostEditStatus.editing) {
      setState(() {
        perm = state.content?.permList?.where((e) => e.selected).lastOrNull?.perm;
        price = state.content?.price;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    debug(
      'enter post edit page: '
      'editType=${widget.editType}, fid=${widget.fid}',
    );
    bbcodeController = buildBBCodeEditorController();
    fullScreen = isDesktop;
  }

  @override
  void dispose() {
    bbcodeController.dispose();
    focusNode.dispose();
    threadTypeController.dispose();
    threadTitleController.dispose();
    dataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (widget.editType) {
      PostEditType.newThread => context.t.postEditPage.newThreadTitle,
      PostEditType.editPost || PostEditType.editDraft => context.t.postEditPage.editPostTitle,
    };

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }

        // TODO: Control the pop back.
        // * Return the value we need to pass the the caller route if writing
        //   something new.
        // * Let user confirm the pop back if editing something already existed.
        // * If possible save the edit content into draft.
        context.pop();
      },
      child: MultiBlocProvider(
        providers: [
          RepositoryProvider(create: (_) => PostEditRepository()),
          BlocProvider(
            create: (context) {
              final bloc = PostEditBloc(postEditRepository: context.repo());

              final event = switch (widget.editType) {
                PostEditType.editPost || PostEditType.editDraft => PostEditLoadDataRequested(
                  _formatDataUrl(fid: widget.fid, tid: widget.tid!, pid: widget.pid!),
                ),
                PostEditType.newThread => ThreadPubFetchInfoRequested(fid: widget.fid),
              };
              bloc.add(event);
              return bloc;
            },
          ),
        ],
        child: BlocConsumer<PostEditBloc, PostEditState>(
          listener: (context, state) async => _onListen(context, state),
          builder: (context, state) {
            return Scaffold(
              // Required by chat_bottom_container in the reply bar.
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: Text(title),
                actions: [
                  if (widget.editType.isEditingDraft) ...[
                    IconButton(
                      onPressed:
                          state.status == PostEditStatus.uploading
                              ? null
                              : () async => _onFinish(context, state, saveDraft: true),
                      icon:
                          state.status == PostEditStatus.uploading && uploadMethod == _UploadMethod.saveDraft
                              ? sizedCircularProgressIndicator
                              : Icon(MdiIcons.contentSaveEditOutline, color: Theme.of(context).colorScheme.secondary),
                      tooltip: context.t.postEditPage.saveAsDraft,
                    ),
                  ],
                  IconButton(
                    tooltip: context.t.postEditPage.publish,
                    icon:
                        state.status == PostEditStatus.uploading && uploadMethod == _UploadMethod.publish
                            ? sizedCircularProgressIndicator
                            : const Icon(Icons.send),
                    onPressed: state.status == PostEditStatus.uploading ? null : () async => _onFinish(context, state),
                  ),
                ],
              ),
              body: SafeArea(bottom: false, child: _buildBody(context, state)),
            );
          },
        ),
      ),
    );
  }
}
