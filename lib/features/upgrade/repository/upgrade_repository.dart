import 'package:rxdart/rxdart.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/features/upgrade/repository/models/models.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/shared/providers/providers.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

const _rawChangelogUrl =
    'https://raw.githubusercontent.com/realth000/tsdm_client/master/CHANGELOG.md';

/// Repository of upgrading the app.
final class UpgradeRepository with LoggerMixin {
  /// Constructor.
  UpgradeRepository();

  static const _githubReleaseInfoUrl =
      'https://github.com/realth000/tsdm_client/releases/latest';
  static const _githubReleaseAssetUrl =
      'https://github.com/realth000/tsdm_client/releases/expanded_assets/';

  final _downloadStream = BehaviorSubject<DownloadStatus>();

  /// Get the [Stream] of download status.
  Stream<DownloadStatus> get downloadStatus =>
      _downloadStream.asBroadcastStream();

  /// Get url of release info.
  String get releaseInfoUrl => _githubReleaseInfoUrl;

  /// Fetch the latest version info from github.
  AsyncEither<uh.Document> fetchLatestInfo() => getIt
      .get<NetClientProvider>(instanceName: ServiceKeys.noCookie)
      .get(_githubReleaseInfoUrl)
      .mapHttp((v) => parseHtmlDocument(v.data as String));

  /// Fetch the assets info with tag [title].
  AsyncEither<uh.Document> fetchAssetsInfo(String title) => getIt
      .get<NetClientProvider>(instanceName: ServiceKeys.noCookie)
      .get('$_githubReleaseAssetUrl/$title')
      .mapHttp((v) => parseHtmlDocument(v.data as String));

  /// Download assets from [downloadUrl] and save to [savePath].
  AsyncVoidEither download({
    required String downloadUrl,
    required String savePath,
  }) =>
      getIt.get<NetClientProvider>(instanceName: ServiceKeys.noCookie).download(
        downloadUrl,
        savePath,
        onReceiveProgress: (recv, total) {
          _downloadStream.add(DownloadStatus(recv: recv, total: total));
          // downloadProgress = ((recv / total) * 100).toStringAsFixed(0);
        },
      );

  /// Fetch the full changelog of the app.
  AsyncEither<String> fetchChangelog() => getIt
      .get<NetClientProvider>(instanceName: ServiceKeys.noCookie)
      .get(_rawChangelogUrl)
      .mapHttp((v) => v.data as String);

  /// Dispose the stream.
  void dispose() {
    _downloadStream.close();
  }
}
