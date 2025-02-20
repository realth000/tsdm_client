import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/features/points/repository/model/models.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

/// Repository of points statistics page and points changelog page.
final class PointsRepository with LoggerMixin {
  static const _statisticsPageUrl = '$baseUrl/home.php?mod=spacecp&ac=credit&op=base';
  static const _changelogPageUrl = '$baseUrl/home.php?mod=spacecp&op=log&ac=credit';

  /// Fetch the points statistics page.
  AsyncEither<uh.Document> fetchStatisticsPage() =>
      getIt.get<NetClientProvider>().get(_statisticsPageUrl).mapHttp((v) => parseHtmlDocument(v.data as String));

  /// Fetch the points changelog page with given [parameter].
  AsyncEither<uh.Document> fetchChangelogPage(ChangelogParameter parameter) => getIt
      .get<NetClientProvider>()
      .get('$_changelogPageUrl$parameter')
      .mapHttp((v) => parseHtmlDocument(v.data as String));
}
