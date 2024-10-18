import 'dart:io' if (dart.libaray.js) 'package:web/web.dart';

import 'package:fpdart/fpdart.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/fp.dart';
import 'package:tsdm_client/features/notification/models/models.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

/// Repository of notification.
final class NotificationRepository with LoggerMixin {
  /// Build the url for notification v2 API.
  ///
  /// [timestamp] is optional timestamp of last call on this API.
  String _buildNotificationV2Url({int? timestamp}) {
    final now = DateTime.now();
    final int? argTimestamp;
    // The input [timestamp] is in seconds.
    final time = timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp * 1000)
        : now;
    if (timestamp != null &&
        0 <= now.difference(time).inDays &&
        now.difference(time).inDays <= 3) {
      argTimestamp = timestamp;
    } else {
      argTimestamp =
          now.add(const Duration(days: -3)).millisecondsSinceEpoch ~/ 1000;
    }

    return '$baseUrl/plugin.php?mobile=yes&tsdmapp=1&id=Kahrpba:usernotify&last_updated=$argTimestamp';
  }

  /// Get and parse a list of [Notice] from the given [url].
  ///
  /// * Return (List<Notice>, null) if success.
  /// * Return (null, resp.StatusCode) if http request failed.
  /// * Return (<Notice>[], null) if success but no notice found.
  AsyncEither<(List<Notice>?, int?)> _fetchNotice(
    NetClientProvider netClient,
    String url,
  ) =>
      AsyncEither(
        () async => netClient.get(url).map((value) {
          if (value.statusCode != HttpStatus.ok) {
            return (null, value.statusCode);
          }

          final document = parseHtmlDocument(value.data as String);

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
        }).run(),
      );

  /// Fetch notice from web server, including unread notices and read notices.
  AsyncEither<List<Notice>> fetchNotice() => AsyncEither(() async {
        final netClient = getIt.get<NetClientProvider>();

        final data = await Future.wait([
          _fetchNotice(netClient, noticeUrl).run(),
          _fetchNotice(netClient, readNoticeUrl).run(),
        ]);

        final d1 = data[0];
        final d2 = data[1];
        if (d1.isLeft()) {
          return left(d1.unwrapErr());
        }
        if (d2.isLeft()) {
          return left(d2.unwrapErr());
        }
        final d1d = d1.unwrap();
        final d2d = d2.unwrap();
        if (d1d.$2 != null) {
          return left(HttpRequestFailedException(d1d.$2));
        }
        if (d2d.$2 != null) {
          return left(HttpRequestFailedException(d2d.$2));
        }

        // Filter duplicate notices.
        // Only filter on reply type notices for now.
        final d3 = d1d.$1!.where(
          (x) =>
              x.redirectUrl == null ||
              !d2d.$1!.any((y) => y.redirectUrl == x.redirectUrl),
        );

        return right([...d3, ...?d2d.$1]);
      });

  /// Fetch the html document of notice detail page.
  AsyncEither<(uh.Document, String? page)> fetchDocument(String url) =>
      AsyncEither(
        () async =>
            switch (await getIt.get<NetClientProvider>().get(url).run()) {
          Left(:final value) => left(value),
          Right(:final value) when value.statusCode != HttpStatus.ok =>
            left(HttpRequestFailedException(value.statusCode)),
          Right(:final value) => right(
              (
                parseHtmlDocument(value.data as String),
                value.realUri.queryParameters['page']
              ),
            ),
        },
      );

  /// Fetch all personal messages from server page.
  AsyncEither<List<PersonalMessage>> fetchPersonalMessage() => AsyncEither(
        () async => switch (await getIt
            .get<NetClientProvider>()
            .get(personalMessageUrl)
            .run()) {
          Left(:final value) => left(value),
          Right(:final value) when value.statusCode != HttpStatus.ok =>
            left(HttpRequestFailedException(value.statusCode)),
          Right(:final value) => right(
              parseHtmlDocument(value.data as String)
                  .querySelectorAll('form#deletepmform > div > dl')
                  .map(PersonalMessage.fromDl)
                  .whereType<PersonalMessage>()
                  .toList(),
            )
        },
      );

  /// Fetch all broadcast messages from server page.
  AsyncEither<List<BroadcastMessage>> fetchBroadMessage() =>
      getIt.get<NetClientProvider>().get(broadcastMessageUrl).mapHttp(
            (v) => parseHtmlDocument(v.data as String)
                .querySelectorAll('form#deletepmform > div > dl')
                .map(BroadcastMessage.fromDl)
                .whereType<BroadcastMessage>()
                .toList(),
          );

  /// Fetch all kinds of notification using API v2.
  ///
  /// [timestamp] is the last time call this api (in seconds).
  AsyncEither<NotificationV2> fetchNotificationV2({int? timestamp}) => getIt
      .get<NetClientProvider>()
      .get(_buildNotificationV2Url(timestamp: timestamp))
      .mapHttp((v) => NotificationV2Mapper.fromJson(v.data as String));
}
