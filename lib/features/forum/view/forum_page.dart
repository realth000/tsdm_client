import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/features/forum/bloc/forum_bloc.dart';
import 'package:tsdm_client/features/forum/models/models.dart';
import 'package:tsdm_client/features/forum/repository/forum_repository.dart';
import 'package:tsdm_client/features/forum/widgets/thread_filter_chip.dart';
import 'package:tsdm_client/features/jump_page/cubit/jump_page_cubit.dart';
import 'package:tsdm_client/features/need_login/view/need_login_page.dart';
import 'package:tsdm_client/features/post/models/models.dart';
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
import 'package:tsdm_client/widgets/indicator.dart';
import 'package:tsdm_client/widgets/list_app_bar/list_app_bar.dart';

const _tabsCount = 3;
const _pinnedTabIndex = 0;
const _threadTabIndex = 1;
const _subredditTabIndex = 2;

const _backToTopCurve = Curves.ease;
const _backToTopAnimationDuration = duration500;

/// Page to show all forum status.
class ForumPage extends StatefulWidget {
  /// Constructor.
  const ForumPage({required this.fid, this.title, this.threadType, super.key})
    : forumUrl = '$baseUrl/forum.php?mod=forumdisplay&fid=$fid';

  /// Forum ID.
  final String fid;

  /// Forum title.
  final String? title;

  /// The url is used to provide features like "open in external browser".
  final String forumUrl;

