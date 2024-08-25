import 'package:fpdart/fpdart.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/fp.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

/// A repository that fetches the homepage html data from website.
final class ForumHomeRepository with LoggerMixin {
  /// Cached document of forum homepage.
  uh.Document? _document;

  /// Check has cached html [_document] or not.
  bool hasCache() => _document != null;

  /// Get the cached [_document].
  uh.Document? getCache() => _document;

  /// Fetch the home page of app from server.
  AsyncEither<uh.Document> fetchHomePage({bool force = false}) =>
      AsyncEither(() async {
        debug('fetch home page');
        if (!force && _document != null) {
          debug('use cached home page');
          return right(_document!);
        }

        final docEither = await _fetchForumHome().run();
        if (docEither.isLeft()) {
          return left(docEither.unwrapErr());
        }

        _document = docEither.unwrap();
        debug('use fetched home page');
        return right(_document!);
      });

  /// Fetch the topic page of app from server.
  AsyncEither<uh.Document> fetchTopicPage({bool force = false}) =>
      AsyncEither(() async {
        debug('fetch topics page');
        if (!force && _document != null) {
          debug('use cached topics page');
          return right(_document!);
        }
        final e = await _fetchForumHome().run();
        if (e.isLeft()) {
          return left(e.unwrapErr());
        }
        _document = e.unwrap();
        return right(_document!);
      });

  /// Fetch the [homePage] of forum.
  ///
  /// # Exception
  ///
  /// * [HttpHandshakeFailedException] if GET request failed.
  AsyncEither<uh.Document> _fetchForumHome() => getIt
      .get<NetClientProvider>()
      .get(homePage)
      .mapHttp((v) => parseHtmlDocument(v.data as String));
}
