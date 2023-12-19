import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/models/searched_thread.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';
import 'package:universal_html/parsing.dart';

part '../generated/providers/search_provider.g.dart';

enum SearchState {
  searching,
  notSearching,
}

/// Search result data.
@immutable
class SearchResult {
  const SearchResult({
    required this.currentPage,
    required this.totalPages,
    required this.count,
    required this.data,
  });

  const SearchResult.empty()
      : currentPage = 0,
        totalPages = 0,
        count = 0,
        data = null;

  /// Current search result page number.
  final int currentPage;

  /// Total search result page numbers.
  final int totalPages;

  /// Search result count;
  final int? count;

  /// Thread list.
  final List<SearchedThread>? data;

  bool isValid() {
    return currentPage > 0 && totalPages > 0 && currentPage <= totalPages;
  }

  @override
  String toString() {
    final dataString = data?.map((e) => e.toString()).join('\n    ');
    return '''
SearchResult{
  currentPage=$currentPage,
  totalPage=$totalPages,
  count=$count,
  data=
    $dataString
}
''';
  }
}

@Riverpod(dependencies: [NetClient])
class Search extends _$Search {
  static const _searchUrl = '$baseUrl/plugin.php';

  SearchState _state = SearchState.notSearching;

  @override
  SearchState build() {
    return _state;
  }

  Future<SearchResult> search({
    required String keyword,
    String authorUid = '0',
    String fid = '0',
    int page = 1,
  }) async {
    _state = SearchState.searching;
    ref.invalidateSelf();
    final ret = await _search(
      keyword: keyword,
      authorUid: authorUid,
      fid: fid,
      page: page,
    );
    _state = SearchState.notSearching;
    ref.invalidateSelf();
    return ret;
  }

  Future<SearchResult> _search({
    required String keyword,
    String authorUid = '0',
    String fid = '0',
    int page = 1,
  }) async {
    final queryParameters = {
      'id': 'Kahrpba:search',
      'query': keyword,
      'authorid': authorUid,
      'fid': fid,
      'page': page,
    };

    final resp = await ref
        .read(netClientProvider())
        .get(_searchUrl, queryParameters: queryParameters);

    if (resp.statusCode != HttpStatus.ok) {
      return const SearchResult.empty();
    }

    final document = parseHtmlDocument(resp.data as String);

    final threadList = document
        .querySelectorAll('div#ct > div#ct_shell > div#left_s > div.ts_se_rs')
        .map(SearchedThread.fromDivNode)
        .where((e) => e.isValid)
        .toList();

    /// Filter out "Results about: ".
    final count = document
        .querySelector('h3')
        ?.firstEndDeepText()
        ?.split(' ')
        .firstOrNull
        ?.parseToInt();

    final currentPage = document.currentPage() ?? 1;
    final totalPages = document.totalPages() ?? currentPage;

    return SearchResult(
      currentPage: currentPage,
      totalPages: totalPages,
      count: count,
      data: threadList,
    );
  }
}
