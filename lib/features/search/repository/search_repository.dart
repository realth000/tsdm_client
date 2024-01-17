import 'dart:io';

import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/shared/providers/server_time_provider/sevrer_time_provider.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

/// Repository of searching.
class SearchRepository {
  static const _searchUrl = '$baseUrl/plugin.php';

  /// An search action with given parameters:
  ///
  /// * [keyword]: Query keyword.
  /// * [fid]: Forum id, 0 represents any forum.
  /// * [uid]: Author user id, 0represents any user.
  /// * [pageNumber]: Page number of search result.
  ///
  /// # Exception
  ///
  /// * **HttpRequestFailedException** when search http requested failed.
  Future<uh.Document> searchWithParameters({
    required String keyword,
    required String fid,
    required String uid,
    required int pageNumber,
  }) async {
    //
    final queryParameters = <String, String>{
      'id': 'Kahrpba:search',
      'query': keyword,
      'authorid': uid,
      'fid': fid,
      'page': '$pageNumber',
    };

    final netClient = getIt.get<NetClientProvider>();
    final resp =
        await netClient.get(_searchUrl, queryParameters: queryParameters);
    if (resp.statusCode != HttpStatus.ok) {
      throw HttpRequestFailedException(resp.statusCode!);
    }

    final document = parseHtmlDocument(resp.data as String);
    getIt.get<ServerTimeProvider>().updateServerTimeWithDocument(document);
    return document;
  }
}
