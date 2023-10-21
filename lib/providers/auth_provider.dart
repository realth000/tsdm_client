import 'dart:io';

import 'package:dio/dio.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/html_element.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';
import 'package:tsdm_client/providers/settings_provider.dart';
import 'package:tsdm_client/utils/debug.dart';

part '../generated/providers/auth_provider.g.dart';

/// Auth state manager.
///
@Riverpod(keepAlive: true, dependencies: [NetClient])
class Auth extends _$Auth {
  static const _checkAuthUrl = '$baseUrl/home.php?mod=spacecp';
  static const _loginUrl =
      '$baseUrl/member.php?mod=logging&action=login&loginsubmit=yes&frommessage&loginhash=';
  static const _logoutUrl =
      '$baseUrl/member.php?mod=logging&action=logout&formhash=';

  /// Check auth state *using cached data*.
  ///
  /// If already logged in, return current login uid, otherwise return null.
  @override
  AuthState build() {
    return _authState;
  }

  AuthState _authState = AuthState.notAuthorized;
  String? _loggedUid;
  String? _loggedUsername;

  String? get loggedUid => _loggedUid;

  String? get loggedUsername => _loggedUsername;

  Future<void> _updateAuthState(AuthState state) async {
    debug('authProvider: update auth state to $state');
    switch (state) {
      case AuthState.authorized:
        await ref
            .read(appSettingsProvider.notifier)
            .setLoginUsername(_loggedUsername!);
      case AuthState.notAuthorized:
        await ref.read(appSettingsProvider.notifier).setLoginUsername('');
      default:
      // Do nothing.
    }
    _authState = state;
    ref.invalidateSelf();
  }

  /// Parsing html [dom.Document] and update auth state with user info in it.
  ///
  /// This is a function acts like try to login, but parse result using cached
  /// html [document].
  ///
  /// **Will update login status**.
  ///
  /// If login success, return true. Otherwise return false.
  Future<bool> loginFromDocument(dom.Document document) async {
    final r = await _parseUidInDocument(document);
    if (r == null) {
      _loggedUid = null;
      _loggedUsername = null;
      await _updateAuthState(AuthState.notAuthorized);
      return false;
    }
    _loggedUid = r.$1;
    _loggedUsername = r.$2;
    await _updateAuthState(AuthState.authorized);
    return true;
  }

  /// Login
  Future<(LoginResult, String)> login({
    required String username,
    required String password,
    required String verifyCode,
    required String formHash,
  }) async {
    await _updateAuthState(AuthState.loggingIn);
    final result = await _login(
      username: username,
      password: password,
      verifyCode: verifyCode,
      formHash: formHash,
    );
    if (result.$1 == LoginResult.success) {
      await _updateAuthState(AuthState.authorized);
    } else {
      await _updateAuthState(AuthState.notAuthorized);
    }
    return result;
  }

  Future<(LoginResult, String)> _login({
    required String username,
    required String password,
    required String verifyCode,
    required String formHash,
  }) async {
    // login
    final body = {
      'username': username,
      'password': password,
      'tsdm_verify': verifyCode,
      'formhash': formHash,
      'referer': homePage,
      'loginfield': 'username',
      'questionid': 0,
      'answer': 0,
      'cookietime': 2592000,
      'loginsubmit': true
    };

    final target = '$_loginUrl$formHash';
    final resp = await ref.read(netClientProvider(username: username)).post(
          target,
          data: body,
          options: Options(
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          ),
        );

    // err_login_captcha_invalid

    if (resp.statusCode != HttpStatus.ok) {
      final message = resp.statusCode;
      debug(message);
      return (LoginResult.requestFailed, '$message');
    }

    final document = html_parser.parse(resp.data);
    final messageNode = document.getElementById('messagetext');
    if (messageNode == null) {
      // Impossible.
      debug('failed to login: message node not found');
      return (LoginResult.messageNotFound, '');
    }
    final result = LoginResult.fromLoginMessageNode(messageNode);
    if (result == LoginResult.success) {
      final r = await _parseUidInDocument(document);
      _loggedUid = r!.$1;
      _loggedUsername = r.$2;
      await _updateAuthState(AuthState.authorized);
    } else {
      _loggedUid = null;
      await _updateAuthState(AuthState.notAuthorized);
    }

    return (result, '');
  }

  /// Logout from TSDM.
  ///
  /// If success or already logged out, return true.
  Future<bool> logout() async {
    await _updateAuthState(AuthState.loggingOut);
    final result = await _logout();
    await _updateAuthState(
      result ? AuthState.notAuthorized : AuthState.authorized,
    );
    return result;
  }

