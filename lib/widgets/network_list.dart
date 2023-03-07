import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html/dom.dart' as html;
import 'package:html/parser.dart' as html_parser;

import '../providers/dio_provider.dart';

/// A widget that retrieve data from network and supports refresh.
class NetworkList<T> extends ConsumerStatefulWidget {
  /// Constructor.
  const NetworkList(
    this.fetchUrl, {
    required this.listBuilder,
    required this.widgetBuilder,
    super.key,
  });

  /// Url to fetch data.
  final String fetchUrl;

  /// Build [Widget] from given [html.Document].
  ///
  /// User needs to provide this method and [NetworkList] refresh by pressing
  /// refresh button.
  final List<T> Function(html.Document document) listBuilder;

  /// Build a list of [Widget].
  final Widget Function(BuildContext, T) widgetBuilder;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NetworkWidgetState();
}

class _NetworkWidgetState<T> extends ConsumerState<NetworkList<T>>
    with SingleTickerProviderStateMixin {
  late Future<Response<dynamic>> _networkData;

  void _loadData() {
    _networkData = ref.read(dioProvider).get(widget.fetchUrl);
  }

  final _allData = <T>[];

  final _listScrollController = ScrollController();

  late final AnimationController _menuAniController;

  bool _showMenu = false;

  static const _aniDuration = Duration(milliseconds: 200);

  double _bottom1 = 20;

  @override
  void initState() {
    super.initState();
    _loadData();
    _menuAniController = AnimationController(
      vsync: this,
      duration: _aniDuration,
    );
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    _menuAniController.dispose();
    super.dispose();
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
  Widget build(BuildContext context) => FutureBuilder(
        future: _networkData,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final newData =
                widget.listBuilder(html_parser.parse(snapshot.data!.data));
            _allData.addAll(newData);
            return Stack(
              alignment: Alignment.bottomRight,
              children: [
                ListView.builder(
                  controller: _listScrollController,
                  itemCount: _allData.length,
                  itemBuilder: (context, index) =>
                      widget.widgetBuilder(context, _allData[index]),
                ),
                AnimatedPositioned(
                  right: 20,
                  bottom: _bottom1,
                  duration: _aniDuration,
                  child: FloatingActionButton(
                    heroTag: 2,
                    child: const Icon(Icons.refresh),
                    onPressed: () {
                      setState(() {
                        _loadData();
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
        },
      );
}
