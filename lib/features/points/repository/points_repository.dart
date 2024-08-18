import 'dart:io' if (dart.libaray.js) 'package:web/web.dart';

import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/features/points/repository/model/models.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

/// Repository of points statistics page and points changelog page.
final class PointsRepository with LoggerMixin {
  static const _statisticsPageUrl =
      '$baseUrl/home.php?mod=spacecp&ac=credit&op=base';
  static const _changelogPageUrl =
      '$baseUrl/home.php?mod=spacecp&op=log&ac=credit';

  /// Fetch the points statistics page.
  ///
  /// # Exceptions
  ///
  /// * **HttpRequestFailedException** when http request failed.
  Future<uh.Document> fetchStatisticsPage() async {
    final netClient = getIt.get<NetClientProvider>();
    final resp = await netClient.get(_statisticsPageUrl);
    if (resp.statusCode != HttpStatus.ok) {
      throw HttpRequestFailedException(resp.statusCode);
    }

    final document = parseHtmlDocument(resp.data as String);
    return document;
  }

  /// Fetch the points changelog page with given [parameter].
  ///
  /// # Exceptions
  ///
  /// * **HttpRequestFailedException** when http request failed.
  Future<uh.Document> fetchChangelogPage(ChangelogParameter parameter) async {
    final netClient = getIt.get<NetClientProvider>();
    final target = '$_changelogPageUrl$parameter';
    info('fetch changelog page from $target');
    final resp = await netClient.get(target);
    if (resp.statusCode != HttpStatus.ok) {
      throw HttpRequestFailedException(resp.statusCode);
    }

    final document = parseHtmlDocument(resp.data as String);
    return document;
  }
}
