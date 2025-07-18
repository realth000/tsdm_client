import 'package:collection/collection.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/constants.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/uri.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/features/forum/models/models.dart';
import 'package:tsdm_client/features/jump_page/cubit/jump_page_cubit.dart';
import 'package:tsdm_client/features/need_login/view/need_login_page.dart';
import 'package:tsdm_client/features/settings/repositories/settings_repository.dart';
import 'package:tsdm_client/features/thread/v1/bloc/thread_bloc.dart';
import 'package:tsdm_client/features/thread/v1/repository/thread_repository.dart';
import 'package:tsdm_client/features/thread/v1/widgets/post_list.dart';
import 'package:tsdm_client/features/thread_visit_history/bloc/thread_visit_history_bloc.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/utils/clipboard.dart';
import 'package:tsdm_client/utils/html/html_muncher.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/utils/platform.dart';
import 'package:tsdm_client/utils/retry_button.dart';
import 'package:tsdm_client/utils/show_toast.dart';
import 'package:tsdm_client/widgets/card/error_card.dart';
import 'package:tsdm_client/widgets/card/post_card/post_card.dart';
import 'package:tsdm_client/widgets/copy_content_dialog.dart';
import 'package:tsdm_client/widgets/list_app_bar.dart';
import 'package:tsdm_client/widgets/reply_bar/bloc/reply_bloc.dart';
import 'package:tsdm_client/widgets/reply_bar/models/reply_types.dart';
import 'package:tsdm_client/widgets/reply_bar/reply_bar.dart';
import 'package:tsdm_client/widgets/reply_bar/repository/reply_repository.dart';

/// Page to show thread.
class ThreadPage extends StatefulWidget {
  /// Constructor.
  const ThreadPage({
    required this.threadID,
    required this.findPostID,
    required this.pageNumber,
    required this.overrideReverseOrder,
    required this.overrideWithExactOrder,
    this.title,
    this.threadType,
    this.onlyVisibleUid,
    super.key,
  }) : assert(threadID != null || findPostID != null, 'MUST provide threadID or findPostID');

  /// Thread ID, tid.
  final String? threadID;

  /// Post ID to find and redirect before accessing the real thread page.
  ///
  /// In some situations we do not know the [threadID] but only a post id to
  /// find.
  /// e.g. Redirect from points statistics changelog event:
  ///
  /// * $baseUrl/forum.php?mod=redirect&goto=findpost&pid=xxx
  ///
  /// So In this situation we need to allow this type of url and assume it is
  /// thread page.
  /// With mod=redirect and goto=findpost and the pid parameter is here.
  ///
  /// This field MUST only used when [threadID] is empty.
  final String? findPostID;

  /// Thread title.
  final String? title;

  /// Thread current page number.
  final String pageNumber;

  /// Override the original post order in thread.
  ///
  /// * If `true`, force add a `ordertype` query parameter when fetching page.
  /// * If `false`, do NOT add such param so that use the original post order.
  ///
  /// This flag is used in situation that user is heading to a certain page
  /// contains a target post. If set to `true`, override order may cause going
  /// to a wrong page.
  ///
  /// Additionally, the effect has less priority compared to
  /// [overrideWithExactOrder] where the latter one is specifying the exact
  /// order type and current field only determines using the order specified by
  /// app if has.
  final bool overrideReverseOrder;

  /// Carries the exact order required by external reasons.
  ///
  /// If value is not null, the final thread order is override by the value no
  /// matter [overrideReverseOrder] is true or false.
  ///
  /// Actually this field is a patch on is the following situation:
  ///
  /// ```console
  /// ${HOST}/...&ordertype=N
  /// ```
  ///
  /// where order type is directly specified in url before dispatching, and
  /// should override any order in app settings.
  final int? overrideWithExactOrder;

  /// Thread type.
  ///
  /// Sometimes we do not know the thread type before we load it, redirect from
  /// homepage, for example. So it's a nullable String.
  final FilterType? threadType;

  /// Only watch the floors posted by the user with uid [onlyVisibleUid].
  final String? onlyVisibleUid;

  @override
  State<ThreadPage> createState() => _ThreadPageState();
}

