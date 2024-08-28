import 'dart:io' if (dart.library.js) 'package:web/web.dart';

import 'package:fpdart/fpdart.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/features/thread_publish/models/models.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

/// Repository for thread publish
///
/// * Fetch info when preparing page.
/// * Post new thread content to server.
final class ThreadPubRepository with LoggerMixin {
  /// Constructor.
  const ThreadPubRepository();

  static String _buildInfoUrl(String fid) =>
      '$homePage?mod=post&action=newthread&fid=$fid';

  static String _buildPostUrl(String fid) =>
      '$homePage?mod=post&action=newthread&fid=$fid&extra=&topicsubmit=yes';

  /// Fetch required info that used in posting new thread.
  ///
  /// This step is far before posting final thread content to server.
  AsyncEither<uh.Document> prepareInfo(String fid) => getIt
      .get<NetClientProvider>()
      .get(_buildInfoUrl(fid))
      .mapHttp((v) => parseHtmlDocument(v.data as String));

  /// Post new thread data to server.
  ///
  /// Generally the serer will response a status code of 301 with location in
  /// header to redirect to published thread page.
  AsyncEither<String> postThread(ThreadPublishInfo info) =>
      AsyncEither(() async {
        switch (await getIt
            .get<NetClientProvider>()
            .get(_buildPostUrl(info.fid))
            .run()) {
          case Left(:final value):
            return left(value);
          case Right(:final value)
              when value.statusCode != HttpStatus.movedPermanently:
            return left(ThreadPublishFailedException(value.statusCode!));
          case Right(:final value):
            if (value.headers.map.containsKey(HttpHeaders.locationHeader)) {
              error('location header not found in response');
              return left(ThreadPublishLocationNotFoundException());
            }
            final locations = value.headers.map[HttpHeaders.locationHeader];
            if (locations?.isEmpty ?? true) {
              error('empty location header');
              return left(ThreadPublishLocationNotFoundException());
            }
            return right(locations!.first);
        }
      });
}
