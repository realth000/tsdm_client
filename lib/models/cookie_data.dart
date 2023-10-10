import 'dart:async';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:tsdm_client/models/user_cookie_event.dart';
import 'package:tsdm_client/utils/debug.dart';

/// Cookie stored to use in [PersistCookieJar] as replacement of [FileStorage]
/// that save in database.
///
/// Not expose cookies, managing cookies with database.
///
/// Because in this layer we do not know any information about user (e.g.
/// username), what we can do is save these cookies as cache in memory.
/// And it's cookieProvider's work to save them to database.
class CookieData implements Storage {
  CookieData(this.cookieStreamSink) : _username = null;

  CookieData.withUsername({
    required String username,
    required Map<String, String> cookie,
    required this.cookieStreamSink,
  })  : _username = username,
        _cookieMap = cookie;

  CookieData.withData({
    required String username,
    required Map<String, String> cookie,
    required this.cookieStreamSink,
  })  : _username = username,
        _cookieMap = cookie;

  /// Stream to send cookie event.
  final StreamSink<UserCookieEvent> cookieStreamSink;

  final String? _username;

  /// Cookie data.
  Map<String, String> _cookieMap = {};

  /// Check if user info completed or not.
  ///
  /// We should not do anything with cookie storage when user info is not complete.
  bool _isUserInfoComplete() {
    /// Note that the server side does not allow same username so it's safe to
    /// do this.
    if (_username == null) {
      return false;
    }
    return true;
  }

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
      debug('only save cookie in memory: user info incomplete');
      return false;
    }

    cookieStreamSink.add(UserCookieEvent.update(
      username: _username!,
      cookie: _cookieMap,
    ));
    return true;
  }

  /// Delete current user [_username]'s cookie from database.
  ///
  /// Return false if delete failed (maybe user not found in database) or missing
  /// user info.
  /// Return true is success.
  Future<bool> _deleteUserCookie() async {
    if (!_isUserInfoComplete()) {
      debug(
        'refuse to delete single user cookie from database: user info incomplete',
      );
      return false;
    }

    debug('CookieData $hashCode: delete cookie: $_username');
    cookieStreamSink.add(UserCookieEvent.delete(
      username: _username!,
    ));
    return true;
  }

  @override
  Future<void> delete(String key) async {
    _cookieMap.remove(key);
    // If user cookie is empty, delete that item from database.
    if (_cookieMap.isEmpty) {
      debug(
        'delete user $_username from database because cookie value is empty',
      );
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
    return _cookieMap[key];
  }

  @override
  Future<void> write(String key, String value) async {
    _cookieMap[key] = value;
    await _syncCookie();
  }
}