class _ThreadPageState extends State<ThreadPage> with SingleTickerProviderStateMixin, LoggerMixin {
  /// Controller of thread tab.
  final _listScrollController = ScrollController();

  final _replyBarController = ReplyBarController();

  Widget _buildBreadcrumbsRow(ThreadState state) {
    final infoTextStyle = Theme.of(
      context,
    ).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.outline);

    final infoTextHighlightStyle = Theme.of(
      context,
    ).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary);

    final breadFrags = state.breadcrumbs
        .map(
          (e) => [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () async {
                  final gid = e.link.tryGetQueryParameters()?['gid'];
                  if (gid != null) {
                    await context.pushNamed(
                      ScreenPaths.forumGroup,
                      pathParameters: {'gid': gid},
                      queryParameters: {'title': e.description},
                    );
                    return;
                  }
                  await context.dispatchAsUrl(e.link.toString());
                },
                child: Text(e.description, style: infoTextHighlightStyle),
              ),
            ),
            const Text(' > '),
          ],
        )
        .flattenedToList;

    return Padding(
      padding: edgeInsetsL12R12.add(edgeInsetsB4),
      child: DefaultTextStyle.merge(
        style: infoTextStyle,
        child: SizedBox(
          height: 20,
          child: ListView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            children: <Widget>[
              ...breadFrags,
              if (state.threadType?.typeID != null && state.fid != null)
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () async => context.pushNamed(
                      ScreenPaths.forum,
                      pathParameters: {'fid': '${state.fid}'},
                      queryParameters: {
                        'threadTypeName': state.threadType?.name,
                        'threadTypeID': '${state.threadType?.typeID}',
                      },
                    ),
                    child: Text('[${state.threadType!.name}]', style: infoTextHighlightStyle),
                  ),
                ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () async {
                    final tr = context.t.threadPage.threadInfo;
                    final id = state.tid ?? widget.threadID;
                    final title = state.title ?? widget.title;
                    await showCopyContentDialog(
                      context: context,
                      title: tr.title,
                      contents: [
                        CopyableContent(name: tr.threadTitle, data: state.title ?? widget.title ?? ''),
                        if (id != null) ...[
                          CopyableContent(name: tr.threadID, data: id),
                          CopyableContent(name: tr.threadUrl, data: 'forum.php?mod=viewthread&tid=$id'),
                          CopyableContent(
                            name: tr.threadUrlWithDomain,
                            data: '$baseUrl/forum.php?mod=viewthread&tid=$id',
                          ),
                        ],
                        if (id != null && title != null) ...[
                          CopyableContent(
                            name: tr.threadUrlBBCode,
                            data: '[url=forum.php?mod=viewthread&tid=$id]$title[/url]',
                          ),
                          CopyableContent(
                            name: tr.threadUrlBBCodeWithDomain,
                            data: '[url=$baseUrl/forum.php?mod=viewthread&tid=$id]$title[/url]',
                          ),
                        ],
                      ],
                    );
                  },
                  child: Text('[${context.t.threadPage.title} ${state.tid ?? ""}]', style: infoTextHighlightStyle),
                ),
              ),
              if (state.viewCount != null || state.replyCount != null)
                Text('[${context.t.threadPage.statistics(view: state.viewCount ?? 0, reply: state.replyCount ?? 0)}]'),
              if (state.isDraft) Text('[${context.t.threadPage.draft}]'),
            ].reversed.toList(),
          ),
        ),
      ),
    );
  }

  Future<void> replyPostCallback(User user, int? postFloor, String? replyAction) async {
    if (replyAction == null) {
      return;
    }

    _replyBarController
      ..replyAction = replyAction
      ..setHintText(
        '${context.t.threadPage.sendReplyHint} ${user.name} '
        '${postFloor == null ? "" : "#$postFloor"}',
      )
      ..requestFocus();
  }

  Widget _buildContent(BuildContext context, ThreadState state) {
    final tr = context.t.threadPage;

    return Column(
      children: [
        Expanded(
          child: PostList(
            threadID: state.tid ?? widget.threadID,
            title: state.title ?? widget.title,
            pageNumber: context.read<JumpPageCubit>().state.currentPage,
            initialPostID: widget.findPostID?.parseToInt(),
            scrollController: _listScrollController,
            widgetBuilder: (context, post) => PostCard(post, replyCallback: replyPostCallback),
            useDivider: true,
            postList: state.postList,
            canLoadMore: state.canLoadMore,
            latestModAct: state.latestModAct,
          ),
        ),
        if (state.threadSoftClosed && !state.threadClosed)
          ColoredBox(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: edgeInsetsL12T4R12B4,
              child: Row(
                children: [
                  Icon(Icons.lock_outline, size: 16, color: Theme.of(context).colorScheme.onSecondaryContainer),
                  sizedBoxW4H4,
                  Expanded(
                    child: Text(
                      tr.softCloseHint,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer),
                    ),
                  ),
                ],
              ),
            ),
          ),
        _buildReplyBar(context, state),
      ],
    );
  }

  Widget _buildBody(BuildContext context, ThreadState state) {
    if (state.needLogin) {
      return NeedLoginPage(
        backUri: GoRouterState.of(context).uri,
        needPop: true,
        popCallback: (context) {
          context.read<ThreadBloc>().add(ThreadRefreshRequested());
        },
      );
    } else if (!state.havePermission) {
      if (state.permissionDeniedMessage != null) {
        return ErrorCard(child: munchElement(context, state.permissionDeniedMessage!));
      } else {
        return Center(child: Text(context.t.general.noPermission));
      }
    }

    return switch (state.status) {
      ThreadStatus.initial || ThreadStatus.loading => const Center(child: CircularProgressIndicator()),
      ThreadStatus.failure => buildRetryButton(context, () {
        context.read<ThreadBloc>().add(ThreadLoadMoreRequested(state.currentPage));
      }),
      ThreadStatus.success => _buildContent(context, state),
    };
  }

  Widget _buildReplyBar(BuildContext context, ThreadState state) {
    if (state.postList.isEmpty) {
      return const SizedBox.shrink();
    }
    return ReplyBar(
      controller: _replyBarController,
      replyType: ReplyTypes.thread,
      fullScreen: isDesktop,
      disabledEditorFeatures: defaultEditorDisabledFeatures,
      fullScreenDisabledEditorFeatures: defaultFullScreenDisabledEditorFeatures,
    );
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final threadReverseOrder = getIt.get<SettingsRepository>().currentSettings.threadReverseOrder;

    return MultiBlocProvider(
      providers: [
        RepositoryProvider<ThreadRepository>(create: (_) => ThreadRepository()),
        RepositoryProvider<ReplyRepository>(create: (_) => const ReplyRepository()),
        BlocProvider(
          create: (context) => ThreadBloc(
            tid: widget.threadID,
            pid: widget.findPostID,
            onlyVisibleUid: widget.onlyVisibleUid,
            threadRepository: context.repo(),
            reverseOrder: widget.overrideReverseOrder ? threadReverseOrder : null,
            exactOrder: widget.overrideWithExactOrder,
          )..add(ThreadLoadMoreRequested(int.tryParse(widget.pageNumber) ?? 1)),
        ),
        BlocProvider(create: (context) => ReplyBloc(replyRepository: context.repo())),
        BlocProvider(create: (context) => JumpPageCubit()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<ThreadBloc, ThreadState>(
            listener: (context, state) {
              // Update reply parameters to reply bar.
              context.read<ReplyBloc>().add(ReplyParametersUpdated(state.replyParameters));

              // Update thread closed state to reply bar.
              if (state.threadClosed) {
                context.read<ReplyBloc>().add(const ReplyThreadClosed(closed: true));
              } else {
                context.read<ReplyBloc>().add(const ReplyThreadClosed(closed: false));
              }

              if (state.status == ThreadStatus.success) {
                // Record thread visit history.
                final currentUser = context.read<AuthenticationRepository>().currentUser;
                if (currentUser == null) {
                  // Do nothing if not logged in.
                  return;
                }
                final uid = currentUser.uid;
                final username = currentUser.username;
                if (uid == null || username == null) {
                  unreachable(
                    'intend to record thread visit history but '
                    'user info is incomplete: uid=$uid, username=$username',
                  );
                  return;
                }
                if (state.tid == null || state.title == null || state.fid == null || state.forumName == null) {
                  info('not prepared to save visit history yet');
                  return;
                }
                debug('save thread visit history tid=${state.tid}');
                context.read<ThreadVisitHistoryBloc>().add(
                  ThreadVisitHistoryUpdateRequested(
                    ThreadVisitHistoryModel(
                      uid: uid,
                      threadId: int.parse(state.tid!),
                      forumId: state.fid!,
                      username: username,
                      threadTitle: state.title!,
                      forumName: state.forumName!,
                      visitTime: DateTime.now(),
                    ),
                  ),
                );
              }
            },
          ),
          BlocListener<ReplyBloc, ReplyState>(
            listenWhen: (prev, curr) => prev.status != curr.status,
            listener: (context, state) {
              if (state.status == ReplyStatus.success) {
                showSnackBar(context: context, message: context.t.threadPage.replySuccess);
                // Close the reply bar when sent success.
                if (_replyBarController.showingEditor) {
                  context.pop();
                }
              }
            },
          ),
        ],
        child: BlocBuilder<ThreadBloc, ThreadState>(
          builder: (context, state) {
            // Update jump page state.
            context.read<JumpPageCubit>().setPageInfo(totalPages: state.totalPages, currentPage: state.currentPage);

            final title = widget.title ?? state.title;
            // Reset jump page state when every build.
            if (state.status == ThreadStatus.loading || state.status == ThreadStatus.initial) {
              context.read<JumpPageCubit>().markLoading();
            } else {
              context.read<JumpPageCubit>().markSuccess();
            }

            var threadUrl = RepositoryProvider.of<ThreadRepository>(context).threadUrl;
            if (widget.threadID != null) {
              threadUrl ??=
                  '$baseUrl/forum.php?mod=viewthread&'
                  'tid=${widget.threadID}&extra=page%3D1';
            } else {
              // Here we don;t have threadID, thus the findPostID is
              // definitely not null.
              threadUrl ??=
                  '$baseUrl/forum.php?mode=redirect&goto=findpost&'
                  'pid=${widget.findPostID}';
            }

            return Scaffold(
              // Required by chat_bottom_container in the reply bar.
              resizeToAvoidBottomInset: false,
              body: ExtendedNestedScrollView(
                controller: _listScrollController,
                onlyOneScrollInBody: true,
                headerSliverBuilder: (context, innerBoxIsScroller) => [
                  ListAppBar(
                    title: title,
                    bottom: PreferredSize(preferredSize: const Size.fromHeight(20), child: _buildBreadcrumbsRow(state)),
                    showReverseOrderAction: true,
                    onSearch: () async {
                      await context.pushNamed(ScreenPaths.search);
                    },
                    onJumpPage: (pageNumber) async {
                      if (!mounted) {
                        return;
                      }
                      // Mark loading here.
                      // Mark state will be removed when loading finishes
                      // in next build.
                      context.read<JumpPageCubit>().markLoading();
                      context.read<ThreadBloc>().add(ThreadJumpPageRequested(pageNumber));
                    },
                    onSelected: (value) async {
                      switch (value) {
                        case MenuActions.refresh:
                          context.read<ThreadBloc>().add(ThreadRefreshRequested());
                        case MenuActions.copyUrl:
                          await copyToClipboard(context, threadUrl!);
                        case MenuActions.openInBrowser:
                          await context.dispatchAsUrl(threadUrl!, external: true);
                        case MenuActions.backToTop:
                          await _listScrollController.animateTo(
                            0,
                            curve: Curves.ease,
                            duration: const Duration(milliseconds: 500),
                          );
                        case MenuActions.reverseOrder:
                          context.readOrNull<ThreadBloc>()?.add(const ThreadChangeViewOrderRequested());
                        case MenuActions.openSettings:
                          await context.pushNamed(ScreenPaths.rootSettings);
                        case MenuActions.debugViewLog:
                          await context.pushNamed(ScreenPaths.debugLog);
                      }
                    },
                  ),
                ],
                body: _buildBody(context, state),
              ),
            );
          },
        ),
      ),
    );
  }
}
