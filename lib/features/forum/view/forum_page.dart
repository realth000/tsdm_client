import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/features/forum/bloc/forum_bloc.dart';
import 'package:tsdm_client/features/forum/repository/forum_repository.dart';
import 'package:tsdm_client/features/forum/widgets/thread_filter_chip.dart';
import 'package:tsdm_client/features/jump_page/cubit/jump_page_cubit.dart';
import 'package:tsdm_client/features/need_login/view/need_login_page.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/utils/clipboard.dart';
import 'package:tsdm_client/utils/html/html_muncher.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/utils/retry_button.dart';
import 'package:tsdm_client/utils/show_toast.dart';
import 'package:tsdm_client/widgets/card/error_card.dart';
import 'package:tsdm_client/widgets/card/forum_card.dart';
import 'package:tsdm_client/widgets/card/thread_card/thread_card.dart';
import 'package:tsdm_client/widgets/list_app_bar.dart';

const _tabsCount = 3;
const _pinnedTabIndex = 0;
const _threadTabIndex = 1;
const _subredditTabIndex = 2;

/// Page to show all forum status.
class ForumPage extends StatefulWidget {
  /// Constructor.
  const ForumPage({required this.fid, this.title, super.key})
      : forumUrl = '$baseUrl/forum.php?mod=forumdisplay&fid=$fid';

  /// Forum ID.
  final String fid;

  /// Forum title.
  final String? title;

