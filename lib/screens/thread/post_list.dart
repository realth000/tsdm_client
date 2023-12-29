import 'dart:async';
import 'dart:io';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/models/normal_thread.dart';
import 'package:tsdm_client/models/reply_parameters.dart';
import 'package:tsdm_client/packages/html_muncher/lib/html_muncher.dart';
import 'package:tsdm_client/providers/html_parser_provider.dart';
import 'package:tsdm_client/providers/jump_page_provider.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';
import 'package:tsdm_client/providers/screen_state_provider.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/utils/show_toast.dart';
import 'package:tsdm_client/widgets/list_app_bar.dart';
import 'package:universal_html/html.dart' as uh;

// enum _MenuActions {
//   refresh,
//   copyUrl,
//   openInBrowser,
//   backToTop,
// }

/// A widget that retrieve data from network and supports refresh.
class PostList<T> extends ConsumerStatefulWidget {
  /// Constructor.
  const PostList(
    this.tid,
    this.fetchUrl,
    this.threadID,
    this.threadType, {
    required this.listBuilder,
    required this.widgetBuilder,
    this.title,
    this.canFetchMorePages = false,
    this.pageNumber = 1,
    this.postId,
    this.replyFormHashCallback,
    this.useDivider = false,
    super.key,
  });

  final String? title;

  /// Whether can fetch more pages.
  final bool canFetchMorePages;

  /// Thread id.
  final String tid;

  /// Url to fetch data.
  final String fetchUrl;

  /// Fetch page number "&page=[pageNumber]".
  final int pageNumber;

  // TODO: Scroll to post.
  /// Post that need to ensure visible (or say: scroll to) when page first built.
  final String? postId;

  final Function(ReplyParameters)? replyFormHashCallback;

  /// Thread ID.
  final String? threadID;

  /// Thread type.
  ///
  /// When it is null, confirm it from thread page.
  final String? threadType;

  /// Build [Widget] from given [uh.Document].
  ///
  /// User needs to provide this method and [PostList] refresh by pressing
  /// refresh button.
  final FutureOr<List<T>> Function(uh.Document document) listBuilder;

  /// Build a list of [Widget].
  final Widget Function(BuildContext, T) widgetBuilder;

  /// Use [Divider] instead of [SizedBox] between list items.
  final bool useDivider;

  @override
  ConsumerState<PostList<T>> createState() => _PostListState<T>();
}

class _PostListState<T> extends ConsumerState<PostList<T>> {
  final _allData = <T>[];

  /// Thread type name.
  /// Actually this should provided by [NormalThread].
  /// But till now we haven't parse this attr in forum page.
  /// So parse here directly from thread page.
  /// But only parse once because every page shall have the same thread type.
  String? _threadType;

  final _stateStream = StreamController<ScreenStateEvent>();

  final _refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  final _listScrollController = ScrollController();

  /// Current page number.
  late int _pageNumber = widget.pageNumber;

  /// Total pages number.
  var _totalPages = 0;

  bool _inLastPage = false;

  /// Widget indicating widget.listBuilder builds failed or not.
  /// When build failed, show text info in current page.
  Widget? _failedMessageWidget;

  /// Flag indicates that whether need to scroll to the post with id widget.postId after load data for the first time.
  /// This scrolling should only scroll the first time widget is built.
  bool needScrollToPost = true;

  /// Parse [_threadType] from thread page [document].
  /// This should only run once.
  String? _parseThreadType(uh.Document document) {
    final node = document.querySelector('div#postlist h1.ts > a');
    return node
        ?.firstEndDeepText()
        ?.replaceFirst('[', '')
        .replaceFirst(']', '');
  }

  /// Check whether in the last page in a web page (consists a series of pages).
  bool canLoadMore(uh.Document document) {
    return _pageNumber >= 0 && _pageNumber < _totalPages;
  }

  Future<void> _loadData() async {
    late final uh.Document document;
    while (true) {
      if (!mounted) {
        return;
      }

      // TODO: Should get next page url from html document, do NOT format it here manually.
      // <a class="nxt" href="next_page_url"></a>
      final d1 = await ref.read(netClientProvider()).get<dynamic>(
            '${widget.fetchUrl}${widget.canFetchMorePages ? "&page=$_pageNumber" : ""}',
          );
      if (!mounted) {
        return;
      }
      if (d1.statusCode == HttpStatus.ok) {
        document = ref.read(htmlParserProvider.notifier).parseResp(d1);
        break;
      }
      if (!mounted) {
        return;
      }
      await showRetryToast(context);
    }
    final data = await widget.listBuilder(document);

    if (!mounted) {
      return;
    }

    // When not post found, try to parse message text dialog.
    if (data.isEmpty) {
      final messageText = document.querySelector('div#messagetext');
      if (messageText != null) {
        setState(() {
          _failedMessageWidget = munchElement(context, messageText);
        });
        return;
      }
    }

    /// TODO: Use thread type parsed in [ThreadData].
    /// Parse thread type
    if (_threadType == null) {
      setState(() {
        _threadType = _parseThreadType(document);
      });
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _allData.addAll(data);
    });
    _pageNumber = document.currentPage() ?? _pageNumber;
    _totalPages = document.totalPages() ?? _pageNumber;
    ref
        .read(jumpPageProvider(hashCode).notifier)
        .setPageState(currentPage: _pageNumber, totalPages: _totalPages);

