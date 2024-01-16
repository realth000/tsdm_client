import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/thread/bloc/thread_bloc.dart';
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
    this.title,
    this.pageNumber = 1,
    this.useDivider = false,
    super.key,
  });

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

  final List<Post> postList;

  final bool canLoadMore;

  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState<T> extends State<PostList> {
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

  final _listScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Try use the thread type in widget which comes from routing.
    _threadType = widget.threadType;
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _refreshData(BuildContext context) async {}

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
            Theme.of(context).navigationBarTheme.elevation ?? 3)
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

  Widget _buildBody(BuildContext context, ThreadState state) {
    const safeHeight = 40.0;

    _refreshController.finishLoad();

    return EasyRefresh.builder(
      scrollBehaviorBuilder: (physics) {
        // Should use ERScrollBehavior instead of ScrollConfiguration.of(context)
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
          await showNoMoreToast(context);
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
                buildHeader: (context, shrinkOffset, overlapsContent) {
                  return _buildHeader(context, shrinkOffset, safeHeight);
                },
                headerMaxExtent: safeHeight,
                headerMinExtent: safeHeight,
              ),
            ),
            SliverPadding(
              padding: edgeInsetsL10R10B10,
              sliver: SliverToBoxAdapter(
                child: Text(widget.title ?? '',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
            ),
            if (widget.postList.isNotEmpty)
              SliverPadding(
                padding: edgeInsetsL10R10B20,
                sliver: SliverList.separated(
                  itemCount: widget.postList.length,
                  itemBuilder: (context, index) {
                    return widget.widgetBuilder(
                        context, widget.postList[index]);
                  },
                  separatorBuilder: widget.useDivider
                      ? (context, index) => const Divider(thickness: 0.5)
                      : (context, index) => sizedBoxW5H5,
                ),
              ),
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

class SliverAppBarPersistentDelegate extends SliverPersistentHeaderDelegate {
  SliverAppBarPersistentDelegate({
    required this.buildHeader,
    required this.headerMaxExtent,
    required this.headerMinExtent,
  });

  final Widget Function(BuildContext, double, bool) buildHeader;

  final double headerMaxExtent;
  final double headerMinExtent;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return buildHeader(context, shrinkOffset, overlapsContent);
  }

  @override
  double get maxExtent => headerMaxExtent;

  @override
  double get minExtent => headerMinExtent;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
