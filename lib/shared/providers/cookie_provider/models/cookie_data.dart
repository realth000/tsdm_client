import 'dart:async';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';
import 'package:tsdm_client/utils/logger.dart';

part 'current_user_cookie.dart';

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
  /// Constructor.
  ///
  /// Use this constructor when logout.
  CookieData.logout({
    required UserLoginInfo userLoginInfo,
    required Cookie cookie,
  })  : _userLoginInfo = userLoginInfo,
        _cookieMap = Map.castFrom(cookie) {
    debug('logout progress with userinfo $_userLoginInfo');

    // We may logout another user, or current user.
    //
    // Only clear static cookie cache when current user logout.
    // This progress is prepared for the multiuser feature.
    if (userLoginInfo == _currentUserCookie.userLoginInfo) {
      debug('clear temporary cookie static cache for current login user');
      _currentUserCookie = _CurrentUserCookie.empty();
    }
  }

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
    Cookie? cookie,
  })  : _userLoginInfo = userLoginInfo,
        _cookieMap = cookie != null
            ? Map.castFrom(cookie)
            : _currentUserCookie.cookie ?? {} {
    if (userLoginInfo.isComplete && cookie != null) {
      // User info is complete, means already has user login.
      _currentUserCookie.copyWith(
        userLoginInfo: userLoginInfo,
        cookie: Map.castFrom(cookie),
      );
    }
  }

  /// Construct with [userLoginInfo].
  ///
  /// Use this constructor when starting a new login progress.
  CookieData.startLogin(UserLoginInfo userLoginInfo)
      : _userLoginInfo = userLoginInfo,
        _cookieMap = {} {
    // Clear current user cookie when going to start a login progress.
    debug('start login progress with userinfo $userLoginInfo');
    _currentUserCookie =
        _CurrentUserCookie.empty().copyWith(userLoginInfo: userLoginInfo);
  }

  // FIXME: This static method is bad practise.
  /// Call when a login progress is going to end.
  ///
  /// **Note that [userLoginInfo] MUST be completed**.
  static Future<void> endLogin(UserLoginInfo userLoginInfo) async {
    assert(
      userLoginInfo.isComplete,
      'The UserLoginInfo intend to finish a '
      'login progress MUST be complete',
    );
    // Fulfill user info.
    talker.debug('end login progress with userinfo $userLoginInfo');
    _currentUserCookie =
        _currentUserCookie.copyWith(userLoginInfo: userLoginInfo);

    await getIt.get<StorageProvider>().saveCookie(
          username: userLoginInfo.username!,
          uid: userLoginInfo.uid!,
          // email: userLoginInfo.email!,
          cookie: _currentUserCookie.cookie!,
        );
  }

  final UserLoginInfo? _userLoginInfo;

  /// Cookie data.
  final Map<String, String> _cookieMap;

  /// Check if user info completed or not.
  ///
  /// We should not do anything with cookie storage when user info is not
  /// complete.
  bool _isUserInfoComplete() =>
      _userLoginInfo != null && _userLoginInfo.isComplete;

  /// Temporary cookie data to save current user cookie.
  ///
  /// We have a principle, that we only have the complete info about a user
  /// when the user has logged in. So that during the login progress, we only
  /// have part of the user info: It's username, uid or email, and with some
  /// cookie that received from server.
  ///
  /// Another principle: Only complete userinfo together with cookie can be
  /// saved in storage.
  ///
  /// The problem is, the cookie received MUST be saved somewhere till we
  /// successfully login and get complete user info, then the cookie becomes
  /// usable and need to save in database.
  ///
  /// So during login progress, save the info here.
  /// When auth repo get complete user info, call some method to fulfill user
  /// info.
  ///
  /// 1. Try to login, this time incomplete user info passed in, save user info
  ///    here. Now cookie is empty.
  /// 2. During login progress, get cookie (already authed) and save here. Now
  ///    cookie is ok but user info still incomplete.
  /// 3. Auth repo (or auth provider else) get full user info using the cookie
  ///    we save in step 2, call some method to save full user info.
  /// 4. Check user info is complete and save data into storage.
  static _CurrentUserCookie _currentUserCookie = _CurrentUserCookie.empty();

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
      info('only save cookie in memory: user info incomplete: $_userLoginInfo');
      _currentUserCookie = _currentUserCookie.copyWith(cookie: _cookieMap);
      return false;
    }
    debug('save complete cookie in memory:'
        ' user info incomplete: $_userLoginInfo');
    _currentUserCookie = _currentUserCookie.copyWith(cookie: _cookieMap);

    await getIt.get<StorageProvider>().saveCookie(
          username: _userLoginInfo!.username!,
          uid: _userLoginInfo.uid!,
          // email: _userLoginInfo.email!,
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

    if (_userLoginInfo != null) {
      debug('CookieData $hashCode: delete cookie for uid: $_userLoginInfo');
      await getIt.get<StorageProvider>().deleteCookieByUserInfo(_userLoginInfo);
    }
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
      debug('delete user ($_userLoginInfo) cookie from database '
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
