import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html/dom.dart' as html;
import 'package:html/parser.dart' as html_parser;

import '../providers/dio_provider.dart';

/// A widget that retrieve data from network and supports refresh.
class NetworkWidget extends ConsumerStatefulWidget {
  /// Constructor.
  const NetworkWidget(
    this.fetchUrl,
    this.bodyBuilder, {
    super.key,
  });

  /// Url to fetch data.
  final String fetchUrl;

  /// Build [Widget] from given [html.Document].
  ///
  /// User needs to provide this method and [NetworkWidget] give it ability to
  /// refresh by pressing refresh button.
  final Widget Function(html.Document document) bodyBuilder;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NetworkWidgetState();
}

class _NetworkWidgetState extends ConsumerState<NetworkWidget>
    with SingleTickerProviderStateMixin {
  late Future<Response<dynamic>> _data;

  void _loadData() {
    _data = ref.read(dioProvider).get(widget.fetchUrl);
  }

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
    _menuAniController.dispose();
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
        future: _data,
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
            return Stack(
              alignment: Alignment.bottomRight,
              children: [
                widget.bodyBuilder(html_parser.parse(snapshot.data!.data)),
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