  Future<bool> _logout() async {
    // Check auth status by accessing user space url.
    final resp = await ref.read(netClientProvider()).get(_checkAuthUrl);
    if (resp.statusCode != HttpStatus.ok) {
      debug(
        'failed to logout: auth http request failed with status code=${resp.statusCode}',
      );
      return false;
    }
    final document = html_parser.parse(resp.data);
    final uid = await _parseUidInDocument(document);
    if (uid == null) {
      debug('unnecessary logout: not authed');
      _loggedUid = null;
      await _updateAuthState(AuthState.notAuthorized);
      return true;
    }

    // Get form hash.
    final re = RegExp(r'formhash" value="(?<FormHash>\w+)"');
    final formHashMatch = re.firstMatch(document.body?.innerHtml ?? '');
    final formHash = formHashMatch?.namedGroup('FormHash');
    if (formHash == null) {
      debug('failed to logout: get form hash failed');
      return false;
    }

    // Logout
    final logoutResp =
        await ref.read(netClientProvider()).get('$_logoutUrl$formHash');
    if (logoutResp.statusCode != HttpStatus.ok) {
      debug(
        'failed to logout: logout request failed with status code ${logoutResp.statusCode}',
      );
      return false;
    }

    final logoutDocument = html_parser.parse(logoutResp.data);
    final logoutMessage = logoutDocument.getElementById('messagetext');
    if (logoutMessage == null || !logoutMessage.innerHtml.contains('已退出')) {
      debug('failed to logout: logout message not found');
      return false;
    }

    _loggedUid = null;
    await _updateAuthState(AuthState.notAuthorized);
    return true;
  }

  /// Parse html [document], find current logged in user uid in it.
  Future<(String, String)?> _parseUidInDocument(dom.Document document) async {
    final userNode = document
        .querySelector('div#hd div.wp div.hdc.cl div#um p strong.vwmy a');
    if (userNode == null) {
      debug('auth failed: user node not found');
      return null;
    }
    final username = userNode.firstEndDeepText();
    if (username == null) {
      debug('auth failed: user name not found');
      return null;
    }
    final uid = userNode.firstHref()?.split('uid=').lastOrNull;
    if (uid == null) {
      debug('auth failed: user id not found');
      return null;
    }
    return (uid, username);
  }
}

/// State of app account login state.
enum AuthState {
  /// Not logged in.
  notAuthorized,

  /// Processing login.
  loggingIn,

  /// Logged in.
  authorized,

  /// Processing logged out.
  loggingOut,
}

/// Enum to represent whether a login attempt succeed.
enum LoginResult {
  /// Login success.
  success,

  /// Failed in http request failed.
  requestFailed,

  /// Failed to find login result message.
  messageNotFound,

  /// Captcha is not correct.
  incorrectCaptcha,

  /// Maybe a login failed.
  ///
  /// When showing error messages or logging, record the original message.
  invalidUsernamePassword,

  /// Too many login attempt and failure.
  attemptLimit,

  /// Other unrecognized error received from server.
  otherError,

  /// Unknown result.
  ///
  /// Treat as login failed.
  unknown;

  factory LoginResult.fromLoginMessageNode(dom.Element messageNode) {
    final message = messageNode
        .querySelector('div#messagetext > p')
        ?.nodes
        .firstOrNull
        ?.text;
    if (message == null) {
      const message = 'login result message text not found';
      debug('failed to check login result: $message');
      return LoginResult.unknown;
    }

    // Check message result node classes.
    // alert_right => login success.
    // alert_info  => login failed, maybe incorrect captcha.
    // alert_error => login failed, maybe invalid username or password.
    final messageClasses = messageNode.classes;

    if (messageClasses.contains('alert_right')) {
      if (message.contains('欢迎您回来')) {
        return LoginResult.success;
      }

      // Impossible unless server response page updated and changed these messages.
      debug(
        'login result check passed but message check maybe outdated: $message',
      );
      return LoginResult.success;
    }

    if (messageClasses.contains('alert_info')) {
      if (message.contains('err_login_captcha_invalid')) {
        return LoginResult.incorrectCaptcha;
      }

      // Other unrecognized error.
      debug(
        'login result check not passed: alert_info class with unknown message: $message',
      );
      return LoginResult.otherError;
    }

    if (messageClasses.contains('alert_error')) {
      if (message.contains('登录失败')) {
        return LoginResult.invalidUsernamePassword;
      }

      if (message.contains('密码错误次数过多')) {
        return LoginResult.attemptLimit;
      }

      // Other unrecognized error.
      debug(
        'login result check not passed: alert_error with unknown message: $message',
      );
      return LoginResult.otherError;
    }

    debug('login result check not passed: unknown result');
    return LoginResult.unknown;
  }
}
