import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/cookie_provider/models/cookie_data.dart';
import 'package:tsdm_client/shared/providers/settings_provider/settings_provider.dart';
import 'package:tsdm_client/utils/debug.dart';

// TODO: Adapt with uid and email after can login with uid and email.
/// Provides a [CookieData] that implement `Storage` class so can be used in `NetClient`.
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
class CookieProvider {
  CookieProvider._();

  factory CookieProvider() => CookieProvider._();

  CookieData build({String? username}) {
    // Specified user override.
    if (username != null) {
      debug('generate cookie data with override username: $username');
      // Here get the cookie from SettingsProvider's instance.
      final databaseCookie = getIt.get<SettingsProvider>().getCookie(username);
      var cookie = <String, String>{};
      if (databaseCookie != null) {
        cookie = Map.castFrom(databaseCookie.cookie);
      }
      return CookieData.withUsername(
        username: username,
        cookie: cookie,
      );
    }
    final loggedUsername = getIt.get<SettingsProvider>().getLoginInfo().$1;
    if (loggedUsername.isEmpty) {
      return CookieData();
    }

    // Has user login before, load cookie.
    final databaseCookie =
        getIt.get<SettingsProvider>().getCookie(loggedUsername);
    if (databaseCookie == null) {
      debug(
        'failed to init cookie: current login user username=$username not found in database',
      );
      return CookieData();
    }

    return CookieData.withData(
      username: loggedUsername,
      cookie: Map.castFrom(databaseCookie.cookie),
    );
  }
}
