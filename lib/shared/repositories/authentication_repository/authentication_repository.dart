import 'dart:async';
import 'dart:io';

import 'package:rxdart/rxdart.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/shared/providers/settings_provider/settings_provider.dart';
import 'package:tsdm_client/shared/repositories/authentication_repository/exceptions/exceptions.dart';
import 'package:tsdm_client/shared/repositories/authentication_repository/internal/login_result.dart';
import 'package:tsdm_client/shared/repositories/authentication_repository/internal/user_info.dart';
import 'package:tsdm_client/shared/repositories/authentication_repository/models/user.dart';
import 'package:tsdm_client/shared/repositories/authentication_repository/models/user_credential.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

/// Status of authentication.
//sealed class AuthenticationStatus {
//  const AuthenticationStatus();
//}
//
//final class AuthenticationUnknown extends AuthenticationStatus {
//  const AuthenticationUnknown() : super();
//}
//
//final class AuthenticationAuthenticated extends AuthenticationStatus {
//  const AuthenticationAuthenticated(this.user) : super();
//  final User user;
//}
//
//final class AuthenticationUnauthenticated extends AuthenticationStatus {
//  const AuthenticationUnauthenticated() : super();
//}

/// Status of authentication.
enum AuthenticationStatus {
  unknown,
  authenticated,
  unauthenticated,
}

/// Repository of authentication.
///
/// Provides login, logout.
///
/// **Need to call dispose.**
class AuthenticationRepository {
  AuthenticationRepository({User? user}) : _authedUser = user;

  static const _checkAuthUrl = '$baseUrl/home.php?mod=spacecp';
  static const _loginBaseUrl =
      '$baseUrl/member.php?mod=logging&action=login&loginsubmit=yes&frommessage&loginhash=';
  static const _logoutBaseUrl =
      '$baseUrl/member.php?mod=logging&action=logout&formhash=';
  static final _formHashRe = RegExp(r'formhash" value="(?<FormHash>\w+)"');

  static String _buildLoginUrl(String formHash) {
    return '$_loginBaseUrl$formHash';
  }

  static String _buildLogoutUrl(String formHash) {
    return '$_logoutBaseUrl$formHash';
  }

  /// Provide a stream of [AuthenticationStatus].
  final _controller = BehaviorSubject<AuthenticationStatus>();

  User? _authedUser;

  User? get currentUser => _authedUser;

  Stream<AuthenticationStatus> get status => _controller.asBroadcastStream();

  void dispose() {
    _controller.close();
  }

  Future<void> loginWithCookie(Map<String, dynamic> cookieMap) async {
    throw UnimplementedError();
  }

  /// Login with password and other parameters in [credential].
  ///
  /// Will not change authentication status if failed to login.
  ///
  /// # Exception
  ///
  /// * **[HttpRequestFailedException]** when http request failed.
  ///
  /// # Sealed Exception
  ///
  /// * **[LoginException]** when login request was refused by the server side.
  Future<void> loginWithPassword(UserCredential credential) async {
    final target = _buildLoginUrl(credential.formHash);
    // FIXME: Now we indicate the login field in credential is always username.
    final netClient = getIt.get<NetClientProvider>();
    final resp = await netClient.postForm(target, data: credential);
    if (resp.statusCode != HttpStatus.ok) {
      throw HttpRequestFailedException(resp.statusCode!);
    }
    final document = parseHtmlDocument(resp.data as String);
    final messageNode = document.getElementById('messagetext');
    if (messageNode == null) {
      throw LoginMessageNotFoundException();
    }
    final loginResult = LoginResult.fromLoginMessageNode(messageNode);
    if (loginResult == LoginResult.success) {
      final userInfo = _parseUserInfoFromDocument(document);
      if (userInfo == null) {
        throw LoginUserInfoNotFoundException();
      }
      // TODO: Here we need to find a way to get the email of logged user.
      await getIt
          .get<SettingsProvider>()
          .setLoginInfo(userInfo.username, int.parse(userInfo.uid));
      _authedUser = User(username: userInfo.username, uid: userInfo.uid);
      _controller.add(AuthenticationStatus.authenticated);
      return;
    }
    try {
      _parseAndThrowLoginResult(loginResult);
    } on LoginException {
      rethrow;
    }
  }

