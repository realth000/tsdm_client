import 'dart:async';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';
import 'package:tsdm_client/utils/logger.dart';

/// Cookie stored to use in [PersistCookieJar] as replacement of [FileStorage]
/// that save in database.
///
/// Not expose cookies, managing cookies with database.
///
/// Because in this layer we do not know any information about user (e.g.
/// username), what we can do is save these cookies as cache in memory.
///
/// Use the [getIt] to access database.
class CookieData with LoggerMixin implements Storage {
  /// Construct with no user name.
  CookieData() : _userLoginInfo = null;

  /// Construct with [userLoginInfo] and [cookie].
  ///
  /// [userLoginInfo] can be partly filled. What means is during login progress,
  /// we may only have one of the following info:
  ///
  /// * Username.
  /// * Uid.
  /// * Password.
  CookieData.withUserInfo({
    required UserLoginInfo userLoginInfo,
    required Cookie cookie,
  })  : _userLoginInfo = userLoginInfo,
        _cookieMap = cookie;

  final UserLoginInfo? _userLoginInfo;

  /// Cookie data.
  Cookie _cookieMap = {};

  /// Check if user info completed or not.
  ///
  /// We should not do anything with cookie storage when user info is not
  /// complete.
  bool _isUserInfoComplete() =>
      _userLoginInfo != null && !_userLoginInfo.isComplete;

  /// Save cookie in database.
  ///
  /// This function is private because saving a cookie should only be triggered
  /// by web request update.
  /// This function should be called every time after cookie value updated.
  /// If user info still incomplete, do not save to database, which shall not
  /// happen.
  ///
  /// Return false if user info is incomplete.
  Future<bool> _syncCookie() async {
    // Do not save cookie if we don't know which user it belongs to.
    // This shall not happen.
    if (!_isUserInfoComplete()) {
      info('only save cookie in memory: user info incomplete');
      return false;
    }

    await getIt.get<StorageProvider>().saveCookie(
          username: _userLoginInfo!.username!,
          uid: _userLoginInfo.uid!,
          email: _userLoginInfo.email!,
          cookie: _cookieMap,
        );

    return true;
  }

  /// Delete current user [_userLoginInfo]'s cookie from database.
  ///
  /// Return false if delete failed (maybe user not found in database) or
  /// missing
  /// user info.
  /// Return true is success.
  Future<bool> _deleteUserCookie() async {
    if (!_isUserInfoComplete()) {
      info(
        'refuse to delete single user cookie from database: '
        'user info incomplete',
      );
      return false;
    }

    debug('CookieData $hashCode: delete '
        'cookie for uid: ${_userLoginInfo?.uid}');
    await getIt.get<StorageProvider>().deleteCookieByUid(_userLoginInfo!.uid!);
    return true;
  }

  // TODO: Try set webpage style in cookie.
  /// To parse web page correctly, set a certain web page style id here.
  ///
  /// The main difference between web page styles are homepage layout.
  ///
  /// name    id     avatar   forum-info-layout
  /// 水晶     4    no avatar  <dd> <em> <font>主题</font> <font>123</font> </em> </dd>
  /// 爱丽丝   5       avatar  <dd> <em>主题</em> , <em>123></em> </dd>
  /// 羽翼     6    no avatar  Same with style 4
  /// 旅行者   13      avatar  Same with style 5
  /// 自由之翼 12      avatar  Same with style 5
  void _setupWebPageStyle() {}

  @override
  Future<void> delete(String key) async {
    _cookieMap.remove(key);
    // If user cookie is empty, delete that item from database.
    if (_cookieMap.isEmpty) {
      debug('delete user (uid:${_userLoginInfo?.uid}) cookie from database '
          'because cookie value is empty');
      await _deleteUserCookie();
    } else {
      await _syncCookie();
    }
  }

  @override
  Future<void> deleteAll(List<String> keys) async {
    _cookieMap.clear();
    await _deleteUserCookie();
  }

  @override
  Future<void> init(bool persistSession, bool ignoreExpires) async {}

  @override
  Future<String?> read(String key) async {
    _setupWebPageStyle();
    return _cookieMap[key];
  }

  @override
  Future<void> write(String key, String value) async {
    _cookieMap[key] = value;
    await _syncCookie();
  }
}
