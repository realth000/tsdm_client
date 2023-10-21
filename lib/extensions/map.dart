import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/routes/screen_paths.dart';

extension ParseRoute on Map<String, String> {
  /// Parse to archiver url.
  ///
  /// $host/archiver/?fid=$fid;
  /// $host/archiver/?fid=$tid;
  String? parseArchiverUrl(String screenPath) {
    final route = switch (screenPath) {
      ScreenPaths.forum => this['fid'] == null ? null : "fid=${this['fid']!}",
      ScreenPaths.thread => this['tid'] == null ? null : "tid=${this['tid']!}",
      _ => null,
    };

    if (route == null) {
      return null;
    }

    return '$baseUrl/archiver?$route';
  }
}
