import 'dart:convert';

import 'package:html/parser.dart' as h;
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/uri.dart';
import 'package:tsdm_client/features/post/models/models.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:uuid/uuid.dart';

const Uuid _uuid = Uuid();

/// Result when parsing [String] to route succeed.
///
/// Represents a route that can be directed to.
class RecognizedRoute {
  /// Constructor.
  const RecognizedRoute(this.screenPath, {this.pathParameters = const {}, this.queryParameters = const {}});

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
  /// Regexp to match anchor in url.
  ///
  /// Anchor is not supported in dart url parsing.
  static final _anchorRe = RegExp(r'#pid(?<anchor>\d+)');

  /// Try parse string to [RecognizedRoute] with arguments.
  /// Return null if string is unsupported route.
  RecognizedRoute? parseUrlToRoute() {
    final queryParameters = tryParseAsUri()?.tryGetQueryParameters();
    if (queryParameters == null) {
      return null;
    }
    final anchor = _anchorRe.firstMatch(this)?.namedGroup('anchor');

    final mod = queryParameters['mod'];

    if (mod == 'forumdisplay' && queryParameters.containsKey('fid')) {
      // Apply supported filter, if any.
      final String? threadTypeID;
      if (queryParameters['filter'] == 'typeid') {
        threadTypeID = queryParameters['typeid'];
      } else {
        threadTypeID = null;
      }
      return RecognizedRoute(
        ScreenPaths.forum,
        pathParameters: {'fid': "${queryParameters['fid']}"},
        queryParameters: {
          if (threadTypeID != null) 'threadTypeID': threadTypeID,
          // FIXME: The FilterType originally is for showing the thread type name, but now the name is unknown when
          // parsing route in url. For now it's safe to add empty thread type name to let the page apply initial filter
          // state. If the name field not present, typeid is also discarded, this is the more one we we dont want.
          if (threadTypeID != null) 'threadTypeName': '-',
        },
      );
    }

    if (mod == 'viewthread' && queryParameters.containsKey('tid')) {
      final order = queryParameters['ordertype']?.parseToInt();

      // When anchor is used, means need to scroll to a target post by its pid.
      //
      // In this situation, do NOT override page order because the page number
      // is also provided, overriding post sort order will go into the wrong
      // page which does not contain the target post.
      return RecognizedRoute(
        ScreenPaths.threadV1,
        queryParameters: {
          'tid': "${queryParameters['tid']}",
          if (queryParameters.containsKey('page')) 'pageNumber': "${queryParameters['page']}",
          if (anchor != null) 'overrideReverseOrder': 'false',
          if (order != null) 'overrideWithExactOrder': '$order',
          if (anchor != null) 'pid': anchor,
          if (queryParameters.containsKey('authorid')) 'onlyVisibleUid': "${queryParameters['authorid']}",
        },
      );
    }

    if (mod == 'space' && queryParameters['do'] == 'thread' && queryParameters['view'] == 'me') {
      return const RecognizedRoute(ScreenPaths.myThread);
    }

    if (mod == 'forum' && queryParameters['srchfrom'] != null) {
      return RecognizedRoute(ScreenPaths.latestThread, queryParameters: {'url': prependHost()});
    }

    if (mod == 'redirect' && queryParameters['tid'] != null) {
      // TODO: Migrate to v2 when supported.
      return RecognizedRoute(
        ScreenPaths.threadV1,
        queryParameters: {
          'tid': "${queryParameters['tid']}",
          if (queryParameters.containsKey('authorid')) 'onlyVisibleUid': "${queryParameters['authorid']}",
        },
      );
    }

    if (mod == 'redirect' && queryParameters['goto'] == 'findpost' && queryParameters['pid'] != null) {
      // TODO: Migrate to v2 when supported.
      return RecognizedRoute(
        ScreenPaths.threadV1,
        queryParameters: {
          'pid': "${queryParameters['pid']}",
          // Disable reverse order when go with findpost.
          // Find post will always return a non-reversed thread, so disable it
          // to avoid incorrect page loaded when loading more pages.
          'overrideReverseOrder': 'false',
          if (queryParameters.containsKey('authorid')) 'onlyVisibleUid': "${queryParameters['authorid']}",
        },
      );
    }

    // FIXME: Do NOT glob access user profile page by uid.
    if (mod == 'space' && queryParameters['do'] != 'friend') {
      // Access by uid.
      if (queryParameters['uid'] != null) {
        return RecognizedRoute(ScreenPaths.profile, queryParameters: {'uid': '${queryParameters["uid"]}'});
      }

      // Access by username.
      if (queryParameters['username'] != null) {
        return RecognizedRoute(ScreenPaths.profile, queryParameters: {'username': '${queryParameters["username"]}'});
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
        pathParameters: {'editType': '${PostEditType.editPost.index}', 'fid': '${queryParameters["fid"]}'},
        queryParameters: {'tid': '${queryParameters["tid"]}', 'pid': '${queryParameters["pid"]}'},
      );
    }

    // Broadcast message detail page.
    if (mod == 'space' &&
        queryParameters['do'] == 'pm' &&
        queryParameters['subop'] == 'viewg' &&
        queryParameters.containsKey('pmid')) {
      return RecognizedRoute(ScreenPaths.broadcastMessageDetail, pathParameters: {'pmid': queryParameters['pmid']!});
    }

    // Chat page.
    //
    // Two formats:
    //
    // 1. $HOST/home.php?mod=spacecp&ac=pm&op=showmsg&
    //    handlekey=showmsg_${UID}&touid=${UID}&pmid=0&daterange=2
    // 2. $HOST/home.php?mod=spacecp&ac=pm&op=showmsg&
    //    handlekey=showmsg_${UID}&handlekey=showMsgBox&touid=${UID}&pmid=0&
    //    daterange=2&infloat=yes&inajax=1&ajaxtarget=fwin_content_showMsgBox
    if (mod == 'spacecp' &&
        queryParameters['ac'] == 'pm' &&
        queryParameters['op'] == 'showmsg' &&
        queryParameters.containsKey('handlekey') &&
        queryParameters.containsKey('touid') &&
        queryParameters.containsKey('pmid') &&
        queryParameters.containsKey('daterange')) {
      return RecognizedRoute(ScreenPaths.chat, pathParameters: {'uid': queryParameters['touid']!});
    }

    /// Chat history.
    if (mod == 'space' &&
        queryParameters['do'] == 'pm' &&
        queryParameters['subop'] == 'view' &&
        queryParameters['touid'] != null) {
      return RecognizedRoute(ScreenPaths.chatHistory, pathParameters: {'uid': queryParameters['touid']!});
    }

    if (mod == null && queryParameters.containsKey('gid')) {
      return RecognizedRoute(ScreenPaths.forumGroup, pathParameters: {'gid': queryParameters['gid']!});
    }

    return null;
  }

