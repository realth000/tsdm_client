import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/features/forum/bloc/forum_bloc.dart';
import 'package:tsdm_client/features/forum/repository/forum_repository.dart';
import 'package:tsdm_client/features/jump_page/cubit/jump_page_cubit.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/models/forum.dart';
import 'package:tsdm_client/shared/models/normal_thread.dart';
import 'package:tsdm_client/shared/models/stick_thread.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/utils/retry_snackbar_button.dart';
import 'package:tsdm_client/utils/show_toast.dart';
import 'package:tsdm_client/widgets/card/forum_card.dart';
import 'package:tsdm_client/widgets/card/thread_card.dart';
import 'package:tsdm_client/widgets/list_app_bar.dart';

const _pinnedTabIndex = 0;
const _threadTabIndex = 1;
const _subredditTabIndex = 2;

class ForumPage extends StatefulWidget {
  const ForumPage({required this.fid, this.title, super.key})
      : forumUrl = '$baseUrl/forum.php?mod=forumdisplay&fid=$fid';

  /// Forum ID.
  final String fid;
  final String? title;

  /// The url is used to provide features like "open in external browser".
  final String forumUrl;

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage>
    with SingleTickerProviderStateMixin {
  /// Controller of thread tab.
  final _listScrollController = ScrollController();

  /// Controller of the [EasyRefresh] in thread tab.
  final _refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  /// Controller of current tab: thread, subreddit.
  TabController? tabController;

  Widget _buildStickThreadTab(
      BuildContext context, List<StickThread> stickThreadList) {
    if (stickThreadList.isEmpty) {
      return Center(child: Text(context.t.forumPage.stickThreadTab.noThread));
    }

    return ListView.separated(
      padding: edgeInsetsL10T5R10B20,
      itemCount: stickThreadList.length,
      itemBuilder: (context, index) => NormalThreadCard(stickThreadList[index]),
      separatorBuilder: (context, index) => sizedBoxW5H5,
    );
  }

  Widget _buildNormalThreadTab(
    BuildContext context,
    List<NormalThread> normalThreadList,
    ForumState state,
  ) {
    // Use _haveNoThread to ensure we parsed the web page and there really
    // no thread in the forum.
    if (normalThreadList.isEmpty) {
      return Center(
        child: Text(
          context.t.forumPage.threadTab.noThread,
          style: Theme.of(context).inputDecorationTheme.hintStyle,
        ),
      );
    }

    _refreshController.finishLoad();

    return EasyRefresh(
      scrollBehaviorBuilder: (physics) => ERScrollBehavior(physics)
          .copyWith(physics: physics, scrollbars: false),
      header: const MaterialHeader(position: IndicatorPosition.locator),
      footer: const MaterialFooter(),
      controller: _refreshController,
      scrollController: _listScrollController,
      onRefresh: () async {
        if (!mounted) {
          return;
        }
        context.read<ForumBloc>().add(ForumRefreshRequested());
        _refreshController
          ..finishRefresh()
          ..resetFooter();
      },
      onLoad: () async {
        if (!mounted) {
          return;
        }
        if (state.currentPage >= state.totalPages) {
          debug('already in last page');
          _refreshController.finishLoad(IndicatorResult.noMore);
          await showNoMoreToast(context);
          return;
        }
        // Load the next page.
        context
            .read<ForumBloc>()
            .add(ForumLoadMoreRequested(state.currentPage + 1));
        // _refreshController.finishLoad();
      },
      child: CustomScrollView(
        controller: _listScrollController,
        slivers: [
          const HeaderLocator.sliver(),
          if (normalThreadList.isNotEmpty)
            SliverPadding(
              padding: edgeInsetsL10T5R10B20,
              sliver: SliverList.separated(
                itemCount: normalThreadList.length,
                itemBuilder: (context, index) =>
                    NormalThreadCard(normalThreadList[index]),
                separatorBuilder: (context, index) => sizedBoxW5H5,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ForumState state) {
    return switch (state.status) {
      ForumStatus.initial ||
      ForumStatus.loading =>
        const Center(child: CircularProgressIndicator()),
      ForumStatus.failed => buildRetrySnackbarButton(context, () {
          context
              .read<ForumBloc>()
              .add(ForumLoadMoreRequested(state.currentPage));
        }),
      ForumStatus.success => TabBarView(
          controller: tabController,
          children: [
            _buildStickThreadTab(context, state.stickThreadList),
            _buildNormalThreadTab(context, state.normalThreadList, state),
            _buildSubredditTab(context, state.subredditList),
          ],
        ),
    };
  }

  Widget _buildSubredditTab(BuildContext context, List<Forum> subredditList) {
    if (subredditList.isEmpty) {
      return Center(child: Text(context.t.forumPage.subredditTab.noSubreddit));
    }

    return ListView.separated(
      padding: edgeInsetsL10T5R10B20,
      itemCount: subredditList.length,
      itemBuilder: (context, index) => ForumCard(subredditList[index]),
      separatorBuilder: (context, index) => sizedBoxW5H5,
    );
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    tabController ??= TabController(
      initialIndex: _threadTabIndex,
      length: 3,
      vsync: this,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ForumBloc(
            fid: widget.fid,
            forumRepository: RepositoryProvider.of<ForumRepository>(context),
          )..add(const ForumLoadMoreRequested(1)),
        ),
        BlocProvider(create: (context) => JumpPageCubit()),
      ],
      child: BlocBuilder<ForumBloc, ForumState>(
        builder: (context, state) {
          if (state.status == ForumStatus.success &&
              state.normalThreadList.isEmpty) {
            tabController?.animateTo(
              _subredditTabIndex,
              duration: const Duration(milliseconds: 500),
            );
          }
          // Update jump page state.
          context.read<JumpPageCubit>().setPageInfo(
                currentPage: state.currentPage,
                totalPages: state.totalPages,
              );

          // Reset jump page state when every build.
          if (state.status != ForumStatus.loading) {
            context.read<JumpPageCubit>().markSuccess();
          }

          return Scaffold(
            appBar: ListAppBar(
              title: widget.title,
              bottom: state.permissionDeniedMessage == null
                  ? TabBar(
                      controller: tabController,
                      tabs: [
                        Tab(
                            child:
                                Text(context.t.forumPage.stickThreadTab.title)),
                        Tab(child: Text(context.t.forumPage.threadTab.title)),
                        Tab(
                            child:
                                Text(context.t.forumPage.subredditTab.title)),
                      ],
                    )
                  : null,
              onSearch: () async {
                await context.pushNamed(ScreenPaths.search,
                    queryParameters: {'fid': widget.fid});
              },
              onJumpPage: (pageNumber) async {
                if (!mounted) {
                  return;
                }
                // Mark loading here.
                // Mark state will be removed when loading finishes (next build).
                context.read<JumpPageCubit>().markLoading();
                context
                    .read<ForumBloc>()
                    .add(ForumJumpPageRequested(pageNumber));
              },
              onSelected: (value) async {
                switch (value) {
                  case MenuActions.refresh:
                    await _listScrollController.animateTo(
                      0,
                      curve: Curves.ease,
                      duration: const Duration(milliseconds: 500),
                    );
                    Future.delayed(const Duration(milliseconds: 100), () async {
                      await _refreshController.callRefresh(
                        scrollController: _listScrollController,
                      );
                    });
                  case MenuActions.copyUrl:
                    await Clipboard.setData(
                      ClipboardData(text: widget.forumUrl),
                    );
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        context.t.aboutPage.copiedToClipboard,
                      ),
                    ));
                  case MenuActions.openInBrowser:
                    await context.dispatchAsUrl(widget.forumUrl,
                        external: true);
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
    );
  }
}
