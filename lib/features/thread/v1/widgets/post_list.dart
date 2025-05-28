import 'dart:core';

import 'package:collection/collection.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/uri.dart';
import 'package:tsdm_client/features/forum/models/models.dart';
import 'package:tsdm_client/features/jump_page/cubit/jump_page_cubit.dart';
import 'package:tsdm_client/features/thread/v1/bloc/thread_bloc.dart';
import 'package:tsdm_client/features/thread/v1/models/models.dart';
import 'package:tsdm_client/features/thread/v1/widgets/operation_log_card.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/utils/show_toast.dart';

/// A widget that retrieve data from network and supports refresh.
class PostList extends StatefulWidget {
  /// Constructor.
  const PostList({
    required this.forumID,
    required this.threadID,
    required this.threadType,
    required this.postList,
    required this.widgetBuilder,
    required this.canLoadMore,
    required this.scrollController,
    required this.isDraft,
    required this.latestModAct,
    this.title,
    this.pageNumber = 1,
    this.useDivider = false,
    this.initialPostID,
    super.key,
  });

  /// Thread title.
  final String? title;

  /// Fetch page number "&page=[pageNumber]".
  final int pageNumber;

  /// Forum ID.
  final int? forumID;

  /// Thread ID.
  final String? threadID;

  /// Thread type.
  ///
  /// When it is null, confirm it from thread page.
  final FilterType? threadType;

  /// Build a list of [Widget].
  final Widget Function(BuildContext, Post) widgetBuilder;

  /// Use [Divider] instead of [SizedBox] between list items.
  final bool useDivider;

  /// List of [Post] content.
  final List<Post> postList;

  /// Flag indicating can load more pages in current post list.
  final bool canLoadMore;

  /// The [ScrollController] passed from outside.
  final ScrollController scrollController;

  /// Optional initial post id.
  ///
  /// Scroll to this post once page built.
  /// Useful in some "find post" situation.
  final int? initialPostID;

  /// Is thread in draft state.
  final bool isDraft;

