import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

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
    super.key,
  });

  final String? title;

  /// Whether can fetch more pages.
  final bool canFetchMorePages;

  /// Url to fetch data.
  final String fetchUrl;

  /// Fetch page number "&page=[pageNumber]".
  final int pageNumber;

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
      print('>> add data : ${data.length}');
      _allData.addAll(data);
    });
    _pageNumber++;
  }

  void _clearData() {
    _pageNumber = 1;
    _allData.clear();
  }

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
  Widget build(BuildContext context) => Scrollbar(
        controller: _listScrollController,
        child: EasyRefresh(
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
              ),
              const HeaderLocator.sliver(),
              if (_allData.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return widget.widgetBuilder(context, _allData[index]);
                    },
                    childCount: _allData.length,
                  ),
                ),
              const FooterLocator.sliver(),
            ],
          ),
        ),
      );
}
