import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/features/jump_page/cubit/jump_page_cubit.dart';
import 'package:tsdm_client/features/thread/bloc/thread_bloc.dart';
import 'package:tsdm_client/features/thread/repository/thread_repository.dart';
import 'package:tsdm_client/features/thread/widgets/post_list.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/models/user.dart';
import 'package:tsdm_client/utils/retry_snackbar_button.dart';
import 'package:tsdm_client/widgets/card/post_card.dart';
import 'package:tsdm_client/widgets/list_app_bar.dart';
import 'package:tsdm_client/widgets/reply_bar/bloc/reply_bloc.dart';
import 'package:tsdm_client/widgets/reply_bar/reply_bar.dart';
import 'package:tsdm_client/widgets/reply_bar/repository/reply_repository.dart';

class ThreadPage extends StatefulWidget {
  const ThreadPage({
    required this.threadID,
    required this.pageNumber,
    this.title,
    this.threadType,
    super.key,
  });

  /// Thread ID, tid.
  final String threadID;

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
      User user, int? postFloor, String? replyAction) async {
    if (replyAction == null) {
      return;
    }

    _replyBarController
      ..replyAction = replyAction
      ..setHintText(
          '${context.t.threadPage.sendReplyHint} ${user.name} ${postFloor == null ? "" : "#$postFloor"}')
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
            title: widget.title ?? '',
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
          ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, ThreadState state) {
    return switch (state.status) {
      ThreadStatus.initial ||
      ThreadStatus.loading =>
        const Center(child: CircularProgressIndicator()),
      ThreadStatus.failed => buildRetrySnackbarButton(context, () {
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
          create: (_) => ReplyRepository(),
        ),
        BlocProvider(
          create: (context) => ThreadBloc(
            tid: widget.threadID,
            threadRepository: RepositoryProvider.of(context),
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
      child: BlocListener<ThreadBloc, ThreadState>(
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
        },
        child: BlocBuilder<ThreadBloc, ThreadState>(
          builder: (context, state) {
            // Update jump page state.
            context.read<JumpPageCubit>().setPageInfo(
                  currentPage: state.currentPage,
                  totalPages: state.totalPages,
                );

            // Reset jump page state when every build.
            if (state.status != ThreadStatus.loading) {
              context.read<JumpPageCubit>().markSuccess();
            }

            final threadUrl = RepositoryProvider.of<ThreadRepository>(context)
                    .threadUrl ??
                '$baseUrl/forum.php?mod=viewthread&tid=${widget.threadID}&extra=page%3D1';

            return Scaffold(
              appBar: ListAppBar(
                title: widget.title,
                onSearch: () async {
                  await context.pushNamed(ScreenPaths.search);
                },
                onJumpPage: (pageNumber) async {
                  if (!mounted) {
                    return;
                  }
                  // Mark loading here.
                  // Mark state will be removed when loading finishes (next build).
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
                      await Clipboard.setData(ClipboardData(text: threadUrl));
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          context.t.aboutPage.copiedToClipboard,
                        ),
                      ));
                    case MenuActions.openInBrowser:
                      await context.dispatchAsUrl(threadUrl, external: true);
                    case MenuActions.backToTop:
                      await _listScrollController.animateTo(
                        0,
                        curve: Curves.ease,
                        duration: const Duration(milliseconds: 500),
                      );
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
