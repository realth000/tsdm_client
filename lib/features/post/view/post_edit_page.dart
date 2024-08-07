import 'package:flutter/material.dart';
import 'package:flutter_bbcode_editor/flutter_bbcode_editor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/constants.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/features/editor/widgets/rich_editor.dart';
import 'package:tsdm_client/features/editor/widgets/toolbar.dart';
import 'package:tsdm_client/features/post/bloc/post_edit_bloc.dart';
import 'package:tsdm_client/features/post/models/post_edit_content.dart';
import 'package:tsdm_client/features/post/models/post_edit_type.dart';
import 'package:tsdm_client/features/post/repository/post_edit_repository.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/utils/retry_button.dart';
import 'package:tsdm_client/utils/show_bottom_sheet.dart';
import 'package:tsdm_client/utils/show_dialog.dart';
import 'package:tsdm_client/utils/show_toast.dart';

/// Default thread title text length (bytes size in utf-8 encoding).
///
/// Actually this value should be provided by the server. Only use this value
/// if not found.
const _defaultThreadTitleMaxlength = 210;

/// Page lets the user to edit a post.
///
/// This is a full screen page, as an alternative choice to edit a post.
///
/// Not only edit the post:
///
/// * Write a new post.
/// * Edit an existing post.
/// * Write a new thread. Because the "thread" is a special post that at the
///   first floor.
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
  const PostEditPage({
    required this.editType,
    required this.fid,
    required this.tid,
    required this.pid,
    super.key,
  });

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
  final String tid;

  /// Post id of the post.
  final String pid;

  static String _formatDataUrl({
    required String fid,
    required String tid,
    required String pid,
  }) {
    return '$baseUrl/forum.php?mod=post&action=edit&fid=$fid&tid=$tid&pid=$pid';
  }

  @override
  State<PostEditPage> createState() => _PostEditPageState();
}

class _PostEditPageState extends State<PostEditPage> {
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

  final bbcodeController = BBCodeEditorController();

  // BBCode text attribute status.
  Color? foregroundColor;
  Color? backgroundColor;
  int? fontSizeLevel;

  /// Show a modal bottom sheet to let user select a thread type.
  ///
  /// Note that the content data [state.content.threadTypeList] MUST be
  /// guaranteed to have values before calling this function.
  Future<void> _showSelectThreadTypeBottomSheet(
    BuildContext context,
    PostEditState state,
  ) async {
    await showCustomBottomSheet<void>(
      context: context,
      title: context.t.postEditPage.editPostTitle,
      childrenBuilder: (context) => state.content!.threadTypeList!
          .map(
            (e) => ListTile(
              title: Text(e.name),
              trailing: e.name == threadTypeController.text
                  ? const Icon(Icons.check_outlined)
                  : null,
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
  Future<void> _showAdditionalOptionBottomSheet(
    BuildContext context,
    PostEditState state,
  ) async {
    await showCustomBottomSheet<void>(
      context: context,
      title: context.t.postEditPage.additionalOptions,
      childrenBuilder: (context) => additionalOptionsMap!.values
          .map(
            (e) => StatefulBuilder(
              builder: (context, setState) {
                return SwitchListTile(
                  title: Text(e.readableName),
                  value: additionalOptionsMap![e.name]!.checked,
                  onChanged: e.disabled
                      ? null
                      : (value) => setState(() {
                            additionalOptionsMap![e.name] =
                                e.copyWith(checked: value);
                          }),
                );
              },
            ),
          )
          .toList(),
    );
  }

  Widget _buildTitleRow(BuildContext context, PostEditState state) {
    final ret = <Widget>[];
    if (state.content?.threadType != null &&
        (state.content?.threadTypeList?.isNotEmpty ?? false)) {
      ret.add(
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 100),
          child: TextFormField(
            key: formKey,
            controller: threadTypeController,
            decoration: InputDecoration(
              labelText: context.t.postEditPage.threadType,
              suffixIcon: const Icon(Icons.arrow_drop_down),
            ),
            readOnly: true,
            onTap: () async => _showSelectThreadTypeBottomSheet(context, state),
            // Only auto focus to title field when writing new thread.
            autofocus: widget.editType == PostEditType.newThread,
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
                return context.t.postEditPage.threadTypeShouldNotBeEmpty;
              }
              return null;
            },
          ),
        ),
      );
    }
    if (state.content?.threadTypeList?.isNotEmpty ?? false) {
      ret.add(
        Expanded(
          child: TextFormField(
            controller: threadTitleController,
            decoration: InputDecoration(
              labelText: context.t.postEditPage.threadTitle,
              suffixText: ' $threadTitleRestLength',
            ),
            onChanged: (value) {
              setState(() {
                threadTitleRestLength = (state.content?.threadTitleMaxLength ??
                        _defaultThreadTitleMaxlength) -
                    value.parseUtf8Length;
              });
            },
            validator: (v) {
              if (widget.editType.isEditingPost) {
                // Skip check when editing post, post have no thread type.
                return null;
              }
              if (v == null) {
                return context.t.postEditPage.titleShouldNotBeEmpty;
              }
              final titleLength = v.parseUtf8Length;
              if (titleLength <= 0) {
                return context.t.postEditPage.titleShouldNotBeEmpty;
              }
              if (titleLength >=
                  (state.content?.threadTitleMaxLength ??
                      _defaultThreadTitleMaxlength)) {
                return context.t.postEditPage.titleTooLong;
              }
              return null;
            },
          ),
        ),
      );
    }
    if (ret.isEmpty) {
      return Container();
    }
    return Row(children: ret.insertBetween(sizedBoxW20H20));
  }

