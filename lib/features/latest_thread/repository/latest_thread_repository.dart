import 'dart:io';

import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

/// Repository of the latest thread feature.
class LatestThreadRepository {
  /// Fetch html document from [url].
  ///
  /// # Exception
  ///
  /// * **HttpRequestFailedException** when http request failed.
  Future<uh.Document> fetchDocument(String url) async {
    final resp = await getIt.get<NetClientProvider>().get(url);
    if (resp.statusCode != HttpStatus.ok) {
      throw HttpRequestFailedException(resp.statusCode);
    }
    final document = parseHtmlDocument(resp.data as String);
    return document;
  }
}
