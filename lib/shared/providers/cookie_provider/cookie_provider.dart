import 'package:tsdm_client/features/settings/repositories/settings_repository.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/cookie_provider/models/cookie_data.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';
import 'package:tsdm_client/utils/logger.dart';

/// Provides a [CookieData] that implement `Storage` class so can be used in
/// `NetClient`.
///
/// [CookieProvider] has an unique `username` representing an unique user.
///
/// Because we can use only one set of cookies in each web request, we use
/// only one cookie at the same time (in web client).
///
/// When switch to another user:
/// * Create a new cookie from database if the new user has cookie
///   used before and replace the cookie currently used in web request.
/// * Create a new cookie from web request if the user does not have
///   any cookie. This step is ran by CookieManager inside web client.
///   After that, save the new cookie in database.
///
/// When cookie updated during web request:
/// 1. Save cookies in memory.
/// 2. Use [CookieProvider] to fill current user info.
/// Cookie manager.
/// Managing all cookies used in app.
///
/// Receive user information (e.g. username) from outside (e.g. web client),
/// fill those info into [CookieData];
///
/// Load cookies from database and save them in memory. When required cookie to
/// use in web requests, build a [CookieData] with current user info.
class CookieProvider with LoggerMixin {
  /// Constructor.
  factory CookieProvider() => CookieProvider._();

  CookieProvider._();

  /// Build a [CookieData] with [userLoginInfo].
  ///
  /// * First look in storage and find the cached cookie related to
  ///   [userLoginInfo].
  /// * Return empty cookie if not found in cache.
  CookieData build({UserLoginInfo? userLoginInfo}) {
    // Specified user override.
    if (userLoginInfo != null) {
      final username = userLoginInfo.username;
      final uid = userLoginInfo.uid;
      final email = userLoginInfo.email;

      Map<String, dynamic>? databaseCookie;

      if (uid != null) {
        databaseCookie = getIt.get<StorageProvider>().getCookieByUidSync(uid);
      } else if (username != null) {
        databaseCookie =
            getIt.get<StorageProvider>().getCookieByUsernameSync(username);
      } else if (email != null) {
        databaseCookie =
            getIt.get<StorageProvider>().getCookieByEmailSync(email);
      }

      var cookie = <String, String>{};
      if (databaseCookie != null) {
        cookie = Map.castFrom(databaseCookie);
      }

      if (cookie.keys.isNotEmpty) {
        debug('load cookie with user info');
        return CookieData.withUserInfo(
          userLoginInfo: userLoginInfo,
          cookie: cookie,
        );
      }
    }

    final loggedUid = getIt.get<SettingsRepository>().currentSettings.loginUid;
    // Valid uid > 0.
    if (loggedUid <= 0) {
      info('load empty cookie');
      return CookieData();
    }

    // Has user login before, load cookie.
    final databaseCookie =
        getIt.get<StorageProvider>().getCookieByUidSync(loggedUid);
    if (databaseCookie == null) {
      error(
        'failed to init cookie: current login user '
        'uid=$loggedUid not found in database',
      );
      return CookieData();
    }

    debug('load cookie from last logged user uid=$loggedUid');
    return CookieData.withUserInfo(
      userLoginInfo: UserLoginInfo(username: null, uid: loggedUid, email: null),
      cookie: databaseCookie,
    );
  }
}
