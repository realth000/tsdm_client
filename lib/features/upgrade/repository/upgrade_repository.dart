import 'dart:io' if (dart.libaray.js) 'package:web/web.dart';

import 'package:dio/dio.dart';
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

  /// Get url of realse info.
  String get releaseInfoUrl => _githubReleaseInfoUrl;

  /// Fetch the latest version info from github.
  ///
  /// # Exception
  ///
  /// * **[HttpRequestFailedException]** when request failed.
  Future<uh.Document> fetchLatestInfo() async {
    final resp = await getIt
        .get<NetClientProvider>(instanceName: ServiceKeys.noCookie)
        .get(_githubReleaseInfoUrl);
    if (resp.statusCode != HttpStatus.ok) {
      throw HttpRequestFailedException(resp.statusCode);
    }

    final document = parseHtmlDocument(resp.data as String);
    return document;
  }

  /// Fetch the assets info with tag [title].
  ///
  /// # Exception
  ///
  /// * **[HttpRequestFailedException]** when request failed.
  Future<uh.Document> fetchAssetsInfo(String title) async {
    final resp = await getIt
        .get<NetClientProvider>(instanceName: ServiceKeys.noCookie)
        .get('$_githubReleaseAssetUrl/$title');
    if (resp.statusCode != HttpStatus.ok) {
      throw HttpRequestFailedException(resp.statusCode);
    }
    final document = parseHtmlDocument(resp.data as String);
    return document;
  }

  /// Download assets from [downloadUrl] and save to [savePath].
  Future<void> download({
    required String downloadUrl,
    required String savePath,
  }) async {
    final netClient =
        getIt.get<NetClientProvider>(instanceName: ServiceKeys.noCookie);
    await netClient.download(
      downloadUrl,
      savePath,
      onReceiveProgress: (recv, total) {
        _downloadStream.add(DownloadStatus(recv: recv, total: total));
        // downloadProgress = ((recv / total) * 100).toStringAsFixed(0);
      },
    );
  }

  /// Fetch the full changelog of the app.
  Future<String?> fetchChangelog() async {
    final netClient =
        getIt.get<NetClientProvider>(instanceName: ServiceKeys.noCookie);
    try {
      final resp = await netClient.get(_rawChangelogUrl);
      final data = resp.data as String;
      return data;
    } on DioException catch (e) {
      debug('failed to load raw changelog: $e');
    }
    return null;
  }

  /// Dispose the stream.
  void dispose() {
    _downloadStream.close();
  }
}
