import 'dart:io';

import 'package:dio/dio.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

/// A repository that fetches the homepage html data from website.
final class ForumHomeRepository with LoggerMixin {
  /// Cached document of forum homepage.
  uh.Document? _document;

  /// Check has cached html [_document] or not.
  bool hasCache() => _document != null;

  /// Get the cached [_document].
  uh.Document? getCache() => _document;

  /// Fetch the home page of app from server.
  ///
  /// # Exception
  ///
  /// * [HttpRequestFailedException] if GET request failed.
  Future<uh.Document> fetchHomePage({bool force = false}) async {
    debug('fetch home page');
    if (!force && _document != null) {
      debug('use cached home page');
      return _document!;
    }
    try {
      _document = await _fetchForumHome();
      debug('use fetched home page');
      return _document!;
    } on HttpRequestFailedException {
      rethrow;
    }
  }

  /// Fetch the topic page of app from server.
  ///
  /// # Exception
  ///
  /// * [HttpRequestFailedException] if GET request failed.
  Future<uh.Document> fetchTopicPage({bool force = false}) async {
    debug('fetch topics page');
    if (!force && _document != null) {
      debug('use cached topics page');
      return _document!;
    }
    try {
      _document = await _fetchForumHome();
      return _document!;
    } on HttpRequestFailedException {
      rethrow;
    }
  }

  /// Fetch the [homePage] of forum.
  ///
  /// # Exception
  ///
  /// * [HttpHandshakeFailedException] if GET request failed.
  Future<uh.Document> _fetchForumHome() async {
    debug('fetch forum home from server');
    final netClient = getIt.get<NetClientProvider>();
    try {
      final resp = await netClient.get(homePage);
      if (resp.statusCode != HttpStatus.ok) {
        throw HttpRequestFailedException(resp.statusCode);
      }
      final document = parseHtmlDocument(resp.data as String);
      return document;
    } on DioException catch (e) {
      throw HttpHandshakeFailedException('handshake failed: $e');
    }
  }
}
