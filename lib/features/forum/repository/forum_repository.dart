import 'dart:io' if (dart.libaray.js) 'package:web/web.dart';

import 'package:fpdart/fpdart.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/fp.dart';
import 'package:tsdm_client/features/forum/models/models.dart';
import 'package:tsdm_client/features/forum/utils/group.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

/// Repository of building a forum.
class ForumRepository {
  /// Fetch the html document of given [fid] at page [pageNumber].
  ///
  AsyncEither<uh.Document> fetchForum({required String fid, required FilterState filterState, int pageNumber = 1}) =>
      AsyncEither(() async {
        final fetchUrl = _formatForumUrl(fid, pageNumber, filterState);
        final netClient = getIt.get<NetClientProvider>();
        final respEither = await netClient.getUri(fetchUrl).run();
        if (respEither.isLeft()) {
          return left(respEither.unwrapErr());
        }
        final resp = respEither.unwrap();
        if (resp.statusCode != HttpStatus.ok) {
          return left(HttpRequestFailedException(resp.statusCode));
        }
        final document = parseHtmlDocument(resp.data as String);
        return right(document);
      });

  Uri _formatForumUrl(String fid, int pageNumber, FilterState filterState) {
    final queryMap = {'mod': 'forumdisplay', 'fid': fid, 'page': '$pageNumber'};

    // Recommend flag checking MUST before the check of thread order as
    // order will be changed if recommend filter is on, we do this behave
    // similar with what the browser side does.
    if (filterState.filterRecommend.recommend) {
      queryMap['recommend'] = '1';
      queryMap['orderby'] = 'recommends';
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

    // Only set 'filter' query parameter when the filter is actually applied.
    if (filterState.filter != null && queryMap.containsKey(filterState.filter)) {
      queryMap['filter'] = filterState.filter!;
    }

    return Uri.https('tsdm39.com', '/forum.php', queryMap);
  }

  /// Fetch the page data on a forum group specified by group id [gid].
  AsyncEither<ForumGroup?> fetchForumGroup(String gid) => getIt
      .get<NetClientProvider>()
      .get('$baseUrl/forum.php?gid=$gid')
      .mapHttp((v) => v.data as String)
      .map(parseHtmlDocument)
      .map(buildGroupListFromDocument)
      .map((v) => v.firstOrNull);
}
