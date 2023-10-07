import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tsdm_client/models/cookie_data.dart';
import 'package:tsdm_client/models/user_cookie_event.dart';
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
///   After that, save the new cookie in database.
///
/// When cookie updated during web request:
/// 1. Save cookies in memory.
/// 2. Use [cookieProvider] to fill current user info and save in database.

/// Cookie manager.
/// Managing all cookies used in app.
///
/// Receive user information (e.g. username) from outside (e.g. web client),
/// fill those info into [CookieData];
///
/// Load cookies from database and save them in memory. When required cookie to
/// use in web requests, build a [CookieData] with current user info.
///
@Riverpod(dependencies: [AppSettings])
class Cookie extends _$Cookie {
  String? _username;

  /// Stream of [UserCookieEvent] to receive all cookie events happened in
  /// [CookieData].
  ///
  /// Handle events and sync cookie to database.
  StreamController<UserCookieEvent>? _cookieStream;

  // To make linter happy: Bypass "unclosed instance of 'Sink'" warning
  // TODO: Find a proper time to close stream when instance disposing.
  void _() {
    _cookieStream?.close();
  }

  @override
  CookieData build({String? username}) {
    if (_cookieStream == null) {
      _cookieStream = StreamController<UserCookieEvent>();
      _cookieStream!.stream.listen((event) async {
        await _handleCookieEvent(event);
      });
    }

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
        cookieStreamSink: _cookieStream!.sink,
      );
    }

    return _buildCookieDataFromLoginUser();
  }

  CookieData _buildCookieDataFromLoginUser() {
    final username = ref.watch(appSettingsProvider).loginUsername;
    if (username.isEmpty) {
      return CookieData(_cookieStream!.sink);
    }

    debug('cookie init load cookie username=$username');
    _username = username;
    // Has user login before, load cookie.
    final databaseCookie =
        ref.read(appSettingsProvider.notifier).getCookie(username);
    if (databaseCookie == null) {
      debug(
        'failed to init cookie: current login user username=$username not found in database',
      );
      return CookieData(_cookieStream!.sink);
    }
    debug(
      'auto load user cookie from database: username=$_username',
    );

    return CookieData.withData(
      username: _username!,
      cookie: Map.castFrom(databaseCookie.cookie),
      cookieStreamSink: _cookieStream!.sink,
    );
  }

  Future<void> _handleCookieEvent(UserCookieEvent event) async {
    switch (event.eventType) {
      case UserCookieEventType.update:
        await ref.read(appSettingsProvider.notifier).saveCookie(
              event.username,
              event.cookie,
            );
      case UserCookieEventType.delete:
        await ref.read(appSettingsProvider.notifier).deleteCookieByUsername(
              event.username,
            );
    }
  }
}