  /// The url is used to provide features like "open in external browser".
  final String forumUrl;

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage>
    with SingleTickerProviderStateMixin, LoggerMixin {
  final _pinnedScrollController = ScrollController();
  final _pinnedRefreshController =
      EasyRefreshController(controlFinishRefresh: true);
  final _subredditScrollController = ScrollController();
  final _subredditRefreshController =
      EasyRefreshController(controlFinishRefresh: true);

  /// Controller of thread tab.
  final _threadScrollController = ScrollController();

  /// Controller of the [EasyRefresh] in thread tab.
  final _threadRefreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  /// Controller of current tab: thread, subreddit.
  TabController? tabController;

  PreferredSizeWidget _buildListAppBar(BuildContext context, ForumState state) {
    return ListAppBar(
      title: widget.title ?? state.title,
      bottom: state.permissionDeniedMessage == null
          ? TabBar(
              controller: tabController,
              tabs: [
                Tab(
                  child: Text(
                    context.t.forumPage.stickThreadTab.title,
                  ),
                ),
                Tab(child: Text(context.t.forumPage.threadTab.title)),
                Tab(
                  child: Text(
                    context.t.forumPage.subredditTab.title,
                  ),
                ),
              ],
              onTap: (index) {
                // Here we want to scroll the current tab to the top.
                // Only scroll to top when user taps on the current
                // tab, which means index is not changing.
                if (tabController?.indexIsChanging ?? true) {
                  // Do nothing because user tapped another index
                  // and want to switch to it.
                  return;
                }
                const duration = Duration(milliseconds: 300);
                const curve = Curves.ease;
                switch (tabController!.index) {
                  case _pinnedTabIndex:
                    _pinnedScrollController.animateTo(
                      0,
                      duration: duration,
                      curve: curve,
                    );
                  case _threadTabIndex:
                    _threadScrollController.animateTo(
                      0,
                      duration: duration,
                      curve: curve,
                    );
                  case _subredditTabIndex:
                    _subredditScrollController.animateTo(
                      0,
                      duration: duration,
                      curve: curve,
                    );
                }
              },
            )
          : null,
      onSearch: () async {
        await context.pushNamed(
          ScreenPaths.search,
          queryParameters: {'fid': widget.fid},
        );
      },
      onJumpPage: (pageNumber) async {
        if (!mounted) {
          return;
        }
        // Mark loading here.
        // Mark state will be removed when
        // loading finishes (next build).
        context.read<JumpPageCubit>().markLoading();
        context.read<ForumBloc>().add(ForumJumpPageRequested(pageNumber));
      },
      onSelected: (value) async {
        switch (value) {
          case MenuActions.refresh:
            if (tabController == null) {
              context.read<ForumBloc>().add(ForumRefreshRequested());
              return;
            }
            switch (tabController!.index) {
              case _pinnedTabIndex:
                await _pinnedRefreshController.callRefresh();
              case _threadTabIndex:
                await _threadRefreshController.callRefresh();
              case _subredditTabIndex:
                await _subredditRefreshController.callRefresh();
              default:
                context.read<ForumBloc>().add(ForumRefreshRequested());
            }
          case MenuActions.copyUrl:
            await copyToClipboard(context, widget.forumUrl);
          case MenuActions.openInBrowser:
            await context.dispatchAsUrl(
              widget.forumUrl,
              external: true,
            );
          case MenuActions.backToTop:
            await _threadScrollController.animateTo(
              0,
              curve: Curves.ease,
              duration: const Duration(milliseconds: 500),
            );
          case MenuActions.reverseOrder:
            ;
        }
      },
    );
  }

  Widget _buildNormalThreadFilterRow(BuildContext context, ForumState state) {
    return Padding(
      padding: edgeInsetsT4B4,
      child: SizedBox(
        height: 40,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const ThreadTypeChip(),
              const ThreadSpecialTypeChip(),
              const ThreadDatelineChip(),
              const ThreadOrderChip(),
              const ThreadDigestChip(),
              const ThreadRecommendedChip(),
            ].prepend(sizedBoxW4H4).insertBetween(sizedBoxW12H12),
          ),
        ),
      ),
    );
  }

  Widget _buildStickThreadTab(BuildContext context, ForumState state) {
    if (state.stickThreadList.isEmpty) {
      return Center(child: Text(context.t.forumPage.stickThreadTab.noThread));
    }
    late final Widget content;
    if (state.rulesElement == null) {
      content = ListView.separated(
        controller: _pinnedScrollController,
        padding: edgeInsetsL12T4R12B24,
        itemCount: state.stickThreadList.length,
        itemBuilder: (context, index) =>
            NormalThreadCard(state.stickThreadList[index]),
        separatorBuilder: (context, index) => sizedBoxW4H4,
      );
    } else {
      content = ListView.separated(
        controller: _pinnedScrollController,
        padding: edgeInsetsL12T4R12B24,
        itemCount: state.stickThreadList.length + 1,
        itemBuilder: (context, index) {
          // TODO: Do NOT add leading rules card by checking index value.
          if (index == 0) {
            return Card(child: munchElement(context, state.rulesElement!));
          } else {
            return NormalThreadCard(state.stickThreadList[index - 1]);
          }
        },
        separatorBuilder: (context, index) => sizedBoxW4H4,
      );
    }

    return EasyRefresh(
      scrollBehaviorBuilder: (physics) => ERScrollBehavior(physics)
          .copyWith(physics: physics, scrollbars: false),
      header: const MaterialHeader(),
      controller: _pinnedRefreshController,
      scrollController: _pinnedScrollController,
      onRefresh: () async {
        if (!mounted) {
          return;
        }
        context.read<ForumBloc>().add(ForumRefreshRequested());
      },
      child: content,
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
      final emptyContentHint = Center(
        child: Text(
          context.t.forumPage.threadTab.noThread,
          style: Theme.of(context).inputDecorationTheme.hintStyle,
        ),
      );
      if (state.filterState.isFiltering()) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNormalThreadFilterRow(context, state),
            Expanded(child: emptyContentHint),
          ],
        );
      }
      return emptyContentHint;
    }

    _threadRefreshController.finishLoad();

    return EasyRefresh.builder(
      scrollBehaviorBuilder: (physics) => ERScrollBehavior(physics)
          .copyWith(physics: physics, scrollbars: false),
      header: const MaterialHeader(),
      footer: const MaterialFooter(),
      controller: _threadRefreshController,
      scrollController: _threadScrollController,
      onRefresh: () async {
        if (!mounted) {
          return;
        }
        context.read<ForumBloc>().add(ForumRefreshRequested());
      },
      onLoad: () async {
        if (!mounted) {
          return;
        }
        if (state.currentPage >= state.totalPages) {
          info('already in last page');
          _threadRefreshController.finishLoad(IndicatorResult.noMore);
          showNoMoreSnackBar(context);
          return;
        }
        // Load the next page.
        context
            .read<ForumBloc>()
            .add(ForumLoadMoreRequested(state.currentPage + 1));
        // _refreshController.finishLoad();
      },
      childBuilder: (context, physics) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNormalThreadFilterRow(context, state),
          Expanded(
            child: Padding(
              padding: edgeInsetsL12R12,
              child: CustomScrollView(
                controller: _threadScrollController,
                physics: physics,
                slivers: [
                  SliverList.separated(
                    itemCount: normalThreadList.length,
                    itemBuilder: (context, index) =>
                        NormalThreadCard(normalThreadList[index]),
                    separatorBuilder: (context, index) => sizedBoxW4H4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent(BuildContext context, ForumState state) {
    if (state.needLogin) {
      return NeedLoginPage(
        backUri: GoRouterState.of(context).uri,
        needPop: true,
        popCallback: (context) {
          context.read<ForumBloc>().add(ForumRefreshRequested());
        },
      );
    } else if (!state.havePermission) {
      if (state.permissionDeniedMessage != null) {
        return ErrorCard(
          message: context.t.general.noPermission,
          child: munchElement(context, state.permissionDeniedMessage!),
        );
      } else {
        return Center(child: Text(context.t.general.noPermission));
      }
    } else {
      return TabBarView(
        controller: tabController,
        children: [
          _buildStickThreadTab(context, state),
          _buildNormalThreadTab(context, state.normalThreadList, state),
          _buildSubredditTab(context, state.subredditList),
        ],
      );
    }
  }

  Widget _buildBody(BuildContext context, ForumState state) {
    return switch (state.status) {
      ForumStatus.initial || ForumStatus.loading => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.filterState.isFiltering())
              _buildNormalThreadFilterRow(context, state),
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ForumStatus.failure => buildRetryButton(context, () {
          context
              .read<ForumBloc>()
              .add(ForumLoadMoreRequested(state.currentPage));
        }),
      ForumStatus.success => _buildSuccessContent(context, state),
    };
  }

  Widget _buildSubredditTab(BuildContext context, List<Forum> subredditList) {
    if (subredditList.isEmpty) {
      return Center(child: Text(context.t.forumPage.subredditTab.noSubreddit));
    }

    return EasyRefresh(
      scrollBehaviorBuilder: (physics) => ERScrollBehavior(physics)
          .copyWith(physics: physics, scrollbars: false),
      header: const MaterialHeader(),
      controller: _subredditRefreshController,
      scrollController: _subredditScrollController,
      onRefresh: () async {
        if (!mounted) {
          return;
        }
        context.read<ForumBloc>().add(ForumRefreshRequested());
      },
      child: ListView.separated(
        controller: _subredditScrollController,
        padding: edgeInsetsL12T4R12B24,
        itemCount: subredditList.length,
        itemBuilder: (context, index) => ForumCard(subredditList[index]),
        separatorBuilder: (context, index) => sizedBoxW4H4,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      initialIndex: _threadTabIndex,
      length: _tabsCount,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pinnedScrollController.dispose();
    _pinnedRefreshController.dispose();
    _threadScrollController.dispose();
    _threadRefreshController.dispose();
    _subredditScrollController.dispose();
    _subredditRefreshController.dispose();
    tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      child: BlocListener<ForumBloc, ForumState>(
        listener: (context, state) {
          if (state.status == ForumStatus.failure) {
            showFailedToLoadSnackBar(context);
          }
        },
        child: BlocBuilder<ForumBloc, ForumState>(
          builder: (context, state) {
            if (state.status == ForumStatus.success &&
                state.normalThreadList.isEmpty &&
                // Do not switch tab if filtering but filtering non result left.
                !state.filterState.isFiltering()) {
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
            if (state.status == ForumStatus.initial ||
                state.status == ForumStatus.loading) {
              context.read<JumpPageCubit>().markLoading();
            } else {
              context.read<JumpPageCubit>().markSuccess();
            }

            return Scaffold(
              appBar: _buildListAppBar(context, state),
              body: _buildBody(context, state),
            );
          },
        ),
      ),
    );
  }
}
