import 'dart:io';

import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/shared/providers/server_time_provider/server_time_provider.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

/// Repository of thread page of the app.
class ThreadRepository {
  String? _threadUrl;

  /// Getter to get the thread url.
  String? get threadUrl => _threadUrl;

  int? _pageNumber;

  /// getter of current thread page number.
  int? get pageNumber => _pageNumber;

  /// Fetch the thread page with [tid] on page [pageNumber].
  ///
  /// # Exception
  ///
  /// * **HttpRequestedFailedException** when http request failed.
  Future<uh.Document> fetchThread({
    required String tid,
    int pageNumber = 1,
    String? onlyVisibleUid,
    bool reverseOrder = false,
  }) async {
    /// Only visible uid.
    final visibleUid =
        onlyVisibleUid == null ? '' : '&authorid=$onlyVisibleUid';
    final orderType = reverseOrder ? '&ordertype=1' : '';
    _pageNumber = pageNumber;
    _threadUrl = '$baseUrl/forum.php?mod=viewthread&tid=$tid&extra=page%3D1'
        '$orderType$visibleUid'
        '&page=$pageNumber';

    final resp = await getIt.get<NetClientProvider>().get(_threadUrl!);
    if (resp.statusCode != HttpStatus.ok) {
      throw HttpRequestFailedException(resp.statusCode!);
    }

    final document = parseHtmlDocument(resp.data as String);
    getIt.get<ServerTimeProvider>().updateServerTimeWithDocument(document);
    return document;
  }
}
