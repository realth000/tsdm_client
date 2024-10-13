import 'dart:io' if (dart.libaray.js) 'package:web/web.dart';

import 'package:fpdart/fpdart.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/fp.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/features/notification/models/models.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

/// Result of loading progress of a notification type page.
class NoticeResult<T> {
  /// Constructor.
  const NoticeResult({
    required this.notificationList,
    required this.pageNumber,
    required this.hasNextPage,
  });

  /// Empty result
  factory NoticeResult.empty() => NoticeResult<T>(
        notificationList: [],
        pageNumber: 1,
        hasNextPage: false,
      );

  /// All notice.
  final List<T> notificationList;

  /// Current loaded page.
  final int pageNumber;

  /// Flag indicating has next page or not
  final bool hasNextPage;
}

/// Repository of notification.
final class NotificationRepository with LoggerMixin {
  /// Get and parse a list of [Notice] from the given [url].
  ///
  /// * Return Notice<Result<Notice>> if success.
  /// * Return resp.StatusCode if http request failed.
  AsyncEither<Either<int?, NoticeResult<Notice>>> _fetchNotice(
    NetClientProvider netClient,
    String url,
  ) =>
      AsyncEither(
        () async =>
            netClient.get(url).map<Either<int?, NoticeResult<Notice>>>((value) {
          if (value.statusCode != HttpStatus.ok) {
            return Left(value.statusCode);
          }

          final document = parseHtmlDocument(value.data as String);

          // Check if empty
          final emptyNode =
              document.querySelector('div#ct > div.mn > div.bm.bw0 > div.emp');
          if (emptyNode != null) {
            error('empty notice');
            // No notice here.
            return Right(NoticeResult<Notice>.empty());
          }

          final noticeList = document
              .querySelectorAll(
                'div#ct div.mn > div.bm.bw0 > div.xld.xlda > div.nts > dl.cl',
              )
              .map(Notice.fromClNode)
              .whereType<Notice>()
              .toList();

          final pageNumber = document.currentPage() ?? 1;
          final hasNextPage = (document.totalPages() ?? -1) > pageNumber;

          return Right(
            NoticeResult<Notice>(
              notificationList: noticeList,
              pageNumber: pageNumber,
              hasNextPage: hasNextPage,
            ),
          );
        }).run(),
      );

  /// Fetch notice from web server, including unread notices and read notices.
  AsyncEither<NoticeResult<Notice>> fetchNotice({int? page}) =>
      AsyncEither(() async {
        final netClient = getIt.get<NetClientProvider>();

        final data = await Future.wait([
          _fetchNotice(
            netClient,
            '$noticeUrl${page != null ? "&page=$page" : null}',
          ).run(),
          _fetchNotice(
            netClient,
            '$readNoticeUrl${page != null ? "&page=$page" : null}',
          ).run(),
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
        if (d1d.isLeft()) {
          return Left(HttpRequestFailedException(d1d.unwrapErr()));
        }
        if (d2d.isLeft()) {
          return Left(HttpRequestFailedException(d2d.unwrapErr()));
        }

        final d2dd = d2d.unwrap();

        // Filter duplicate notices.
        // Only filter on reply type notices for now.
        final d3 = d1d.unwrap().notificationList.where(
              (x) =>
                  x.redirectUrl == null ||
                  d2dd.notificationList
                      .any((y) => y.redirectUrl == x.redirectUrl),
            );

        return right(
          NoticeResult(
            notificationList: [...d3, ...d2dd.notificationList],
            pageNumber: d2dd.pageNumber,
            hasNextPage: d2dd.hasNextPage,
          ),
        );
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
  AsyncEither<Either<int?, NoticeResult<PersonalMessage>>>
      fetchPersonalMessage({
    int? page,
  }) =>
          AsyncEither(() async {
            final result = await getIt
                .get<NetClientProvider>()
                .get(
                  '$personalMessageUrl${page != null ? "&page=$page" : null}',
                )
                .run();
            if (result.isLeft()) {
              return Left(result.unwrapErr());
            }

            final resultR = result.unwrap();
            if (resultR.statusCode != HttpStatus.ok) {
              return Left(HttpRequestFailedException(resultR.statusCode));
            }

            final document = parseHtmlDocument(resultR.data as String);
            final noticeList = document
                .querySelectorAll('form#deletepmform > div > dl')
                .map(PersonalMessage.fromDl)
                .whereType<PersonalMessage>()
                .toList();

            final pageNumber = document.currentPage() ?? 1;
            final hasNextPage = (document.totalPages() ?? -1) > pageNumber;

            return Right(
              Right(
                NoticeResult<PersonalMessage>(
                  notificationList: noticeList,
                  pageNumber: pageNumber,
                  hasNextPage: hasNextPage,
                ),
              ),
            );
          });

  /// Fetch all broadcast messages from server page.
  AsyncEither<Either<int?, NoticeResult<BroadcastMessage>>> fetchBroadMessage({
    int? page,
  }) =>
      getIt
          .get<NetClientProvider>()
          .get('$broadcastMessageUrl${page != null ? "&page=$page" : ""}')
          .mapHttp(
        (v) {
          final document = parseHtmlDocument(v.data as String);
          final noticeList = document
              .querySelectorAll('form#deletepmform > div > dl')
              .map(BroadcastMessage.fromDl)
              .whereType<BroadcastMessage>()
              .toList();

          final pageNumber = document.currentPage() ?? 1;
          final hasNextPage = (document.totalPages() ?? -1) > pageNumber;
          return Right(
            NoticeResult<BroadcastMessage>(
              notificationList: noticeList,
              pageNumber: pageNumber,
              hasNextPage: hasNextPage,
            ),
          );
        },
      );
}
