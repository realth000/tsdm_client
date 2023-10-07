import 'dart:io';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/utils/html_element.dart';

part '../generated/providers/root_content_provider.g.dart';

class ThreadAuthorPair {
  ThreadAuthorPair({
    required this.threadUrl,
    required this.threadTitle,
    required this.authorUrl,
    required this.authorName,
  });

  final String threadUrl;
  final String threadTitle;
  final String authorUrl;
  final String authorName;
}

/// For the following structure, filter and combine thread and its author.
///
/// <div class="Kahrpba_threads">
///   <a href="thread_url">
///     thread_title
///   </a>
///   <a href="author_url">
///     <em>author_name</em>
///   </a>
///
/// Filter out thread_url, thread_title, author_url and author_name.
///
/// Where [element] is <div class="Kahrpba_threads"> node.
ThreadAuthorPair? _filterThreadAndAuthors(Element element) {
  final allNode = element.querySelectorAll('a').toList();
  // There should be two <a> in children.
  if (allNode.length != 2) {
    debug('skip build thread author pair: node count is ${allNode.length}');
    return null;
  }

  final threadUrl = allNode[0].attributes['href'];
  if (threadUrl == null) {
    debug('skip incomplete thread author pair: thread url not found');
    return null;
  }

  final threadTitle = allNode[0].firstEndDeepText();
  if (threadTitle == null) {
    debug('skip incomplete thread author pair: thread title not found');
    return null;
  }

  final authorUrl = allNode[1].attributes['href'];
  if (authorUrl == null) {
    debug('skip incomplete thread author pair: author url not found');
    return null;
  }

  final authorName = allNode[1].firstEndDeepText();
  if (authorName == null) {
    debug('skip incomplete thread author pair: author name not found');
    return null;
  }

  return ThreadAuthorPair(
    threadUrl: threadUrl,
    threadTitle: threadTitle,
    authorUrl: authorUrl,
    authorName: authorName,
  );
}

/// Provider to prepare root page content from homepage "https://www.tsdm39.com/forum.php"
// TODO: Make this a not persist provider.
@Riverpod(keepAlive: true, dependencies: [NetClient])
class RootContent extends _$RootContent {
  static const String _rootPage = 'https://www.tsdm39.com/forum.php';

  @override
  Future<CachedRootContent> build() async {
    return fetch();
  }

  /// Fetch data from homepage.
  ///
  /// This will take a long time so use cached data as possible.
  Future<CachedRootContent> fetch() async {
    final resp = await ref.read(netClientProvider()).get(_rootPage);
    if (resp.statusCode != HttpStatus.ok) {
      return Future.error(
          'failed to load root page content, status code is ${resp.statusCode}');
    }
    _doc = html_parser.parse(resp.data);

    _cache = CachedRootContent();
    await _cache.analyze(_doc);

    return _cache;
  }

  Document get doc => _doc;

  late Document _doc;

  CachedRootContent get cache => _cache;

  late CachedRootContent _cache;
}

class CachedRootContent {
  CachedRootContent();

  String welcomeText = '';
  String welcomeLastLoginText = '';
  List<String?> picUrlList = [];
  List<String?> picHrefList = [];
  List<String>? memberInfoList = [];

  List<(String, String)>? welcomeNavigateHrefsPairs = [];

  List<String?>? navNameList = [];
  final sectionAllThreadPairList = <List<ThreadAuthorPair?>>[];

  List<String?> _buildKahrpbaPicUrlList(Element? styleNode) {
    if (styleNode == null) {
      debug('failed to build kahrpba picture url list: node is null');
      return [];
    }

    return styleNode.innerHtml
        .split('\n')
        .where((e) => e.startsWith('.Kahrpba_pic_') && !e.contains('ctrlbtn'))
        .map((e) => e.split('(').lastOrNull?.split(')').firstOrNull)
        .toList();
  }

  List<String?> _buildKahrpbaPicHrefList(Element? scriptNode) {
    if (scriptNode == null) {
      debug('failed to build kahrpba picture href list: node is null');
      return [];
    }

    return scriptNode.innerHtml
        .split('\n')
        .where((e) => e.contains("window.location='"))
        .map((e) =>
            e.split("window.location='").lastOrNull?.split("'").firstOrNull)
        .toList();
  }

  Future<void> analyze(Document document) async {
    final chartNode = document.getElementById('chart');
    final chartZNode = document.querySelector('p.chart.z');
    final styleNode = chartNode?.querySelector('style');
    final scriptNode = chartNode?.querySelector('script');
    picUrlList = _buildKahrpbaPicUrlList(styleNode);
    picHrefList = _buildKahrpbaPicHrefList(scriptNode);
    if (picUrlList.isEmpty && picHrefList.isEmpty) {
      debug('root content pinned pic not found: maybe not login');

      // There's no pinned recent threads when not login, just return
      return;
    }
    final chartZInfoList = chartZNode?.querySelectorAll('em').toList();
    if (chartZInfoList != null && chartZInfoList.length == 4) {
      memberInfoList =
          chartZInfoList.map((e) => e.text).toList(growable: false);
    } else {
      memberInfoList = null;
    }

    final welcomeNode = document.getElementById('tsdmwelcome');
    // welcomeText is plain text inside welcomeNode div.
    // Only using [nodes] method can capture it.
    final welcomeTextList = welcomeNode?.nodes.firstOrNull?.text
        ?.split('，')
        .map((e) => e.trim())
        .toList();
    welcomeText = welcomeTextList?[0] ?? 'Hello';
    welcomeLastLoginText = welcomeTextList?[1] ?? '';
    welcomeNavigateHrefsPairs = welcomeNode
        ?.querySelectorAll('a')
        .where((e) => e.attributes.containsKey('href'))
        .map((e) => (e.firstEndDeepText() ?? 'unknown', e.attributes['href']!))
        .toList();

    navNameList = document
        .querySelector('td#Kahrpba_nav')
        ?.children
        .map((e) => e.firstEndDeepText())
        .toList();
    final navShowList = document
        .querySelector('td#Kahrpba_show')
        ?.children
        .where((e) => e.id.startsWith('Kahrpba_c'))
        .toList();

    if (navNameList == null ||
        navShowList == null ||
        navNameList?.length != navShowList.length) {
      debug(
          'failed to parse homepage pin section: navName length: ${navNameList?.length}, navShowList length: ${navShowList?.length}');
      return;
    }

    final count = navNameList!.length;
    for (var i = 0; i < count; i++) {
      sectionAllThreadPairList.add(navShowList[i]
          .querySelectorAll('div.Kahrpba_threads')
          .map(_filterThreadAndAuthors)
          .toList());
    }
  }
}
