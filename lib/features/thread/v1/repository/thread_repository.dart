import 'dart:io' if (dart.libaray.js) 'package:web/web.dart';

import 'package:fpdart/fpdart.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/fp.dart';
import 'package:tsdm_client/features/thread/v1/models/models.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
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

  String _buildOperationUrl(String tid) =>
      '$baseUrl/forum.php?mod=misc&action=viewthreadmod&tid=$tid'
          '&infloat=yes&handlekey=viewthreadmod&inajax=1&ajaxtarget=fwin_content_viewthreadmod';

  /// Fetch the thread page with [tid] on page [pageNumber].
  ///
  /// # Exception
  ///
  /// * **HttpRequestedFailedException** when http request failed.
  AsyncEither<uh.Document> fetchThread({
    String? tid,
    String? pid,
    int pageNumber = 1,
    String? onlyVisibleUid,
    bool? reverseOrder,
    int? exactOrder,
  }) =>
      AsyncEither(() async {
        assert(tid != null || pid != null, 'tid and pid MUST not be null at the same time');

        /// Only visible uid.
        final visibleUid = onlyVisibleUid == null ? '' : '&authorid=$onlyVisibleUid';
        // ordertype: Control sort of post floors.
        // 1: desc (latest post first)
        // 2: asc (oldest post first)
        //
        // Some threads defined reverse order (latest post first) as default
        // post order, it's hard to detect the default order of a thread.
        //
        // Instead, always set `ordertype` query parameter to ensure all threads
        // are in the same default order.
        //
        // And in some situation, do NOT force reverse order, like user is going
        // to find a post in a certain page number, in this use case a manually
        // other override may going into different page that does NOT contain
        // the target post.
        final orderType = switch ((exactOrder, reverseOrder)) {
          (final int i, _) => '&ordertype=$i',
          (null, true) => '&ordertype=1',
          (null, false) => '&ordertype=2',
          (null, null) => '',
        };

        _pageNumber = pageNumber;
        if (tid != null) {
          _threadUrl =
          '$baseUrl/forum.php?mod=viewthread&tid=$tid&extra=page%3D1'
              '$orderType$visibleUid'
              '&page=$pageNumber';
        } else {
          // The page came from where we redirect by finding a post.
          _threadUrl = '$baseUrl/forum.php?mod=redirect&goto=findpost&pid=$pid';
        }

        final respEither = await getIt.get<NetClientProvider>().get(_threadUrl!).run();
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

  /// Fetch the operation log for thread [tid].
  AsyncEither<List<OperationLogItem>> fetchOperationLog(String tid) =>
      getIt.get<NetClientProvider>().get(_buildOperationUrl(tid)).mapHttp((resp) {
        final htmlData = parseXmlDocument(resp.data as String).documentElement?.nodes.first.text;
        if (htmlData == null) {
          // Safe to throw because we use it in a future builder.
          throw Exception('html data not found');
        }

        final doc = parseHtmlDocument(htmlData);
        final items =
        doc.querySelectorAll('table tr').map(OperationLogItem.fromTr).whereType<OperationLogItem>().toList();
        return items;
      });
}