  /// Optional thread type filter.
  ///
  /// The opened page will apply a "filter=typeid&typeid=$threadType" filter on the page.
  final FilterType? threadType;

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> with SingleTickerProviderStateMixin, LoggerMixin {
  final _pinnedScrollController = ScrollController();
  final _pinnedRefreshController = EasyRefreshController(controlFinishRefresh: true);

  final _subredditScrollController = ScrollController();
  final _subredditRefreshController = EasyRefreshController(controlFinishRefresh: true);

  /// Controller of thread tab.
  final _threadScrollController = ScrollController();

  /// Controller of the [EasyRefresh] in thread tab.
  final _threadRefreshController = EasyRefreshController(controlFinishRefresh: true, controlFinishLoad: true);

  /// Controller of current tab: thread, subreddit.
  late TabController tabController;

  /// Visibility of FAB.
  bool _fabVisible = true;

  void _updateFabVisibilityByTabIndex() {
    if (tabController.index == _threadTabIndex) {
      setState(() {
        _fabVisible = true;
      });
    } else {
      setState(() {
        _fabVisible = false;
      });
    }
  }

  PreferredSizeWidget _buildListAppBar(BuildContext context, ForumState state) {
    return ListAppBar(
      title: widget.title ?? state.title,
      bottom: state.permissionDeniedMessage == null
          ? TabBar(
              controller: tabController,
              tabs: [
                Tab(child: Text(context.t.forumPage.stickThreadTab.title)),
                Tab(child: Text(context.t.forumPage.threadTab.title)),
                Tab(child: Text(context.t.forumPage.subredditTab.title)),
              ],
              onTap: (index) {
                // Here we want to scroll the current tab to the top.
                // Only scroll to top when user taps on the current
                // tab, which means index is not changing.
                if (tabController.indexIsChanging) {
                  // Do nothing because user tapped another index
                  // and want to switch to it.
                  return;
                }
                const duration = Duration(milliseconds: 300);
                const curve = Curves.ease;
                switch (tabController.index) {
                  case _pinnedTabIndex:
                    if (_pinnedScrollController.hasClients) {
                      _pinnedScrollController.animateTo(0, duration: duration, curve: curve);
                    }
                  case _threadTabIndex:
                    if (_threadScrollController.hasClients) {
                      _threadScrollController.animateTo(0, duration: duration, curve: curve);
                    }
                  case _subredditTabIndex:
                    if (_subredditScrollController.hasClients) {
                      _subredditScrollController.animateTo(0, duration: duration, curve: curve);
                    }
                }
              },
            )
          : null,
      onSearch: () async => context.pushNamed(ScreenPaths.search, queryParameters: {'fid': widget.fid}),
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
      onRefresh: () async => switch (tabController.index) {
        _pinnedTabIndex => await _pinnedRefreshController.callRefresh(),
        _threadTabIndex => await _threadRefreshController.callRefresh(),
        _subredditTabIndex => await _subredditRefreshController.callRefresh(),
        _ => context.mounted ? context.read<ForumBloc>().add(ForumRefreshRequested()) : null,
      },
      onCopyUrl: () async => copyToClipboard(context, widget.forumUrl),
      onOpenInBrowser: () async => context.dispatchAsUrl(widget.forumUrl, external: true),
      onBackToTop: () async => await switch (tabController.index) {
        _pinnedTabIndex when _pinnedScrollController.hasClients => _pinnedScrollController,
        _threadTabIndex when _threadScrollController.hasClients => _threadScrollController,
        _subredditTabIndex when _subredditScrollController.hasClients => _subredditScrollController,
        _ => null,
      }?.animateTo(0, curve: _backToTopCurve, duration: _backToTopAnimationDuration),
      customMenuItems: [
        MenuCustomItem(
          icon: Icons.numbers_outlined,
          description: context.t.forumPage.copyFid(fid: widget.fid),
          onSelected: () async => copyToClipboard(context, widget.fid),
        ),
      ],
    );
  }

  Widget _buildNormalThreadFilterRow(BuildContext context, ForumState state) {
    return Row(
      children: [
        Expanded(
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            height: 40,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (state.filterTypeList.isNotEmpty) const ThreadTypeChip(),
                  if (state.filterSpecialTypeList.isNotEmpty) const ThreadSpecialTypeChip(),
                  if (state.filterDatelineList.isNotEmpty) const ThreadDatelineChip(),
                  if (state.filterOrderList.isNotEmpty) const ThreadOrderChip(),
                  const ThreadDigestChip(),
                  const ThreadRecommendedChip(),
                ].prepend(sizedBoxW4H4).insertBetween(sizedBoxW12H12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStickThreadTab(BuildContext context, ForumState state) {
    if (state.stickThreadList.isEmpty && state.rulesElement == null) {
      return Center(child: Text(context.t.forumPage.stickThreadTab.noThread));
    }
    late final Widget content;
    if (state.rulesElement == null) {
      content = ListView.separated(
        controller: _pinnedScrollController,
        padding: edgeInsetsL12T4R12,
        itemCount: state.stickThreadList.length,
        itemBuilder: (context, index) => NormalThreadCard(state.stickThreadList[index]),
        separatorBuilder: (context, index) => sizedBoxW4H4,
      );
    } else {
      content = ListView.separated(
        controller: _pinnedScrollController,
        padding: edgeInsetsL12T4R12.add(context.safePadding()),
        itemCount: state.stickThreadList.length + 1,
        itemBuilder: (context, index) {
          // TODO: Do NOT add leading rules card by checking index value.
          if (index == 0) {
            return Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: munchElement(context, state.rulesElement!),
            );
          } else {
            return NormalThreadCard(state.stickThreadList[index - 1]);
          }
        },
        separatorBuilder: (context, index) => sizedBoxW4H4,
      );
    }

    return EasyRefresh(
      scrollBehaviorBuilder: (physics) => ERScrollBehavior(physics).copyWith(physics: physics, scrollbars: false),
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

  Widget _buildNormalThreadTab(BuildContext context, List<NormalThread> normalThreadList, ForumState state) {
    // Use _haveNoThread to ensure we parsed the web page and there really
    // no thread in the forum.
    if (normalThreadList.isEmpty) {
      final emptyContentHint = Center(
        child: Text(context.t.forumPage.threadTab.noThread, style: Theme.of(context).inputDecorationTheme.hintStyle),
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
      scrollBehaviorBuilder: (physics) => ERScrollBehavior(physics).copyWith(physics: physics, scrollbars: false),
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
        context.read<ForumBloc>().add(ForumLoadMoreRequested(state.currentPage + 1));
        // _refreshController.finishLoad();
      },
      childBuilder: (context, physics) => CustomScrollView(
        controller: _threadScrollController,
        physics: physics,
        slivers: [
          PinnedHeaderSliver(child: _buildNormalThreadFilterRow(context, state)),
          const SliverPadding(padding: edgeInsetsL12T4R12),
          SliverList.separated(
            itemCount: normalThreadList.length,
            itemBuilder: (context, index) =>
                Padding(padding: edgeInsetsL12R12, child: NormalThreadCard(normalThreadList[index])),
            separatorBuilder: (context, index) => sizedBoxW4H4,
          ),
          SliverPadding(padding: context.safePadding()),
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
        return ErrorCard(child: munchElement(context, state.permissionDeniedMessage!));
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
          if (state.filterState.isFiltering()) _buildNormalThreadFilterRow(context, state),
          const Expanded(child: CenteredCircularIndicator()),
        ],
      ),
      ForumStatus.failure => buildRetryButton(context, () {
        context.read<ForumBloc>().add(ForumLoadMoreRequested(state.currentPage));
      }),
      ForumStatus.success => _buildSuccessContent(context, state),
    };
  }

  Widget _buildSubredditTab(BuildContext context, List<Forum> subredditList) {
    if (subredditList.isEmpty) {
      return Center(child: Text(context.t.forumPage.subredditTab.noSubreddit));
    }

    return EasyRefresh(
      scrollBehaviorBuilder: (physics) => ERScrollBehavior(physics).copyWith(physics: physics, scrollbars: false),
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
        padding: edgeInsetsL12T4R12.add(context.safePadding()),
        itemCount: subredditList.length,
        itemBuilder: (context, index) => ForumCard(subredditList[index]),
        separatorBuilder: (context, index) => sizedBoxW4H4,
      ),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context, ForumState state) {
    if (state.status != ForumStatus.success || !_fabVisible) {
      return null;
    }

    return FloatingActionButton(
      onPressed: () async => context.pushNamed(
        ScreenPaths.editPost,
        pathParameters: {'editType': '${PostEditType.newThread.index}', 'fid': widget.fid},
      ),
      tooltip: context.t.forumPage.tooltip.fab,
      child: const Icon(Icons.add_outlined),
    );
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(initialIndex: _threadTabIndex, length: _tabsCount, vsync: this)
      ..addListener(_updateFabVisibilityByTabIndex);
  }

  bool _onBodyScrollNotification(UserScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) {
      return false;
    }

    // Update fab visibility according to scroll direction.
    if (notification.direction == ScrollDirection.forward && !_fabVisible) {
      setState(() {
        _fabVisible = true;
      });
    } else if (notification.direction == ScrollDirection.reverse && _fabVisible) {
      setState(() {
        _fabVisible = false;
      });
    }
    return true;
  }

  @override
  void dispose() {
    _pinnedScrollController.dispose();
    _pinnedRefreshController.dispose();
    _threadScrollController.dispose();
    _threadRefreshController.dispose();
    _subredditScrollController.dispose();
    _subredditRefreshController.dispose();
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final FilterState? filterState;
            if (widget.threadType != null) {
              filterState = FilterState(
                filter: 'typeid',
                filterType: FilterType(
                  // Name now only used in ThreadChip to show available filters, fine to keep empty here.
                  name: widget.threadType!.name,
                  typeID: widget.threadType!.typeID,
                ),
              );
            } else {
              filterState = null;
            }

            return ForumBloc(
              fid: widget.fid,
              forumRepository: RepositoryProvider.of<ForumRepository>(context),
              filterState: filterState,
            )..add(const ForumLoadMoreRequested(1));
          },
        ),
        BlocProvider(create: (context) => JumpPageCubit()),
      ],
      child: BlocBuilder<ForumBloc, ForumState>(
        builder: (context, state) {
          if (state.status == ForumStatus.success &&
              state.normalThreadList.isEmpty &&
              // Do not switch tab if filtering but filtering non result left.
              !state.filterState.isFiltering()) {
            tabController.animateTo(_subredditTabIndex, duration: const Duration(milliseconds: 500));
          }
          // Update jump page state.
          context.read<JumpPageCubit>().setPageInfo(currentPage: state.currentPage, totalPages: state.totalPages);

          // Reset jump page state when every build.
          if (state.status == ForumStatus.initial || state.status == ForumStatus.loading) {
            context.read<JumpPageCubit>().markLoading();
          } else {
            context.read<JumpPageCubit>().markSuccess();
          }

          return Scaffold(
            // appBar: PreferredSize(preferredSize: const Size.fromHeight(145), child: _buildListAppBar(context, state)),
            appBar: _buildListAppBar(context, state),
            body: NotificationListener<UserScrollNotification>(
              onNotification: _onBodyScrollNotification,
              child: SafeArea(bottom: false, child: _buildBody(context, state)),
            ),
            floatingActionButton: _buildFloatingActionButton(context, state),
          );
        },
      ),
    );
  }
}
