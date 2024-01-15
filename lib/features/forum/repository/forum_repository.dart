import 'dart:io';

import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/shared/providers/server_time_provider/sevrer_time_provider.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

/// Repository of building a forum.
class ForumRepository {
  /// Fetch the html document of given [fid] at page [pageNumber].
  ///
  /// # Exception
  ///
  /// * **HttpRequestFailedException** if http request failed.
  Future<uh.Document> fetchForum({
    required String fid,
    int pageNumber = 1,
  }) async {
    final fetchUrl =
        '$baseUrl/forum.php?mod=forumdisplay&fid=$fid&page=$pageNumber';
    final netClient = getIt.get<NetClientProvider>();
    final resp = await netClient.get(fetchUrl);
    if (resp.statusCode != HttpStatus.ok) {
      throw HttpRequestFailedException(resp.statusCode!);
    }
    final document = parseHtmlDocument(resp.data as String);
    getIt.get<ServerTimeProvider>().updateServerTimeWithDocument(document);
    return document;
  }
}
