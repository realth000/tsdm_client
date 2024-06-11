import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/features/jump_page/cubit/jump_page_cubit.dart';
import 'package:tsdm_client/features/need_login/view/need_login_page.dart';
import 'package:tsdm_client/features/thread/bloc/thread_bloc.dart';
import 'package:tsdm_client/features/thread/repository/thread_repository.dart';
import 'package:tsdm_client/features/thread/widgets/post_list.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/packages/html_muncher/lib/html_muncher.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/repositories/settings_repository/settings_repository.dart';
import 'package:tsdm_client/utils/clipboard.dart';
import 'package:tsdm_client/utils/retry_button.dart';
import 'package:tsdm_client/widgets/card/post_card/post_card.dart';
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
    this.title,
    this.threadType,
    super.key,
  }) : assert(
          threadID != null || findPostID != null,
          'MUST provide threadID or findPostID',
        );

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

  /// Thread type.
  ///
  /// Sometimes we do not know the thread type before we load it, redirect from
  /// homepage, for example. So it's a nullable String.
  final String? threadType;

  @override
  State<ThreadPage> createState() => _ThreadPageState();
}

class _ThreadPageState extends State<ThreadPage>
    with SingleTickerProviderStateMixin {
  /// Controller of thread tab.
  final _listScrollController = ScrollController();

  final _replyBarController = ReplyBarController();

  Future<void> replyPostCallback(
    User user,
    int? postFloor,
    String? replyAction,
  ) async {
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
    final pageNumber =
        RepositoryProvider.of<ThreadRepository>(context).pageNumber ??
            int.tryParse(widget.pageNumber) ??
            1;

    return Column(
      children: [
        Expanded(
          child: PostList(
            threadID: widget.threadID,
            title: widget.title ?? state.title,
            threadType: widget.threadType,
            pageNumber: pageNumber,
            scrollController: _listScrollController,
            widgetBuilder: (context, post) => PostCard(
              post,
              replyCallback: replyPostCallback,
            ),
            useDivider: true,
            postList: state.postList,
            canLoadMore: state.canLoadMore,
          ),
        ),
        if (state.postList.isNotEmpty)
          ReplyBar(
            controller: _replyBarController,
            replyType: ReplyTypes.thread,
          ),
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
        return Center(
          child: munchElement(context, state.permissionDeniedMessage!),
        );
      } else {
        return Center(child: Text(context.t.general.noPermission));
      }
    }

    return switch (state.status) {
      ThreadStatus.initial ||
      ThreadStatus.loading =>
        const Center(child: CircularProgressIndicator()),
      ThreadStatus.failed => buildRetryButton(context, () {
          context
              .read<ThreadBloc>()
              .add(ThreadLoadMoreRequested(state.currentPage));
        }),
      ThreadStatus.success => _buildContent(context, state),
    };
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        RepositoryProvider<ThreadRepository>(
          create: (_) => ThreadRepository(),
        ),
        RepositoryProvider<ReplyRepository>(
          create: (_) => const ReplyRepository(),
        ),
        BlocProvider(
          create: (context) => ThreadBloc(
            tid: widget.threadID,
            pid: widget.findPostID,
            threadRepository: RepositoryProvider.of(context),
            reverseOrder: RepositoryProvider.of<SettingsRepository>(context)
                .getThreadReverseOrder(),
          )..add(ThreadLoadMoreRequested(int.tryParse(widget.pageNumber) ?? 1)),
        ),
        BlocProvider(
          create: (context) => ReplyBloc(
            replyRepository: RepositoryProvider.of(context),
          ),
        ),
        BlocProvider(
          create: (context) => JumpPageCubit(),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<ThreadBloc, ThreadState>(
            listener: (context, state) {
              // Update reply parameters to reply bar.
              context
                  .read<ReplyBloc>()
                  .add(ReplyParametersUpdated(state.replyParameters));

              // Update thread closed state to reply bar.
              if (state.threadClosed) {
                context
                    .read<ReplyBloc>()
                    .add(const ReplyThreadClosed(closed: true));
              } else {
                context
                    .read<ReplyBloc>()
                    .add(const ReplyThreadClosed(closed: false));
              }
              if (state.status == ThreadStatus.failed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.t.general.failedToLoad)),
                );
              }
            },
          ),
          BlocListener<ReplyBloc, ReplyState>(
            listenWhen: (prev, curr) => prev.status != curr.status,
            listener: (context, state) {
              if (state.status == ReplyStatus.success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.t.threadPage.replySuccess)),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<ThreadBloc, ThreadState>(
          builder: (context, state) {
            // Update jump page state.
            context.read<JumpPageCubit>().setPageInfo(
                  currentPage: state.currentPage,
                  totalPages: state.totalPages,
                );

            String? title;

            // Reset jump page state when every build.
            if (state.status == ThreadStatus.loading ||
                state.status == ThreadStatus.initial) {
              context.read<JumpPageCubit>().markLoading();
              title = widget.title;
            } else {
              context.read<JumpPageCubit>().markSuccess();
            }

            var threadUrl =
                RepositoryProvider.of<ThreadRepository>(context).threadUrl;
            if (widget.threadID != null) {
              threadUrl ??= '$baseUrl/forum.php?mod=viewthread&'
                  'tid=${widget.threadID}&extra=page%3D1';
            } else {
              // Here we don;t have threadID, thus the findPostID is
              // definitely not null.
              threadUrl ??= '$baseUrl/forum.php?mode=redirect&goto=findpost&'
                  'pid=${widget.findPostID}';
            }

            return Scaffold(
              appBar: ListAppBar(
                title: title,
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
                  context
                      .read<ThreadBloc>()
                      .add(ThreadJumpPageRequested(pageNumber));
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
                      context
                          .readOrNull<ThreadBloc>()
                          ?.add(const ThreadChangeViewOrderRequested());
                  }
                },
              ),
              body: _buildBody(context, state),
            );
          },
        ),
      ),
    );
  }
}
