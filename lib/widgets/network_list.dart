import 'dart:async';

import 'package:collection/collection.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';
import 'package:url_launcher/url_launcher.dart';

enum _MenuActions {
  refresh,
  copyUrl,
  openInBrowser,
  backToTop,
}

/// A widget that retrieve data from network and supports refresh.
class NetworkList<T> extends ConsumerStatefulWidget {
  /// Constructor.
  const NetworkList(
    this.fetchUrl, {
    required this.listBuilder,
    required this.widgetBuilder,
    this.title,
    this.canFetchMorePages = false,
    this.pageNumber = 1,
    this.initialData,
    this.replyFormHashCallback,
    super.key,
  });

  final String? title;

  /// Whether can fetch more pages.
  final bool canFetchMorePages;

  /// Url to fetch data.
  final String fetchUrl;

  /// Fetch page number "&page=[pageNumber]".
  final int pageNumber;

  final Function(String postTime, String formHash, String subject)?
      replyFormHashCallback;

  /// Build [Widget] from given [uh.Document].
  ///
  /// User needs to provide this method and [NetworkList] refresh by pressing
  /// refresh button.
  final FutureOr<List<T>> Function(uh.Document document) listBuilder;

  /// Build a list of [Widget].
  final Widget Function(BuildContext, T) widgetBuilder;

  /// Initial data to use in the first fetch.
  /// This argument allows to load cached data every first time.
  final uh.Document? initialData;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NetworkWidgetState<T>();
}

class _NetworkWidgetState<T> extends ConsumerState<NetworkList<T>> {
  final _allData = <T>[];

  final _refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  final _listScrollController = ScrollController();

  late int _pageNumber = widget.pageNumber;

  /// Flag to mark whether has already tried to load data.
  /// If any attempt occurred before, set to true.
  bool _initialized = false;

  bool _inLastPage = false;

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
    final barNode =
        document.querySelector('div#ct > div#ct_shell > div#pgt.pgs > div.pgt');

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
    if (!_initialized && widget.initialData != null) {
      document = widget.initialData!;
      _initialized = true;
    } else {
      final d1 = await ref.read(netClientProvider()).get<dynamic>(
            '${widget.fetchUrl}${widget.canFetchMorePages ? "&page=$_pageNumber" : ""}',
          );
      document = parseHtmlDocument(d1.data as String);
    }
    final data = await widget.listBuilder(document);

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

      String? postTime;
      String? formHash;
      String? subject;
      for (final node in inputNodeList) {
        if (!node.attributes.containsKey('name')) {
          continue;
        }
        final name = node.attributes['name'];
        if (name == 'posttime') {
          postTime = node.attributes['value'];
        } else if (name == 'formhash') {
          formHash = node.attributes['value'];
        } else if (name == 'subject') {
          subject = node.attributes['value'];
        }
      }

      if (postTime == null || formHash == null || subject == null) {
        debug(
            'failed to get reply form hash: postTime=$postTime formHash=$formHash subject=$subject');
        return;
      }
      widget.replyFormHashCallback!(postTime, formHash, subject);
    }
  }

  void _clearData() {
    _pageNumber = 1;
    _allData.clear();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => EasyRefresh(
        scrollBehaviorBuilder: (physics) {
          // Should use ERScrollBehavior instead of ScrollConfiguration.of(context)
          return ERScrollBehavior(physics)
              .copyWith(physics: physics, scrollbars: false);
        },
        header: const MaterialHeader(position: IndicatorPosition.locator),
        footer: const ClassicFooter(position: IndicatorPosition.locator),
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
            _refreshController.finishLoad(IndicatorResult.noMore);
            return;
          }

          if (!widget.canFetchMorePages) {
            _clearData();
          }
          await _loadData();
          _refreshController.finishLoad();
        },
        child: CustomScrollView(
          controller: _listScrollController,
          slivers: [
            SliverAppBar(
              title: widget.title == null ? null : Text(widget.title!),
              pinned: true,
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
                        await _refreshController.callRefresh();
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
            const HeaderLocator.sliver(),
            if (_allData.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
                sliver: SliverList.separated(
                  itemCount: _allData.length,
                  itemBuilder: (context, index) {
                    return widget.widgetBuilder(context, _allData[index]);
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(width: 10, height: 5);
                  },
                ),
              ),
            const FooterLocator.sliver(),
          ],
        ),
      );
}
