import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/routes/app_routes.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:uuid/uuid.dart';

const Uuid _uuid = Uuid();

extension ParseUrl on String {
  /// Try parse string to [AppRoute] with arguments.
  (String, Map<String, String>)? parseUrlToRoute() {
    final url = Uri.parse(this);
    final mod = url.queryParameters['mod'];

    if (mod == 'forumdisplay' && url.queryParameters.containsKey('fid')) {
      return (ScreenPaths.forum, {'fid': "${url.queryParameters['fid']}"});
    }

    if (mod == 'viewthread' && url.queryParameters.containsKey('tid')) {
      return (ScreenPaths.thread, {'tid': "${url.queryParameters['tid']}"});
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
    return int.tryParse(this);
  }

  /// Parse "yyyy-MM-DD HH:mm:ss" or "yyyy-MM-DD" format to string.
  /// Allow "yyyy-M-D", fill to "yyyy-MM-DD" format.
  DateTime? parseToDateTimeUtc8() {
    final list = split(' ');
    if (list.isEmpty || list.length > 2) {
      return null;
    }
    final timePart = list.elementAtOrNull(1);

    final datePartList = list[0].split('-');
    if (datePartList.length != 3) {
      // Should not happen.
      return DateTime.tryParse(this);
    }
    final formattedDateString =
        '${datePartList[0]}-${datePartList[1].padLeft(2, '0')}-${datePartList[2].padLeft(2, '0')}';
    return DateTime.tryParse(
      timePart == null ? formattedDateString : '$formattedDateString $timePart',
    );
  }
}

extension ImageCacheFileName on String {
  String fileNameV5() {
    return _uuid.v5(Namespace.URL, this);
  }
}
