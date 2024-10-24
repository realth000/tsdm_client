import 'package:cookie_jar/cookie_jar.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/features/settings/repositories/settings_repository.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';
import 'package:tsdm_client/utils/logger.dart';

/// Manage cookie in http requests.
///
/// Provides ability to read/write cookie in storage, also keeps the current
/// user's info and cookie in memory.
final class CookieProvider with LoggerMixin implements Storage {
  /// Constructor.
  CookieProvider(this._userLoginInfo, this._cookieMap);

  /// Build a [CookieProvider].
  ///
  /// Load current user's info and cookie from settings and storage.
  factory CookieProvider.build() {
    final settings = getIt.get<SettingsRepository>().currentSettings;
    final loggedUid = settings.loginUid;
    final userInfo = UserLoginInfo(
      username: settings.loginUsername,
      uid: loggedUid,
      // email: settings.loginEmail,
    );
    // Valid uid > 0.
    if (loggedUid <= 0) {
      talker.warning('load empty cookie');
      return CookieProvider(userInfo, {});
    }

    talker.debug('load cookie from database with login user '
        'uid: ${"$loggedUid".obscured(4)}');
    // Has user login before, load cookie.
    final databaseCookie =
        getIt.get<StorageProvider>().getCookieByUidSync(loggedUid);
    if (databaseCookie == null) {
      talker.error(
        'failed to init cookie: current login user '
        'id not found in database',
      );
      return CookieProvider(userInfo, {});
    }

    return CookieProvider(userInfo, Map.castFrom(databaseCookie));
  }

  /// Construct a instance with no preload cookie or user info
  factory CookieProvider.buildEmpty() =>
      CookieProvider(UserLoginInfo.empty(), {});

  /// Cookie data.
  Map<String, String> _cookieMap;

  /// Info of the user currently login.
  UserLoginInfo _userLoginInfo;

  /// Update current recorded user info.
  Future<void> updateUserInfo(UserLoginInfo userInfo) async {
    debug('update user info: $userInfo');
    _userLoginInfo = userInfo;
    if (_userLoginInfo.isComplete) {
      debug('complete user info updated, sync cookie');
      await _syncCookie();
    }
  }

  /// Load cookie of [userInfo] from storage.
  ///
  /// Return false if any error occurred.
  Future<bool> loadCookieFromStorage(UserLoginInfo userInfo) async {
    final username = userInfo.username;
    final uid = userInfo.uid;
    if (username == null && uid == null) {
      error('failed to switch cookie: invalid user info');
      return false;
    }

    Map<String, dynamic>? databaseCookie;

    final storage = getIt.get<StorageProvider>();

    if (uid != null) {
      info('load cookie from database with given '
          'uid: ${"$uid".obscured(4)}');
      databaseCookie = storage.getCookieByUidSync(uid);
    } else if (username != null) {
      info('load cookie from database with given '
          'username: ${username.obscured()}');
      databaseCookie = storage.getCookieByUsernameSync(username);
      // } else if (email != null) {
      //   databaseCookie = storage.getCookieByEmailSync(email);
    }

    if (databaseCookie == null) {
      error('failed to switch cookie: cookie not found in database');
      return false;
    }
    debug('cookie switch to user $userInfo');
    _userLoginInfo = UserLoginInfo(username: username, uid: uid);
    _cookieMap = Map.castFrom(databaseCookie);
    return true;
  }

  /// Save current user's info and cookie to storage.
  Future<void> saveCookieToStorage() async {
    if (!_userLoginInfo.isComplete) {
      warning('can not save user info incomplete cookie to storage');
      return;
    }
    debug('save authed cookie to storage');
    await getIt.get<StorageProvider>().saveCookie(
          username: _userLoginInfo.username!,
          uid: _userLoginInfo.uid!,
          cookie: _cookieMap,
        );
  }

  /// Delete current login user info and cookie from memory and database.
  void clearUserInfoAndCookie() {
    debug('clear user info and cookie');
    _userLoginInfo = const UserLoginInfo(username: null, uid: null);
    _cookieMap = {};
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
    if (!_userLoginInfo.isComplete) {
      info('only save cookie in memory: user info incomplete: $_userLoginInfo');
      return false;
    }

    // Only save authed cookie into storage.
    if (!_cookieMap.values.any((e) => e.contains('s_gkr8_682f_auth'))) {
      return false;
    }

    await getIt.get<StorageProvider>().saveCookie(
          username: _userLoginInfo.username!,
          uid: _userLoginInfo.uid!,
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
    if (!_userLoginInfo.isComplete) {
      info(
        'refuse to delete single user cookie from database: '
        'user info incomplete',
      );
      return false;
    }

    debug('CookieData $hashCode: delete cookie for uid: $_userLoginInfo');
    await getIt.get<StorageProvider>().deleteCookieByUserInfo(_userLoginInfo);
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
    // Do not update authed cookie with not authed one.
    if ((_cookieMap[key]?.contains('s_gkr8_682f_auth') ?? false) &&
        !value.contains('s_gkr8_682f_auth')) {
      return;
    }
    _cookieMap[key] = value;
    await _syncCookie();
  }
}