  /// Latest modification action.
  final String? latestModAct;

  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList> with LoggerMixin {
  /// Thread type name.
  /// Actually this should provided by [NormalThread].
  /// But till now we haven't parse this attr in forum page.
  /// So parse here directly from thread page.
  /// But only parse once because every page shall have the same thread type.
  FilterType? _threadType;

  final _refreshController = EasyRefreshController(controlFinishRefresh: true, controlFinishLoad: true);

  /// [ScrollController] comes from outside.
  ///
  /// Note that this class does NOT own the scroll controller.
  ///
  /// FIXME: How to ensure controller lives longer than the class instance.
  ///
  /// Do NOT dispose it here.
  ///
  // ignore: dispose_controllers
  late ScrollController _listScrollController;

  late ListController _listController;

  /// Current page number
  int pageNumber = 1;

  void _updatePageNumber() {
    final p = _listController.visibleRange?.$1;
    if (p != null) {
      // List forms through separator builder, divide 2 because of the separator
      // widget.
      final p2 = widget.postList[p ~/ 2].page;
      if (p2 != pageNumber) {
        pageNumber = p2;
        //  Current page changes.
        context.read<JumpPageCubit>().setPageInfo(currentPage: p2);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Try use the thread type in widget which comes from routing.
    _threadType = widget.threadType;
    _listScrollController = widget.scrollController;
    _listController = ListController();
    _listController.addListener(_updatePageNumber);

    if (widget.initialPostID != null) {
      // Scroll to post, if any.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debug('scroll to pid: ${widget.initialPostID}');
        var pos = -1;
        final p = '${widget.initialPostID}';
        for (final (index, post) in widget.postList.indexed) {
          if (post.postID == p) {
            pos = index;
            break;
          }
        }
        if (pos < 0) {
          return;
        }
        debug('scroll to position: ${pos * 2}');
        _listController.animateToItem(
          index: pos * 2,
          scrollController: _listScrollController,
          alignment: 0,
          duration: (_) => duration200,
          curve: (_) => Curves.ease,
        );
      });
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _listController
      ..removeListener(_updatePageNumber)
      ..dispose();
    super.dispose();
  }

  Widget _buildHeader(
    BuildContext context,
    List<ThreadBreadcrumb> breadcrumbs,
    double expandHeight,
    int? viewCount,
    int? replyCount,
  ) {
    if (!_listController.isAttached) {
      return sizedBoxEmpty;
    }
    final infoTextStyle = Theme.of(
      context,
    ).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.outline);

    final infoTextHighlightStyle = Theme.of(
      context,
    ).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary);

    if (_listScrollController.offset <= expandHeight) {
      final breadFrags =
          breadcrumbs
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
        padding: edgeInsetsL12T4R12B4,
        child: DefaultTextStyle.merge(
          style: infoTextStyle,
          child: SizedBox(
            height: 20,
            child: ListView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              children:
                  <Widget>[
                    ...breadFrags,
                    if (_threadType?.typeID != null && widget.forumID != null)
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap:
                              () async => context.pushNamed(
                                ScreenPaths.forum,
                                pathParameters: {'fid': '${widget.forumID!}'},
                                queryParameters: {
                                  'threadTypeName': _threadType!.name,
                                  'threadTypeID': '${_threadType!.typeID}',
                                },
                              ),
                          child: Text('[${_threadType!.name}]', style: infoTextHighlightStyle),
                        ),
                      ),
                    Text('[${context.t.threadPage.title} ${widget.threadID ?? ""}]'),
                    if (viewCount != null || replyCount != null)
                      Text('[${context.t.threadPage.statistics(view: viewCount ?? 0, reply: replyCount ?? 0)}]'),
                    if (widget.isDraft) Text('[${context.t.threadPage.draft}]'),
                  ].reversed.toList(),
            ),
          ),
        ),
      );
    }

    // The color to simulate app bar background color.
    // final bg =
    //     _listScrollController.offset >= expandHeight
    //         ? ElevationOverlay.applySurfaceTint(
    //           Theme.of(context).colorScheme.surface,
    //           Theme.of(context).colorScheme.surfaceTint,
    //           Theme.of(context).navigationBarTheme.elevation ?? 3,
    //         )
    //         : Colors.transparent;
    return Padding(
      padding: edgeInsetsL12T4R12B4,
      child: Text(
        _listScrollController.offset > expandHeight ? (widget.title ?? '') : (widget.threadType?.name ?? ''),
        style: Theme.of(context).textTheme.titleMedium,
        maxLines: 1,
      ),
    );
  }

  Widget _buildPostList(BuildContext context) {
    if (widget.postList.isEmpty) {
      return sizedBoxEmpty;
    }

    return SuperSliverList.separated(
      listController: _listController,
      itemCount: widget.postList.length,
      itemBuilder: (context, index) {
        return widget.widgetBuilder(context, widget.postList[index]);
      },
      separatorBuilder: (context, index) => widget.useDivider ? const Divider(thickness: 0.5) : sizedBoxW4H4,
    );
  }

  Widget _buildBody(BuildContext context, ThreadState state) {
    const safeHeight = 40.0;

    _refreshController.finishLoad();

    _threadType ??= state.threadType;
    return EasyRefresh.builder(
      scrollBehaviorBuilder: (physics) {
        // Should use ERScrollBehavior instead of
        // ScrollConfiguration.of(context)
        return ERScrollBehavior(physics).copyWith(physics: physics, scrollbars: false);
      },
      header: const MaterialHeader(position: IndicatorPosition.locator),
      footer: const MaterialFooter(),
      controller: _refreshController,
      scrollController: _listScrollController,
      onRefresh: () async {
        if (!mounted) {
          return;
        }
        context.read<ThreadBloc>().add(ThreadRefreshRequested());
      },
      onLoad: () async {
        if (!mounted) {
          return;
        }
        if (!widget.canLoadMore) {
          showNoMoreSnackBar(context);
          _refreshController.finishLoad();
          return;
        }
        context.read<ThreadBloc>().add(ThreadLoadMoreRequested(context.read<JumpPageCubit>().state.currentPage + 1));
      },
      childBuilder: (context, physics) {
        return CustomScrollView(
          physics: physics,
          controller: _listScrollController,
          slivers: [
            const HeaderLocator.sliver(),
            SliverPersistentHeader(
              floating: true,
              delegate: SliverAppBarPersistentDelegate(
                buildHeader: (context, shrinkOffset, {required bool overlapsContent}) {
                  return AppBar(
                    titleSpacing: 0,
                    automaticallyImplyLeading: false,
                    primary: false,
                    title: _buildHeader(context, state.breadcrumbs, safeHeight, state.viewCount, state.replyCount),
                  );
                },
                headerMaxExtent: safeHeight,
                headerMinExtent: safeHeight,
              ),
            ),
            if (widget.latestModAct != null && widget.latestModAct!.isNotEmpty && widget.threadID != null)
              SliverToBoxAdapter(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: edgeInsetsL12T4R12B4,
                    child: OperationLogCard(latestAction: widget.latestModAct!, tid: widget.threadID!),
                  ),
                ),
              ),
            SliverPadding(
              padding: edgeInsetsL12T4R12B4,
              sliver: SliverToBoxAdapter(
                child: Text(widget.title ?? '', style: Theme.of(context).textTheme.titleLarge),
              ),
            ),
            _buildPostList(context),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThreadBloc, ThreadState>(builder: _buildBody);
  }
}

/// Delegate to build a persistent sliver app bar.
class SliverAppBarPersistentDelegate extends SliverPersistentHeaderDelegate {
  /// Constructor.
  SliverAppBarPersistentDelegate({
    required this.buildHeader,
    required this.headerMaxExtent,
    required this.headerMinExtent,
  });

  /// Builder to build the app bar.
  final Widget Function(BuildContext, double, {required bool overlapsContent}) buildHeader;

  /// Max extent of top header.
  final double headerMaxExtent;

  /// Min extent of top header.
  final double headerMinExtent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return buildHeader(context, shrinkOffset, overlapsContent: overlapsContent);
  }

  @override
  double get maxExtent => headerMaxExtent;

  @override
  double get minExtent => headerMinExtent;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}
