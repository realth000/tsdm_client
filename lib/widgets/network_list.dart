import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html/dom.dart' as html;
import 'package:html/parser.dart' as html_parser;
import 'package:tsdm_client/providers/dio_provider.dart';

/// A widget that retrieve data from network and supports refresh.
class NetworkList<T> extends ConsumerStatefulWidget {
  /// Constructor.
  const NetworkList(
    this.fetchUrl, {
    required this.listBuilder,
    required this.widgetBuilder,
    this.canFetchMorePages = false,
    this.pageNumber = 1,
    super.key,
  });

  /// Whether can fetch more pages.
  final bool canFetchMorePages;

  /// Url to fetch data.
  final String fetchUrl;

  /// Fetch page number "&page=[pageNumber]".
  final int pageNumber;

  /// Build [Widget] from given [html.Document].
  ///
  /// User needs to provide this method and [NetworkList] refresh by pressing
  /// refresh button.
  final List<T> Function(html.Document document) listBuilder;

  /// Build a list of [Widget].
  final Widget Function(BuildContext, T) widgetBuilder;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NetworkWidgetState<T>();
}

class _NetworkWidgetState<T> extends ConsumerState<NetworkList<T>>
    with SingleTickerProviderStateMixin {
  Future<void> _loadData() async {
    final d1 = await ref.read(dioProvider).get<dynamic>(
          '${widget.fetchUrl}${widget.canFetchMorePages ? "&page=$_pageNumber" : ""}',
        );
    final d2 = widget.listBuilder(html_parser.parse(d1.data));
    if (!mounted) {
      return;
    }
    setState(() {
      _allData.addAll(d2);
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

  late final AnimationController _menuAniController;

  bool _showMenu = false;

  late int _pageNumber = widget.pageNumber;

  static const _aniDuration = Duration(milliseconds: 200);

  double _bottom1 = 20;

  @override
  void initState() {
    super.initState();
    _menuAniController = AnimationController(
      vsync: this,
      duration: _aniDuration,
    );
  }

  @override
  void dispose() {
    _menuAniController.dispose();
    _listScrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _openMenuWidgets() {
    _menuAniController.forward();
    _bottom1 = 90;
  }

  void _closeMenuWidgets() {
    _menuAniController.reverse();
    _bottom1 = 20;
  }

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.bottomRight,
        children: [
          EasyRefresh(
            header: const MaterialHeader(),
            footer: const MaterialFooter(),
            scrollController: _listScrollController,
            controller: _refreshController,
            refreshOnStart: true,
            child: ListView.builder(
              controller: _listScrollController,
              itemCount: _allData.length,
              itemBuilder: (context, index) =>
                  widget.widgetBuilder(context, _allData[index]),
            ),
            onRefresh: () async {
              _clearData();
              await _loadData();
              _refreshController
                ..finishRefresh()
                ..resetFooter();
            },
            onLoad: () async {
              if (!widget.canFetchMorePages) {
                _clearData();
              }
              await _loadData();
              _refreshController.finishLoad();
            },
          ),
          AnimatedPositioned(
            right: 20,
            bottom: _bottom1,
            duration: _aniDuration,
            child: FloatingActionButton(
              heroTag: 2,
              child: const Icon(Icons.refresh),
              onPressed: () async {
                await _refreshController.callRefresh();
                setState(() {
                  _showMenu = false;
                  _closeMenuWidgets();
                });
              },
            ),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _showMenu = !_showMenu;
                  if (_showMenu) {
                    _openMenuWidgets();
                  } else {
                    _closeMenuWidgets();
                  }
                });
              },
              child: AnimatedIcon(
                icon: AnimatedIcons.menu_close,
                progress: _menuAniController,
              ),
            ),
          ),
        ],
      );
}
