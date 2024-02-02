import 'dart:io';

import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/features/notification/models/notice.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/shared/providers/server_time_provider/server_time_provider.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

/// Repository of notification.
class NotificationRepository {
  /// Get and parse a list of [Notice] from the given [url].
  ///
  /// * Return (List<Notice>, null) if success.
  /// * Return (null, resp.StatusCode) if http request failed.
  /// * Return (<Notice>[], null) if success but no notice found.
  Future<(List<Notice>?, int?)> _fetchNotice(
    NetClientProvider netClient,
    String url,
  ) async {
    final resp = await netClient.get(url);
    if (resp.statusCode != HttpStatus.ok) {
      return (null, resp.statusCode);
    }
    final document = parseHtmlDocument(resp.data as String);
    getIt.get<ServerTimeProvider>().updateServerTimeWithDocument(document);

    // Check if empty
    final emptyNode =
        document.querySelector('div#ct > div.mn > div.bm.bw0 > div.emp');
    if (emptyNode != null) {
      debug('empty notice');
      // No notice here.
      return (<Notice>[], null);
    }

    final noticeList = document
        .querySelectorAll(
          'div#ct div.mn > div.bm.bw0 > div.xld.xlda > div.nts > dl.cl',
        )
        .map(Notice.fromClNode)
        .whereType<Notice>()
        .toList();
    return (noticeList, null);
  }

  /// Fetch notice from web server, including unread notices and read notices.
  ///
  /// # Exception
  ///
  /// * **HttpRequestFailedException** when any http request failed.
  Future<List<Notice>> fetchNotice() async {
    final netClient = getIt.get<NetClientProvider>();

    final data = await Future.wait([
      _fetchNotice(netClient, noticeUrl),
      _fetchNotice(netClient, readNoticeUrl),
    ]);

    final d1 = data[0];
    final d2 = data[1];
    if (d1.$2 != null) {
      throw HttpRequestFailedException(d1.$2!);
    }
    if (d2.$2 != null) {
      throw HttpRequestFailedException(d2.$2!);
    }

    // Filter duplicate notices.
    // Only filter on reply type notices for now.
    final d3 = d1.$1!.where(
      (x) =>
          x.redirectUrl == null ||
          !d2.$1!.any((y) => y.redirectUrl == x.redirectUrl),
    );

    return [...d3, ...?d2.$1];
  }

  /// Fetch the html document of notice detail page.
  ///
  /// # Exception
  ///
  /// * **HttpRequestFailedException** when http request failed.
  Future<(uh.Document, String? page)> fetchNoticeDetail(String url) async {
    final resp = await getIt.get<NetClientProvider>().get(url);
    if (resp.statusCode != HttpStatus.ok) {
      throw HttpRequestFailedException(resp.statusCode!);
    }

    final document = parseHtmlDocument(resp.data as String);
    getIt.get<ServerTimeProvider>().updateServerTimeWithDocument(document);
    return (document, resp.realUri.queryParameters['page']);
  }
}