  /// Build the row to control a
  Widget _buildControlRow(BuildContext context, PostEditState state) {
    return Row(
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
          icon: const Icon(Icons.settings_outlined),
          onPressed: additionalOptionsMap != null
              ? () async => _showAdditionalOptionBottomSheet(context, state)
              : null,
        ),
        const Spacer(),
        FilledButton(
          // label: Text(context.t.postEditPage.saveAndBack),
          onPressed: state.status == PostEditStatus.uploading
              ? null
              : () {
                  if (widget.editType.isEditingPost) {
                    final event = PostEditCompleteEditRequested(
                      formHash: state.content!.formHash,
                      postTime: state.content!.postTime,
                      delattachop: state.content!.delattachop,
                      page: state.content!.page,
                      wysiwyg: state.content!.wysiwyg,
                      fid: widget.fid,
                      tid: widget.tid,
                      pid: widget.pid,
                      threadType: threadType,
                      threadTitle: threadTitleController.text,
                      data: bbcodeController.toBBCode(),
                      options: additionalOptionsMap?.values.toList() ?? [],
                    );
                    context.read<PostEditBloc>().add(event);
                    return;
                  }
                  // TODO: Handle creating a post.
                  // TODO: Handle creating a thread.
                },
          child: state.status == PostEditStatus.uploading
              ? sizedCircularProgressIndicator
              : const Icon(Icons.send_outlined),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        RepositoryProvider(
          create: (_) => PostEditRepository(),
        ),
        BlocProvider(
          create: (context) => PostEditBloc(
            postEditRepository: RepositoryProvider.of(context),
          )..add(
              PostEditLoadDataRequested(
                PostEditPage._formatDataUrl(
                  fid: widget.fid,
                  tid: widget.tid,
                  pid: widget.pid,
                ),
              ),
            ),
        ),
      ],
      child: BlocListener<PostEditBloc, PostEditState>(
        listener: (context, state) {
          if (state.status == PostEditStatus.failedToLoad) {
            showSnackBar(
              context: context,
              message: context.t.postEditPage.failedToLoadData,
            );
          } else if (state.status == PostEditStatus.failedToUpload &&
              state.errorText != null) {
            showSnackBar(context: context, message: state.errorText!);
          } else if (state.status == PostEditStatus.success &&
              widget.editType.isEditingPost) {
            showSnackBar(
              context: context,
              message: context.t.postEditPage.editSuccess,
            );
            context.pop();
          }
        },
        child: BlocBuilder<PostEditBloc, PostEditState>(
          builder: (context, state) {
            if (state.status == PostEditStatus.initial ||
                state.status == PostEditStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == PostEditStatus.failedToLoad) {
              return buildRetryButton(context, () {
                context.read<PostEditBloc>().add(
                      PostEditLoadDataRequested(
                        PostEditPage._formatDataUrl(
                          fid: widget.fid,
                          tid: widget.tid,
                          pid: widget.pid,
                        ),
                      ),
                    );
              });
            }

            // Only init these values once.
            if (!init) {
              threadTypeController.text =
                  state.content?.threadType?.name ?? '  ';
              threadType = state.content?.threadType;
              threadTitleController.text = state.content?.threadTitle ?? '';
              // Update the length of chars user can still input.
              // Bytes of chars for title in utf-8 encoding.
              threadTitleRestLength = (state.content?.threadTitleMaxLength ??
                      _defaultThreadTitleMaxlength) -
                  threadTitleController.text.parseUtf8Length;
              dataController.text = state.content?.data ?? '';
              if (state.content?.options != null) {
                additionalOptionsMap = Map.fromEntries(
                  state.content!.options!.map((e) => MapEntry(e.name, e)),
                );
              }
              init = true;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleRow(context, state),
                sizedBoxW20H20,
                // Post data editor.
                Expanded(
                  child: RichEditor(
                    controller: bbcodeController,
                    initialText: state.content?.data,
                  ),
                ),
                sizedBoxW5H5,
                EditorToolbar(
                  bbcodeController: bbcodeController,
                  disabledFeatures: defaultFullScreenDisabledEditorFeatures,
                ),
                _buildControlRow(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (widget.editType) {
      PostEditType.newPost => context.t.postEditPage.newPostTitle,
      PostEditType.newThread => context.t.postEditPage.newThreadTitle,
      PostEditType.editPost => context.t.postEditPage.editPostTitle,
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
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Padding(
          padding: edgeInsetsL15T15R15B15,
          child: _buildBody(context),
        ),
      ),
    );
  }
}
