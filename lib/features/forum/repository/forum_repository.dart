import 'dart:io';

import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/features/forum/models/models.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
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
    required FilterState filterState,
    int pageNumber = 1,
  }) async {
    final fetchUrl = _formatForumUrl(fid, pageNumber, filterState);
    final netClient = getIt.get<NetClientProvider>();
    final resp = await netClient.getUri(fetchUrl);
    if (resp.statusCode != HttpStatus.ok) {
      throw HttpRequestFailedException(resp.statusCode);
    }
    final document = parseHtmlDocument(resp.data as String);
    return document;
  }

  Uri _formatForumUrl(
    String fid,
    int pageNumber,
    FilterState filterState,
  ) {
    final queryMap = {
      'mod': 'forumdisplay',
      'fid': fid,
      'page': '$pageNumber',
    };

    // Recommend flag checking MUST before the check of thread order as
    // order will be changed if recommend filter is on, we do this behave
    // similar with what the browser side does.
    if (filterState.filterRecommend.recommend) {
      queryMap['recommend'] = '1';
      queryMap['orderby'] = 'recommends';
    }
    if (filterState.filter != null) {
      queryMap['filter'] = filterState.filter!;
    }
    if (filterState.filterType?.typeID != null) {
      queryMap['typeid'] = filterState.filterType!.typeID!;
    }
    if (filterState.filterSpecialType?.specialType != null) {
      queryMap['specialtype'] = filterState.filterSpecialType!.specialType!;
    }
    if (filterState.filterOrder?.orderBy != null) {
      queryMap['orderby'] = filterState.filterOrder!.orderBy!;
    }
    if (filterState.filterDateline?.dateline != null) {
      queryMap['dateline'] = filterState.filterDateline!.dateline!;
    }
    if (filterState.filterDigest.digest) {
      queryMap['digest'] = '1';
    }

    return Uri.https(
      'tsdm39.com',
      '/forum.php',
      queryMap,
    );
  }
}
