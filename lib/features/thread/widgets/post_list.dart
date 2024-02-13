import 'dart:core';

import 'package:collection/collection.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/thread/bloc/thread_bloc.dart';
import 'package:tsdm_client/features/thread/widgets/post_group.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/shared/models/normal_thread.dart' as nt;
import 'package:tsdm_client/shared/models/post.dart';
import 'package:tsdm_client/utils/show_toast.dart';

/// A widget that retrieve data from network and supports refresh.
class PostList extends StatefulWidget {
  /// Constructor.
  const PostList({
    required this.threadID,
    required this.threadType,
    required this.postList,
    required this.widgetBuilder,
    required this.canLoadMore,
    required this.scrollController,
    this.title,
    this.pageNumber = 1,
    this.useDivider = false,
    super.key,
  });

  /// Thread title.
  final String? title;

  /// Fetch page number "&page=[pageNumber]".
  final int pageNumber;

  /// Thread ID.
  final String? threadID;

  /// Thread type.
  ///
  /// When it is null, confirm it from thread page.
  final String? threadType;

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

  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  /// Thread type name.
  /// Actually this should provided by [nt.NormalThread].
  /// But till now we haven't parse this attr in forum page.
  /// So parse here directly from thread page.
  /// But only parse once because every page shall have the same thread type.
  String? _threadType;

  final _refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  /// [ScrollController] comes from outside.
  ///
  /// Do NOT dispose it here.
  late final ScrollController _listScrollController;

  @override
  void initState() {
    super.initState();
    // Try use the thread type in widget which comes from routing.
    _threadType = widget.threadType;
    _listScrollController = widget.scrollController;
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Widget _buildHeader(
    BuildContext context,
    double shrinkOffset,
    double expandHeight,
  ) {
    if (_listScrollController.offset <= expandHeight) {
      return Padding(
        padding: edgeInsetsL10R10B10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '[${context.t.threadPage.title} ${widget.threadID ?? ""}]',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.outline),
            ),
            sizedBoxW5H5,
            Text(
              '[${_threadType ?? ""}]',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.outline),
            ),
          ],
        ),
      );
    }
    final bg = _listScrollController.offset >= expandHeight
        ? ElevationOverlay.applySurfaceTint(
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surfaceTint,
            Theme.of(context).navigationBarTheme.elevation ?? 3,
          )
        : Colors.transparent;
    return ColoredBox(
      color: bg,
      child: Padding(
        padding: edgeInsetsL10R10B10,
        child: Text(
          _listScrollController.offset > expandHeight
              ? (widget.title ?? '')
              : (widget.threadType ?? ''),
          style: Theme.of(context).textTheme.titleLarge,
          maxLines: 1,
        ),
      ),
    );
  }

  List<Widget> _buildPostList(BuildContext context) {
    if (widget.postList.isEmpty) {
      return [];
    }
    final ret = <Widget>[];

    // Current sliver group index.
    //
    // All posts in the same page will be gathered in a group.
    // Each page has at most 10 posts.
    final postGroupList = widget.postList.slices(10);
    for (final postGroup in postGroupList) {
      final pageNumber =
          ((postGroup.firstOrNull?.postFloor ?? 0) / 10).floor() + 1;
      ret.add(
        SliverMainAxisGroup(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: PostGroupHeaderDelegate(groupIndex: '$pageNumber'),
            ),
            SliverList.separated(
              itemCount: postGroup.length,
              itemBuilder: (context, index) {
                return widget.widgetBuilder(context, postGroup[index]);
              },
              separatorBuilder: (context, index) => widget.useDivider
                  ? const Divider(thickness: 0.5)
                  : sizedBoxW5H5,
            ),
          ],
        ),
      );
    }

    return ret;
  }

  Widget _buildBody(BuildContext context, ThreadState state) {
    const safeHeight = 40.0;

    _refreshController.finishLoad();

    _threadType ??= state.threadType;

    return EasyRefresh.builder(
      scrollBehaviorBuilder: (physics) {
        // Should use ERScrollBehavior instead of
        // ScrollConfiguration.of(context)
        return ERScrollBehavior(physics)
            .copyWith(physics: physics, scrollbars: false);
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
          await showNoMoreSnackBar(context);
          _refreshController.finishLoad();
          return;
        }
        context
            .read<ThreadBloc>()
            .add(ThreadLoadMoreRequested(widget.pageNumber + 1));
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
                buildHeader: (
                  context,
                  shrinkOffset, {
                  required bool overlapsContent,
                }) {
                  return _buildHeader(context, shrinkOffset, safeHeight);
                },
                headerMaxExtent: safeHeight,
                headerMinExtent: safeHeight,
              ),
            ),
            SliverPadding(
              padding: edgeInsetsL10R10B10,
              sliver: SliverToBoxAdapter(
                child: Text(
                  widget.title ?? '',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            ..._buildPostList(context),
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
  final Widget Function(BuildContext, double, {required bool overlapsContent})
      buildHeader;

  /// Max extent of top header.
  final double headerMaxExtent;

  /// Min extent of top header.
  final double headerMinExtent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return buildHeader(context, shrinkOffset, overlapsContent: overlapsContent);
  }

  @override
  double get maxExtent => headerMaxExtent;

  @override
  double get minExtent => headerMinExtent;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
