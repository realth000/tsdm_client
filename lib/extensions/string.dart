import 'package:flutter/cupertino.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:uuid/uuid.dart';

const Uuid _uuid = Uuid();

/// Result when parsing [String] to route succeed.
@immutable
class RecognizedRoute {
  const RecognizedRoute(
    this.screenPath, {
    this.pathParameters = const {},
    this.queryParameters = const {},
  });

  final String screenPath;
  final Map<String, String> pathParameters;
  final Map<String, String> queryParameters;
}

extension ParseUrl on String {
  /// Try parse string to [RecognizedRoute] with arguments.
  /// Return null if string is unsupported route.
  RecognizedRoute? parseUrlToRoute() {
    final url = Uri.parse(this);
    final queryParameters = url.queryParameters;
    final mod = queryParameters['mod'];

    if (mod == 'forumdisplay' && queryParameters.containsKey('fid')) {
      return RecognizedRoute(
        ScreenPaths.forum,
        pathParameters: {'fid': "${queryParameters['fid']}"},
      );
    }

    if (mod == 'viewthread' && queryParameters.containsKey('tid')) {
      return RecognizedRoute(
        ScreenPaths.thread,
        pathParameters: {'tid': "${queryParameters['tid']}"},
      );
    }

    if (mod == 'space' &&
        queryParameters['do'] == 'thread' &&
        queryParameters['view'] == 'me') {
      return const RecognizedRoute(ScreenPaths.myThread);
    }

    if (mod == 'forum' && queryParameters['srchfrom'] != null) {
      return RecognizedRoute(
        ScreenPaths.latestThread,
        queryParameters: {'url': prependHost()},
      );
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

  String trimTitle() {
    return replaceFirst(' -  天使动漫论坛 - 梦开始的地方  -  Powered by Discuz!', '');
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