    // Update whether we are in the last page.
    _inLastPage = !canLoadMore(document);

    // If this can reply, call the callback.
    if (widget.replyFormHashCallback != null) {
      final inputNodeList = document.querySelectorAll('input');
      if (inputNodeList.isEmpty) {
        debug('failed to get reply form hash: input not found');
        return;
      }

      String? fid;
      String? postTime;
      String? formHash;
      String? subject;
      for (final node in inputNodeList) {
        if (!node.attributes.containsKey('name')) {
          continue;
        }
        final name = node.attributes['name'];
        final value = node.attributes['value'];
        switch (name) {
          case 'srhfid':
            fid = value;
          case 'posttime':
            postTime = value;
          case 'formhash':
            formHash = value;
          case 'subject':
            subject = value;
        }
      }

      if (fid == null ||
          postTime == null ||
          formHash == null ||
          subject == null) {
        debug(
            'failed to get reply form hash: fid=$fid postTime=$postTime formHash=$formHash subject=$subject');
        return;
      }
      await widget.replyFormHashCallback!(ReplyParameters(
        fid: fid,
        tid: widget.tid,
        postTime: postTime,
        formHash: formHash,
        subject: subject,
      ));
    }
  }

  void _clearData() {
    _allData.clear();
  }

  @override
  void initState() {
    super.initState();
    // Try use the thread type in widget which comes from routing.
    _threadType = widget.threadType;
    screenStateContainer
        .read(screenStateProvider.notifier)
        .sink(_stateStream.sink);
    _stateStream.stream.listen((event) async {
      switch (event) {
        case ScreenStateEvent.refresh:
          await _refresh();
        default:
      }
    });
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    _refreshController.dispose();
    screenStateContainer.read(screenStateProvider.notifier).clearSink();
    _stateStream.close();
    super.dispose();
  }

  Future<void> _refresh() async {
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

  @override
  Widget build(BuildContext context) {
    final safeHeight = 40.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListAppBar(
          onSearch: () async {
            await context.pushNamed(ScreenPaths.search);
          },
          jumpPageKey: hashCode,
          onJumpPage: (pageNumber) async {
            if (!mounted) {
              return;
            }
            setState(() {
              _pageNumber = pageNumber;
              ref.read(jumpPageProvider(hashCode).notifier).setPageState(
                  currentPage: _pageNumber, totalPages: _totalPages);
            });
            await _refresh();
          },
          onSelected: (value) async {
            switch (value) {
              case MenuActions.refresh:
                await _refresh();
              case MenuActions.copyUrl:
                await Clipboard.setData(
                  ClipboardData(text: widget.fetchUrl),
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
                await context.dispatchAsUrl(widget.fetchUrl, external: true);
              case MenuActions.backToTop:
                await _listScrollController.animateTo(
                  0,
                  curve: Curves.ease,
                  duration: const Duration(milliseconds: 500),
                );
            }
          },
        ),
        Expanded(
          child: EasyRefresh.builder(
            scrollBehaviorBuilder: (physics) {
              // Should use ERScrollBehavior instead of ScrollConfiguration.of(context)
              return ERScrollBehavior(physics)
                  .copyWith(physics: physics, scrollbars: false);
            },
            header: const MaterialHeader(position: IndicatorPosition.locator),
            footer: const MaterialFooter(),
            controller: _refreshController,
            scrollController: _listScrollController,
            refreshOnStart: true,
            onRefresh: () async {
              if (!mounted) {
                return;
              }
              _clearData();
              await _loadData();
              _refreshController
                ..finishRefresh()
                ..resetFooter();
            },
            onLoad: () async {
              if (!mounted) {
                return;
              }
              if (!widget.canFetchMorePages) {
                return;
              }
              if (_inLastPage) {
                debug('already in last page');
                _refreshController
                  ..finishLoad(IndicatorResult.noMore)
                  ..resetFooter();
                await showNoMoreToast(context);
                return;
              }

              _pageNumber++;
              await _loadData();
              _refreshController.finishLoad();
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
                  if (_failedMessageWidget == null && _allData.isNotEmpty)
                    SliverPadding(
                      padding: edgeInsetsL10R10B20,
                      sliver: SliverList.separated(
                        itemCount: _allData.length,
                        itemBuilder: (context, index) {
                          return widget.widgetBuilder(context, _allData[index]);
                        },
                        separatorBuilder: widget.useDivider
                            ? (context, index) => const Divider(thickness: 0.5)
                            : (context, index) => sizedBoxW5H5,
                      ),
                    ),
                  if (_failedMessageWidget != null)
                    SliverFillRemaining(
                        child: Center(child: _failedMessageWidget)),
                ],
              );
            },
          ),
        ),
      ],
    );
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
