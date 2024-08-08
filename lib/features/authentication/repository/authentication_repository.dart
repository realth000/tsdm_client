import 'dart:async';
import 'dart:io';

import 'package:rxdart/rxdart.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/features/authentication/repository/exceptions/exceptions.dart';
import 'package:tsdm_client/features/authentication/repository/internal/login_result.dart';
import 'package:tsdm_client/features/authentication/repository/models/models.dart';
import 'package:tsdm_client/features/settings/repositories/settings_repository.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

/// Status of authentication.
enum AuthenticationStatus {
  /// Unknown state.
  ///
  /// Same with [unauthenticated].
  unknown,

  /// Have user logged.
  authenticated,

  /// No one logged.
  unauthenticated,
}

/// Repository of authentication.
///
/// Provides login, logout.
///
/// **Need to call dispose.**
class AuthenticationRepository with LoggerMixin {
  /// Constructor.
  AuthenticationRepository({UserLoginInfo? user}) : _authedUser = user;

  static const _checkAuthUrl = '$baseUrl/home.php?mod=spacecp';
  static const _loginBaseUrl =
      '$baseUrl/member.php?mod=logging&action=login&loginsubmit=yes&frommessage&loginhash=';
  static const _logoutBaseUrl =
      '$baseUrl/member.php?mod=logging&action=logout&formhash=';
  static const _fakeFormUrl =
      '$baseUrl/member.php?mod=logging&action=login&infloat=yes&frommessage&inajax=1&ajaxtarget=messagelogin';
  static const _passwordSettingsUrl =
      '$baseUrl/home.php?mod=spacecp&ac=profile&op=password';
  static final _layerLoginRe = RegExp(r'layer_login_(?<Hash>\w+)');
  static final _formHashRe = RegExp(r'formhash" value="(?<FormHash>\w+)"');

  static String _buildLoginUrl(String formHash) {
    return '$_loginBaseUrl$formHash';
  }

  static String _buildLogoutUrl(String formHash) {
    return '$_logoutBaseUrl$formHash';
  }

  /// Provide a stream of [AuthenticationStatus].
  final _controller = BehaviorSubject<AuthenticationStatus>();

  UserLoginInfo? _authedUser;

  /// The current logged user.
  UserLoginInfo? get currentUser => _authedUser;

  /// Authentication status stream.
  Stream<AuthenticationStatus> get status => _controller.asBroadcastStream();

  /// Dispose the resources.
  void dispose() {
    _controller.close();
  }

