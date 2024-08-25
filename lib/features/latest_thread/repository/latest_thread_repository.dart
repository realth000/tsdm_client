import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

/// Repository of the latest thread feature.
class LatestThreadRepository {
  /// Fetch html document from [url].
  AsyncEither<uh.Document> fetchDocument(String url) => getIt
      .get<NetClientProvider>()
      .get(url)
      .mapHttp((v) => parseHtmlDocument(v.data as String));
}
