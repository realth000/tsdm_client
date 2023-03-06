import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html/dom.dart' as html;
import 'package:html/parser.dart' as html_parser;

import '../providers/dio_provider.dart';
import 'stack.dart';

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

class _NetworkWidgetState extends ConsumerState<NetworkWidget> {
  late Future<Response<dynamic>> _data;

  void _loadData() {
    _data = ref.read(dioProvider).get(widget.fetchUrl);
  }

  @override
  void initState() {
    super.initState();
    _loadData();
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
            return buildStack(
              widget.bodyBuilder(html_parser.parse(snapshot.data!.data)),
              FloatingActionButton(
                onPressed: () {
                  setState(_loadData);
                },
                child: const Icon(Icons.refresh),
              ),
            );
          }
        },
      );
}