  /// Parse logged user info from html [document].
  Future<void> loginWithDocument(uh.Document document) async {
    final userInfo = _parseUserInfoFromDocument(document);
    if (userInfo == null) {
      debug('failed to login with document: user info not found');
      return;
    }
    // TODO: Here we need to find a way to get the email of logged user.
    await getIt
        .get<SettingsProvider>()
        .setLoginInfo(userInfo.username, int.parse(userInfo.uid));
    _authedUser = User(username: userInfo.username, uid: userInfo.uid);
    debug('login with document: user $userInfo');
    _controller.add(AuthenticationStatus.authenticated);
  }

  /// Logout the current user.
  ///
  /// Check authentication status first then try to logout.
  /// Do nothing if already unauthenticated.
  ///
  /// # Exception
  ///
  /// * **[HttpRequestFailedException]** if http requests failed.
  ///
  /// # Sealed Exception
  ///
  /// * **[LogoutException]** if failed to logout.
  Future<void> logout() async {
    if (_authedUser == null) {
      return;
    }
    final netClient = getIt.get<NetClientProvider>();
    final resp = await netClient.get(_checkAuthUrl);
    if (resp.statusCode != HttpStatus.ok) {
      throw HttpRequestFailedException(resp.statusCode!);
    }
    final document = parseHtmlDocument(resp.data as String);
    final userInfo = _parseUserInfoFromDocument(document);
    if (userInfo == null) {
      // Not logged in.
      await getIt.get<SettingsProvider>().setLoginInfo('', -1);
      _authedUser = null;
      _controller.add(AuthenticationStatus.unauthenticated);
      return;
    }
    final formHash = _formHashRe
        .firstMatch(document.body?.innerHtml ?? '')
        ?.namedGroup('FormHash');
    if (formHash == null) {
      throw LogoutFormHashNotFoundException();
    }

    final logoutResp = await netClient.get(_buildLogoutUrl(formHash));
    if (logoutResp.statusCode != HttpStatus.ok) {
      throw HttpRequestFailedException(logoutResp.statusCode!);
    }
    final logoutDocument = parseHtmlDocument(logoutResp.data as String);
    final logoutMessage = logoutDocument.getElementById('messagetext');
    if (logoutMessage == null || !logoutMessage.innerHtmlEx().contains('已退出')) {
      // Here we'd better to check the failed reason, but it's ok without it.
      throw LogoutFailedException();
    }
    await getIt.get<SettingsProvider>().setLoginInfo('', -1);
    _authedUser = null;
    _controller.add(AuthenticationStatus.unauthenticated);
  }

  /// Parse html [document], find current logged in user uid in it.
  UserInfo? _parseUserInfoFromDocument(uh.Document document) {
    final userNode =
        // Style 1: With avatar.
        document.querySelector(
              'div#hd div.wp div.hdc.cl div#um p strong.vwmy a',
            ) ??
            // Style 2: Without avatar.
            document.querySelector(
              'div#inner_stat > strong > a',
            );
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
    return UserInfo(uid: uid, username: username);
  }

  /// Parse the login result.
  ///
  /// Do nothing if login succeed.
  ///
  /// Throw exception if login failed.
  ///
  /// # Sealed Exception
  ///
  /// * **[LoginException]** throw when parse result is not "login success".
  void _parseAndThrowLoginResult(LoginResult loginResult) {
    switch (loginResult) {
      case LoginResult.success:
        return;
      case LoginResult.incorrectCaptcha:
        throw LoginIncorrectCaptchaException();
      case LoginResult.invalidUsernamePassword:
        throw LoginInvalidCredentialException();
      case LoginResult.incorrectQuestionOrAnswer:
        throw LoginIncorrectSecurityQuestionException();
      case LoginResult.attemptLimit:
        throw LoginAttemptLimitException();
      case LoginResult.otherError:
        throw LoginOtherErrorException('other error');
      case LoginResult.unknown:
        throw LoginOtherErrorException('unknown result');
    }
  }
}