  /// Fetch login hash and form hash for logging in.
  ///
  /// # Exception
  ///
  /// * **HttpRequestFailedException** when http request failed.
  /// * **LoginFormHashNotFoundException** when form hash not found.
  /// * **LoginInvalidFormHashException** when form hash found but not in the
  ///   expected format.
  Future<LoginHash> fetchHash() async {
    // TODO: Parse CDATA.
    // 返回的data是xml：
    //
    // <?xml version="1.0" encoding="utf-8"?>
    // <root><![CDATA[
    // <div id="main_messaqge_L5hJN">
    // <div id="layer_login_L5hJN">
    //
    // 其中"main_message_"后面的是本次登录的loginHash，登录时需要加到url上
    final rawDataResp = await getIt.get<NetClientProvider>().get(_fakeFormUrl);
    if (rawDataResp.statusCode != HttpStatus.ok) {
      throw HttpRequestFailedException(rawDataResp.statusCode!);
    }
    final data = rawDataResp.data as String;
    final match = _layerLoginRe.firstMatch(data);
    final loginHash = match?.namedGroup('Hash');
    if (loginHash == null) {
      throw LoginFormHashNotFoundException();
    }

    final formHashMatch = _formHashRe.firstMatch(data);
    final formHash = formHashMatch?.namedGroup('FormHash');
    if (formHash == null) {
      throw LoginInvalidFormHashException();
    }

    debug('get login hash $loginHash');
    return LoginHash(formHash: formHash, loginHash: loginHash);
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
    final userLoginInfo = switch (credential.loginField) {
      LoginField.username => UserLoginInfo(
          username: credential.loginFieldValue,
          uid: null,
          email: null,
        ),
      LoginField.uid => UserLoginInfo(
          username: null,
          uid: credential.loginFieldValue.parseToInt(),
          email: null,
        ),
      LoginField.email => UserLoginInfo(
          username: null,
          uid: null,
          email: credential.loginFieldValue,
        ),
    };

    final netClient =
        await NetClientProvider.build(userLoginInfo: userLoginInfo);
    final resp = await netClient.postForm(target, data: credential.toJson());
    if (resp.statusCode != HttpStatus.ok) {
      throw HttpRequestFailedException(resp.statusCode!);
    }
    final document = parseHtmlDocument(resp.data as String);
    final messageNode = document.getElementById('messagetext');
    if (messageNode == null) {
      error('failed to check login result: result node not found');
      throw LoginMessageNotFoundException();
    }

    final loginResult = LoginResult.fromLoginMessageNode(messageNode);
    if (loginResult == LoginResult.success) {
      // Get complete user info from page.
      final fullInfoResp = await netClient.get(_passwordSettingsUrl);
      if (fullInfoResp.statusCode != HttpStatus.ok) {
        error('failed to fetch complete user info: '
            'code=${fullInfoResp.statusCode}');
        throw LoginUserInfoNotFoundException();
      }
      final fullInfoDoc = parseHtmlDocument(fullInfoResp.data as String);
      final fullUserInfo =
          _parseUserInfoFromDocument(fullInfoDoc, parseEmail: true);
      if (fullUserInfo == null || !fullUserInfo.isComplete) {
        error('failed to check login result: user info is null');
        throw LoginUserInfoNotFoundException();
      }

      await _saveLoggedUserInfo(fullUserInfo);

      _authedUser = UserLoginInfo(
        username: fullUserInfo.username,
        uid: fullUserInfo.uid,
        email: fullUserInfo.email,
      );
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

    // Second check for email.
    // Get complete user info from page.
    final fullInfoResp =
        await (await NetClientProvider.build(userLoginInfo: userInfo))
            .get(_passwordSettingsUrl);
    if (fullInfoResp.statusCode != HttpStatus.ok) {
      error('failed to fetch complete user info: '
          'code=${fullInfoResp.statusCode}');
      return;
    }
    final fullInfoDoc = parseHtmlDocument(fullInfoResp.data as String);
    final fullUserInfo =
        _parseUserInfoFromDocument(fullInfoDoc, parseEmail: true);
    if (fullUserInfo == null || !fullUserInfo.isComplete) {
      error('failed to: parse login result: email not foudn');
      return;
    }
    await _saveLoggedUserInfo(fullUserInfo);

    _authedUser = fullUserInfo;
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

    await getIt.get<StorageProvider>().deleteCookieByUid(_authedUser!.uid!);

    final settings = getIt.get<SettingsRepository>();
    await settings.deleteValue(SettingsKeys.loginUsername);
    await settings.deleteValue(SettingsKeys.loginUid);
    await settings.deleteValue(SettingsKeys.loginEmail);

    _authedUser = null;
    _controller.add(AuthenticationStatus.unauthenticated);
  }

  /// Parse html [document], find current logged in user uid in it.
  ///
  /// Set [parseEmail] to true if [document] predicted to contain user email.
  /// Now only support parsing email from password settings page.
  UserLoginInfo? _parseUserInfoFromDocument(
    uh.Document document, {
    bool parseEmail = false,
  }) {
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
    final uid = userNode.firstHref()?.split('uid=').lastOrNull?.parseToInt();
    if (uid == null) {
      debug('auth failed: user id not found');
      return null;
    }

    String? email;
    if (parseEmail) {
      email = document.querySelector('input#emailnew')?.attributes['value'];
    }
    return UserLoginInfo(uid: uid, username: username, email: email);
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

  Future<void> _saveLoggedUserInfo(UserLoginInfo userInfo) async {
    // Save logged user info in settings.
    final settings = getIt.get<SettingsRepository>();
    await settings.setValue<String>(
      SettingsKeys.loginUsername,
      userInfo.username!,
    );
    await settings.setValue<int>(
      SettingsKeys.loginUid,
      userInfo.uid!,
    );
    await settings.setValue<String>(
      SettingsKeys.loginEmail,
      userInfo.email!,
    );
  }
}
