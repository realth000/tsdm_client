import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/models/normal_thread.dart';
import 'package:tsdm_client/models/reply_parameters.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/utils/show_toast.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';
import 'package:url_launcher/url_launcher.dart';

const _headerMaxExtent = 60.0;
const _headerMinExtent = 60.0;

enum _MenuActions {
  refresh,
  copyUrl,
  openInBrowser,
  backToTop,
}

/// A widget that retrieve data from network and supports refresh.
class PostList<T> extends ConsumerStatefulWidget {
  /// Constructor.
  const PostList(
    this.tid,
    this.fetchUrl, {
    required this.listBuilder,
    required this.widgetBuilder,
    this.title,
    this.threadType,
    this.canFetchMorePages = false,
    this.pageNumber = 1,
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

  final Function(ReplyParameters)? replyFormHashCallback;

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
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NetworkWidgetState<T>();
}

class _NetworkWidgetState<T> extends ConsumerState<PostList<T>> {
  final _allData = <T>[];

  /// Thread type name.
  /// Actually this should provided by [NormalThread].
  /// But till now we haven't parse this attr in forum page.
  /// So parse here directly from thread page.
  /// But only parse once because every page shall have the same thread type.
  String? _threadType;

  final _refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  final _listScrollController = ScrollController();

  late int _pageNumber = widget.pageNumber;

  bool _inLastPage = false;

  /// Parse [_threadType] from thread page [document].
  /// This should only run once.
  String? _parseThreadType(uh.Document document) {
    final node = document.querySelector(
        'div#postlist > table > tbody > tr > td.pbn > h1.ts > a');
    return node?.firstEndDeepText();
  }

  /// Check whether in the last page in a web page (consists a series of pages).
  ///
  /// When already in the last page, current page mark (the <strong> node) is
  /// the last child of pagination indicator node.
  ///
  /// <div class="pgt">
  ///   <div class="pg">
  ///     <a class="url_to_page1"></a>
  ///     <a class="url_to_page2"></a>
  ///     <a class="url_to_page3"></a>
  ///     <strong>4</strong>           <-  Here we are in the last page
  ///   </div>
  /// </div>
  ///
  /// Typically when the web page only have one page, there is no pg node:
  ///
  /// <div class="pgt">
  ///   <span>...</span>
  /// </div>
  ///
  /// Indicating can not load more.
  bool canLoadMore(uh.Document document) {
    final barNode = document.getElementById('pgt');

    if (barNode == null) {
      debug('failed to check can load more: node not found');
      return false;
    }

    final paginationNode = barNode.querySelector('div.pg');
    if (paginationNode == null) {
      // Only one page, can not load more.
      return false;
    }

    final lastNode = paginationNode.children.lastOrNull;
    if (lastNode == null) {
      debug('failed to check can load more: empty pagination list');
      return false;
    }

    // If we are in the last page, the last node should be a "strong" type node.
    if (lastNode.nodeType != uh.Node.ELEMENT_NODE) {
      return false;
    }
    return lastNode.localName != 'strong';
  }

  Future<void> _loadData() async {
    late final uh.Document document;
    while (true) {
      if (!mounted) {
        return;
      }
      final d1 = await ref.read(netClientProvider()).get<dynamic>(
            '${widget.fetchUrl}${widget.canFetchMorePages ? "&page=$_pageNumber" : ""}',
          );
      if (d1.statusCode == HttpStatus.ok) {
        document = parseHtmlDocument(d1.data as String);
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
    _pageNumber++;

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
    _pageNumber = 1;
    _allData.clear();
  }

  @override
  void initState() {
    super.initState();
    // Try use the thread type in widget which comes from routing.
    _threadType = widget.threadType;
  }

  Widget _buildHeader(
      BuildContext context, WidgetRef ref, double shrinkOffset) {
    final titleText = widget.title;
    final isExpandHeader = _listScrollController.offset < _headerMaxExtent;

    Widget? titleWidget;
    if (titleText != null) {
      if (!isExpandHeader) {
        titleWidget = Text(titleText);
      }
    }

    return Column(
      children: [
        AppBar(
          title: titleWidget,
          actions: [
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _MenuActions.refresh,
                  child: Row(children: [
                    const Icon(Icons.refresh_outlined),
                    Text(context.t.networkList.actionRefresh),
                  ]),
                ),
                PopupMenuItem(
                  value: _MenuActions.copyUrl,
                  child: Row(children: [
                    const Icon(Icons.copy_outlined),
                    Text(context.t.networkList.actionCopyUrl),
                  ]),
                ),
                PopupMenuItem(
                  value: _MenuActions.openInBrowser,
                  child: Row(children: [
                    const Icon(Icons.launch_outlined),
                    Text(context.t.networkList.actionOpenInBrowser),
                  ]),
                ),
                PopupMenuItem(
                  value: _MenuActions.backToTop,
                  child: Row(children: [
                    const Icon(Icons.vertical_align_top_outlined),
                    Text(context.t.networkList.actionBackToTop),
                  ]),
                ),
              ],
              onSelected: (value) async {
                switch (value) {
                  case _MenuActions.refresh:
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
                  case _MenuActions.copyUrl:
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
                  case _MenuActions.openInBrowser:
                    await launchUrl(
                      Uri.parse(widget.fetchUrl),
                      mode: LaunchMode.externalApplication,
                    );
                  case _MenuActions.backToTop:
                    await _listScrollController.animateTo(
                      0,
                      curve: Curves.ease,
                      duration: const Duration(milliseconds: 500),
                    );
                }
              },
            ),
          ],
        ),
      ],
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
    return EasyRefresh(
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
        if (_inLastPage) {
          debug('already in last page');
          _refreshController
            ..finishLoad(IndicatorResult.noMore)
            ..resetFooter();
          await showNoMoreToast(context);
          return;
        }

        if (!widget.canFetchMorePages) {
          _clearData();
        }
        await _loadData();
        _refreshController
          ..finishLoad()
          ..resetFooter();
      },
      child: CustomScrollView(
        controller: _listScrollController,
        slivers: [
          const HeaderLocator.sliver(),
          SliverPersistentHeader(
            pinned: true,
            floating: true,
            delegate: SliverAppBarPersistentDelegate(
                buildHeader: (context, shrinkOffset, overlapsContent) {
              return _buildHeader(context, ref, shrinkOffset);
            }),
          ),
          SliverPadding(
            padding: edgeInsetsL10R10B10,
            sliver: SliverToBoxAdapter(
              child: Text(widget.title ?? '',
                  style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          if (_allData.isNotEmpty)
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
        ],
      ),
    );
  }
}

class SliverAppBarPersistentDelegate extends SliverPersistentHeaderDelegate {
  SliverAppBarPersistentDelegate({required this.buildHeader});

  final Widget Function(BuildContext, double, bool) buildHeader;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return buildHeader(context, shrinkOffset, overlapsContent);
  }

  @override
  double get maxExtent => _headerMaxExtent;

  @override
  double get minExtent => _headerMinExtent;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
