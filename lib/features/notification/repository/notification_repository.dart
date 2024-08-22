import 'dart:io' if (dart.libaray.js) 'package:web/web.dart';

import 'package:fpdart/fpdart.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/features/notification/models/models.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

/// Repository of notification.
final class NotificationRepository with LoggerMixin {
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

    // Check if empty
    final emptyNode =
        document.querySelector('div#ct > div.mn > div.bm.bw0 > div.emp');
    if (emptyNode != null) {
      error('empty notice');
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
  AsyncEither<List<Notice>> fetchNotice() => AsyncEither(() async {
        final netClient = getIt.get<NetClientProvider>();

        final data = await Future.wait([
          _fetchNotice(netClient, noticeUrl),
          _fetchNotice(netClient, readNoticeUrl),
        ]);

        final d1 = data[0];
        final d2 = data[1];
        if (d1.$2 != null) {
          return left(HttpRequestFailedException(d1.$2));
        }
        if (d2.$2 != null) {
          return left(HttpRequestFailedException(d2.$2));
        }

        // Filter duplicate notices.
        // Only filter on reply type notices for now.
        final d3 = d1.$1!.where(
          (x) =>
              x.redirectUrl == null ||
              !d2.$1!.any((y) => y.redirectUrl == x.redirectUrl),
        );

        return right([...d3, ...?d2.$1]);
      });

  /// Fetch the html document of notice detail page.
  AsyncEither<(uh.Document, String? page)> fetchDocument(String url) =>
      AsyncEither(() async {
        final resp = await getIt.get<NetClientProvider>().get(url);
        if (resp.statusCode != HttpStatus.ok) {
          return left(HttpRequestFailedException(resp.statusCode));
        }

        final document = parseHtmlDocument(resp.data as String);
        return right((document, resp.realUri.queryParameters['page']));
      });

  /// Fetch all personal messages from server page.
  AsyncEither<List<PersonalMessage>> fetchPersonalMessage() =>
      AsyncEither(() async {
        final resp =
            await getIt.get<NetClientProvider>().get(personalMessageUrl);
        if (resp.statusCode != HttpStatus.ok) {
          return left(HttpRequestFailedException(resp.statusCode));
        }

        final document = parseHtmlDocument(resp.data as String);

        return right(
          document
              .querySelectorAll('form#deletepmform > div > dl')
              .map(PersonalMessage.fromDl)
              .whereType<PersonalMessage>()
              .toList(),
        );
      });

  /// Fetch all broadcast messages from server page.
  ///
  /// # Exception
  ///
  /// * **HttpRequestFailedException** when http request failed.
  AsyncEither<List<BroadcastMessage>> fetchBroadMessage() =>
      AsyncEither(() async {
        final resp =
            await getIt.get<NetClientProvider>().get(broadcastMessageUrl);
        if (resp.statusCode != HttpStatus.ok) {
          return left(HttpRequestFailedException(resp.statusCode));
        }

        final document = parseHtmlDocument(resp.data as String);

        return right(
          document
              .querySelectorAll('form#deletepmform > div > dl')
              .map(BroadcastMessage.fromDl)
              .whereType<BroadcastMessage>()
              .toList(),
        );
      });
}
