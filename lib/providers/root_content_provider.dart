import 'dart:io';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';

part '../generated/providers/root_content_provider.g.dart';

/// Provider to prepare root page content from homepage "https://www.tsdm39.com/forum.php"
// TODO: Make this a not presistant provider.
@Riverpod(keepAlive: true, dependencies: [NetClient])
class RootContent extends _$RootContent {
  static const String _rootPage = 'https://www.tsdm39.com/forum.php';

  @override
  Future<Document> build() async {
    return fetch();
  }

  /// Fetch data from homepage.
  ///
  /// This will take a long time so use cached data as possible.
  Future<Document> fetch() async {
    final resp = await ref.read(netClientProvider).get(_rootPage);
    if (resp.statusCode != HttpStatus.ok) {
      return Future.error(
          'failed to load root page content, status code is ${resp.statusCode}');
    }
    _doc = html_parser.parse(resp.data);

    return _doc;
  }

  Document get doc => _doc;

  late Document _doc;
}
