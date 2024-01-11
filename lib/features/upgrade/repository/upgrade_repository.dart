import 'dart:io';

import 'package:rxdart/rxdart.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/features/upgrade/repository/models/download_status.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

class UpgradeRepository {
  UpgradeRepository();

  static const _githubReleaseInfoUrl =
      'https://github.com/realth000/tsdm_client/releases/latest';
  static const _githubReleaseAssetUrl =
      'https://github.com/realth000/tsdm_client/releases/expanded_assets/';

  final _downloadStream = BehaviorSubject<DownloadStatus>();

  Stream<DownloadStatus> get downloadStatus =>
      _downloadStream.asBroadcastStream();

  String get releaseInfoUrl => _githubReleaseInfoUrl;

  /// Fetch the latest version info from github.
  ///
  /// # Exception
  ///
  /// * **[HttpRequestFailedException]** when request failed.
  Future<uh.Document> fetchLatestInfo() async {
    final resp =
        await NetClientProvider(disableCookie: true).get(_githubReleaseInfoUrl);
    if (resp.statusCode != HttpStatus.ok) {
      throw HttpRequestFailedException(resp.statusCode!);
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
    final resp = await NetClientProvider(disableCookie: true)
        .get('$_githubReleaseAssetUrl/$title');
    if (resp.statusCode != HttpStatus.ok) {
      throw HttpRequestFailedException(resp.statusCode!);
    }
    final document = parseHtmlDocument(resp.data as String);
    return document;
  }

  Future<void> download({
    required String downloadUrl,
    required String savePath,
  }) async {
    final netClient = NetClientProvider(disableCookie: true);
    await netClient.download(
      downloadUrl,
      savePath,
      onReceiveProgress: (recv, total) {
        _downloadStream.add(DownloadStatus(recv: recv, total: total));
        // downloadProgress = ((recv / total) * 100).toStringAsFixed(0);
      },
      deleteOnError: true,
    );
  }

  void dispose() {
    _downloadStream.close();
  }
}