  /// Parse self as an uri and return the value of parameter [name].
  String? uriQueryParameter(String name) {
    return tryParseAsUri()?.tryGetQueryParameters()?[name];
  }

  /// Check a string is pattern of user space url.
  ///
  /// A string is a valid user space url ONLY if
  ///
  /// 1. Is a valid url.
  /// 2. In query parameters, 'mod' == 'space'.
  /// 3. In query parameters, contains key 'uid' or 'username'. (email ignored).
  /// 4. In query parameters, value of 'ac' is neither 'usergroup' nor 'credit'.
  bool get isUserSpaceUrl {
    final args = tryParseAsUri()?.tryGetQueryParameters();
    if (args == null) {
      return false;
    }

    if (args['mod'] != 'space') {
      return false;
    }

    if (args['uid'] == null && args['username'] == null) {
      return false;
    }

    final ac = args['ac'];
    if (ac == 'usergroup' || ac == 'credit') {
      return false;
    }

    return true;
  }

  /// Parse as url.
  ///
  /// Return null if any exception is thrown in the parsing process. And log an error message if so.
  Uri? tryParseAsUri() {
    try {
      return Uri.parse(this);
    } on Exception catch (e, st) {
      talker.handle('failed to parse maybe user space url: $e', st);
      return null;
    }
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
    if (startsWith('https://') || startsWith('http://') || startsWith('mailto:')) {
      return this;
    }
    return '$baseUrl/$this';
  }

  /// Prepend [suffix].
  String? append(String suffix) {
    return '$this$suffix';
  }

  /// Truncate string at position [size].
  ///
  /// If [length] is smaller than [size], return the whole string.
  String truncate(int size, {bool ellipsis = false}) {
    return length > size ? '${substring(0, size)}${ellipsis ? "..." : ""}' : this;
  }

  /// Trim the trailing web page title.
  String trimTitle() {
    return replaceFirst(' -  天使动漫论坛 - 梦开始的地方  -  Powered by Discuz!', '');
  }

  /// Parse html escaped text into normal text.
  String? unescapeHtml() {
    return h.parseFragment(this).text;
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
    final formattedDateString =
        '${datePartList[0]}-'
        '${datePartList[1].padLeft(2, '0')}-'
        '${datePartList[2].padLeft(2, '0')}';
    return DateTime.tryParse(timePart == null ? formattedDateString : '$formattedDateString $timePart');
  }

  /// Parse the string bytes size in utf-8 encoding.
  int get parseUtf8Length => utf8.encode(this).length;
}

/// Extension on [String] that provides info used in caching images.
extension ImageCacheFileName on String {
  /// Return a valid UUID-v5 format string of current string.
  String fileNameV5() {
    return _uuid.v5(Namespace.url.value, this);
  }
}

/// Make string secure.
extension ObsecureStringExt on String {
  /// Convert first [length] characters into "*".
  String obscured([int length = 8]) {
    if (isEmpty) {
      return '<empty string>';
    }

    if (this.length <= length) {
      return List.generate(this.length, (_) => '*').join();
    }

    return replaceRange(0, length, List.generate(length, (_) => '*').join());
  }
}
