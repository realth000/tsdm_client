import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tsdm_client/models/cookie_data.dart';
import 'package:tsdm_client/providers/settings_provider.dart';
import 'package:tsdm_client/utils/debug.dart';

part '../generated/providers/cookie_provider.g.dart';

/// [cookieProvider] has an unique [username] representing an unique user.
///
/// Because we can use only one set of cookies in each web request, we use
/// only one cookie at the same time (in web client).
///
/// When switch to another user:
/// * Create a new cookie from database if the new user has cookie
///   used before and replace the cookie currently used in web request.
/// * Create a new cookie from web request if the user does not have
///   any cookie. This step is ran by CookieManager inside web client.
///   After that, save the new cookie in database. ///
/// When cookie updated during web request:
/// 1. Save cookies in memory.
/// 2. Use [cookieProvider] to fill current user info.

/// Cookie manager.
/// Managing all cookies used in app.
///
/// Receive user information (e.g. username) from outside (e.g. web client),
/// fill those info into [CookieData];
///
/// Load cookies from database and save them in memory. When required cookie to
/// use in web requests, build a [CookieData] with current user info.
///
/// Pass its [ref] to [CookieData] to let it access database provider.
/// We pass [ref] to [CookieData] instead of:
/// 1. Use stream to get cookie events from the created [CookieData].
/// 2. Make [CookieData] a provider.
/// Because:
/// 1. The stream works but its lifetime and open/close control is hard to
/// implement, stream sink should be held by both side.
/// 2. It is not recommended to construct another provider in a provider and
/// return it as state.
@Riverpod(dependencies: [AppSettings])
class Cookie extends _$Cookie {
  String? _username;

  @override
  CookieData build({String? username}) {
    // Specified user override.
    if (username != null) {
      debug('generate cookie data with override username: $username');
      final databaseCookie =
          ref.read(appSettingsProvider.notifier).getCookie(username);
      var cookie = <String, String>{};
      if (databaseCookie != null) {
        cookie = Map.castFrom(databaseCookie.cookie);
      }
      return CookieData.withUsername(
        username: username,
        cookie: cookie,
        ref: ref,
      );
    }

    return _buildCookieDataFromLoginUser();
  }

  CookieData _buildCookieDataFromLoginUser() {
    final username = ref.read(appSettingsProvider).loginUsername;
    if (username.isEmpty) {
      return CookieData(ref);
    }

    _username = username;
    // Has user login before, load cookie.
    final databaseCookie =
        ref.read(appSettingsProvider.notifier).getCookie(username);
    if (databaseCookie == null) {
      debug(
        'failed to init cookie: current login user username=$username not found in database',
      );
      return CookieData(ref);
    }

    return CookieData.withData(
      username: _username!,
      cookie: Map.castFrom(databaseCookie.cookie),
      ref: ref,
    );
  }
}
