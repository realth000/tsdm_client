import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/routes/app_routes.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:uuid/uuid.dart';

const Uuid _uuid = Uuid();

extension ParseUrl on String {
  /// Try parse string to [AppRoute] with arguments.
  (String, Map<String, String>)? parseUrlToRoute() {
    final fidRe = RegExp(r'fid=(?<Fid>\d+)');
    final fidMatch = fidRe.firstMatch(this);
    if (fidMatch != null) {
      return (ScreenPaths.forum, {'fid': "${fidMatch.namedGroup('Fid')}"});
    }

    final tidRe = RegExp(r'tid=(?<Tid>\d+)');
    final tidMatch = tidRe.firstMatch(this);
    if (tidMatch != null) {
      return (ScreenPaths.thread, {'tid': "${tidMatch.namedGroup('Tid')}"});
    }

    return null;
  }

  /// Parse self as an uri and return the value of parameter [name].
  String? uriQueryParameter(String name) {
    return Uri.parse(this).queryParameters[name];
  }
}

extension EnhanceModification on String {
  /// Prepend [prefix].
  String? prepend(String prefix) {
    return '$prefix$this';
  }

  /// Prepend host url.
  String prependHost() {
    return '$baseUrl/$this';
  }

  /// Truncate string at position [size].
  ///
  /// If [length] is smaller than [size], return the whole string.
  String truncate(int size, {bool ellipsis = false}) {
    return length > size
        ? '${substring(0, size)}${ellipsis ? "..." : ""}'
        : this;
  }
}

extension ParseStringTo on String {
  int? parseToInt() {
    return int.parse(this);
  }

  DateTime? parseToDateTimeUtc8() {
    final datePartList = split('-');
    if (datePartList.length != 3) {
      // Should not happen.
      return DateTime.tryParse(this);
    }
    final formattedDateString =
        '${datePartList[0]}-${datePartList[1].padLeft(2, '0')}-${datePartList[2].padLeft(2, '0')}';
    return DateTime.tryParse(formattedDateString);
  }
}

extension ImageCacheFileName on String {
  String fileNameV5() {
    return _uuid.v5(Namespace.URL, this);
  }
}
