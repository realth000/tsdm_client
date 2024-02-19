import 'dart:convert';

import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/features/post/models/post_edit_type.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:uuid/uuid.dart';

const Uuid _uuid = Uuid();

/// Result when parsing [String] to route succeed.
///
/// Represents a route that can be directed to.
class RecognizedRoute {
  /// Constructor.
  const RecognizedRoute(
    this.screenPath, {
    this.pathParameters = const {},
    this.queryParameters = const {},
  });

  /// Available screen path that defines in `screen_path.dart`.
  final String screenPath;

  /// Path parameters of the route.
  final Map<String, String> pathParameters;

  /// Query parameters of the route.
  final Map<String, String> queryParameters;
}

/// Extension on [String] that provides methods to parsing [String] as app
/// routes.
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
        queryParameters: {'tid': "${queryParameters['tid']}"},
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

    if (mod == 'redirect' && queryParameters['tid'] != null) {
      return RecognizedRoute(
        ScreenPaths.thread,
        queryParameters: {'tid': "${queryParameters['tid']}"},
      );
    }

    if (mod == 'redirect' &&
        queryParameters['goto'] == 'findpost' &&
        queryParameters['pid'] != null) {
      return RecognizedRoute(
        ScreenPaths.thread,
        queryParameters: {'pid': "${queryParameters['pid']}"},
      );
    }

    if (mod == 'space') {
      // Access by uid.
      if (queryParameters['uid'] != null) {
        return RecognizedRoute(
          ScreenPaths.profile,
          queryParameters: {'uid': '${queryParameters["uid"]}'},
        );
      }

      // Access by username.
      if (queryParameters['username'] != null) {
        return RecognizedRoute(
          ScreenPaths.profile,
          queryParameters: {'username': '${queryParameters["username"]}'},
        );
      }
    }

    // Edit post.
    if (mod == 'post' &&
        queryParameters['action'] == 'edit' &&
        queryParameters['fid'] != null &&
        queryParameters['pid'] != null &&
        queryParameters['pid'] != null) {
      return RecognizedRoute(
        ScreenPaths.editPost,
        pathParameters: {
          'editType': '${PostEditType.editPost.index}',
          'fid': '${queryParameters["fid"]}',
          'tid': '${queryParameters["tid"]}',
          'pid': '${queryParameters["pid"]}',
        },
      );
    }

    return null;
  }

  /// Parse self as an uri and return the value of parameter [name].
  String? uriQueryParameter(String name) {
    return Uri.parse(this).queryParameters[name];
  }
}

/// Extension on [String] that enhances modification.
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

  /// Trim the trailing web page title.
  String trimTitle() {
    return replaceFirst(' -  天使动漫论坛 - 梦开始的地方  -  Powered by Discuz!', '');
  }
}

/// Extension on [String] that parses [String] to other types.
extension ParseStringTo on String {
  /// Try to parse [String] to [int].
  ///
  /// Return null if is invalid [int].
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
    final formattedDateString = '${datePartList[0]}-'
        '${datePartList[1].padLeft(2, '0')}-'
        '${datePartList[2].padLeft(2, '0')}';
    return DateTime.tryParse(
      timePart == null ? formattedDateString : '$formattedDateString $timePart',
    );
  }

  /// Parse the string bytes size in utf-8 encoding.
  int get parseUtf8Length => utf8.encode(this).length;
}

/// Extension on [String] that provides info used in caching images.
extension ImageCacheFileName on String {
  /// Return a valid UUID-v5 format string of current string.
  String fileNameV5() {
    return _uuid.v5(Namespace.URL, this);
  }
}
