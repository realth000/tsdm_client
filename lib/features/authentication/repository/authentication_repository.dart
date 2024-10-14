import 'dart:async';
import 'dart:io' if (dart.libaray.js) 'package:web/web.dart';

import 'package:fpdart/fpdart.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/fp.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
// import 'package:tsdm_client/features/authentication/repository/internal/login_result.dart';
import 'package:tsdm_client/features/authentication/repository/models/models.dart';
import 'package:tsdm_client/features/settings/repositories/settings_repository.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/cookie_provider/models/cookie_data.dart';
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

  // FIXME: Refactor login base url.
  static const _loginBaseUrl =
      '$baseUrl/member.php?mobile=yes&tsdmapp=1&mod=logging&action=login&loginsubmit=yes';
  static const _logoutBaseUrl =
      '$baseUrl/member.php?mod=logging&action=logout&formhash=';
  static const _fakeFormUrl =
      '$baseUrl/member.php?mod=logging&action=login&infloat=yes&frommessage&inajax=1&ajaxtarget=messagelogin';
  static const _passwordSettingsUrl =
      '$baseUrl/home.php?mod=spacecp&ac=profile&op=password';
  static final _layerLoginRe = RegExp(r'layer_login_(?<Hash>\w+)');
  static final _formHashRe = RegExp(r'formhash" value="(?<FormHash>\w+)"');

  // static String _buildLoginUrl(String formHash) {
  //   return '$_loginBaseUrl$formHash';
  // }

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
  AsyncEither<LoginHash> fetchHash() =>
      getIt.get<NetClientProvider>().get(_fakeFormUrl).flatMap((v) {
        // TODO: Parse CDATA.
        // 返回的data是xml：
        //
        // <?xml version="1.0" encoding="utf-8"?>
        // <root><![CDATA[
        // <div id="main_messaqge_L5hJN">
        // <div id="layer_login_L5hJN">
        //
        // 其中"main_message_"后面的是本次登录的loginHash，登录时需要加到url上
        if (v.statusCode != HttpStatus.ok) {
          return taskLeft(HttpRequestFailedException(v.statusCode));
        }
        final data = v.data as String;
        final match = _layerLoginRe.firstMatch(data);
        final loginHash = match?.namedGroup('Hash');
        if (loginHash == null) {
          return taskLeft(LoginFormHashNotFoundException());
        }

        final formHashMatch = _formHashRe.firstMatch(data);
        final formHash = formHashMatch?.namedGroup('FormHash');
        if (formHash == null) {
          return taskLeft(LoginInvalidFormHashException());
        }

        debug('get login hash $loginHash');
        return taskRight(LoginHash(formHash: formHash, loginHash: loginHash));
      });

  /// Login with password and other parameters in [credential].
  ///
  /// Will not change authentication status if failed to login.
  AsyncVoidEither loginWithPassword(UserCredential credential) =>
      AsyncVoidEither(() async {
        const target = _loginBaseUrl; // _buildLoginUrl(credential.formHash);
        // final userLoginInfo = switch (credential.loginField) {
        //   LoginField.username => UserLoginInfo(
        //       username: credential.loginFieldValue,
        //       uid: null,
        //       // email: null,
        //     ),
        //   LoginField.uid => UserLoginInfo(
        //       username: null,
        //       uid: credential.loginFieldValue.parseToInt(),
        //       // email: null,
        //     ),
        //   LoginField.email => UserLoginInfo(
        //       username: null,
        //       uid: null,
        //       email: credential.loginFieldValue,
        //     ),
        // };

        // debug('login with user info: $userLoginInfo');
        // Here the userLoginInfo is incomplete:
        //
        // Only contains one login field: Username, uid or email.
        final netClient = NetClientProvider.build(
            // userLoginInfo: userLoginInfo,
            // startLogin: true,
            );

        final respEither =
            await netClient.postForm(target, data: credential.toJson()).run();
        if (respEither.isLeft()) {
          return left(respEither.unwrapErr());
        }

        final resp = respEither.unwrap();
        if (resp.statusCode != HttpStatus.ok) {
          return left(HttpRequestFailedException(resp.statusCode));
        }
        final loginResult = LoginResultMapper.fromJson(resp.data as String);
        if (loginResult.status != 0) {
          error('failed to login: $loginResult}');
          return left(LoginOtherErrorException('login failed'));
        }

        final userInfo = UserLoginInfo(
          username: loginResult.values!.username,
          uid: int.parse(loginResult.values!.uid!),
        );
        await CookieData.endLogin(userInfo);

        // final document = parseHtmlDocument(resp.data as String);
        // final messageNode = document.getElementById('messagetext');
        // if (messageNode == null) {
        //   error('failed to check login result: result node not found');
        //   return left(LoginMessageNotFoundException());
        // }

        // final loginResult = LoginResult.fromLoginMessageNode(messageNode);
        // if (loginResult == LoginResult.success) {
        //   // Get complete user info from page.
        //   final fullInfoRespEither =
        //       await netClient.get(_passwordSettingsUrl).run();
        //   if (fullInfoRespEither.isLeft()) {
        //     return left(fullInfoRespEither.unwrapErr());
        //   }

        //   final fullInfoResp = fullInfoRespEither.unwrap();
        //   if (fullInfoResp.statusCode != HttpStatus.ok) {
        //     error('failed to fetch complete user info: '
        //         'code=${fullInfoResp.statusCode}');
        //     return left(LoginUserInfoNotFoundException());
        //   }
        //   final fullInfoDoc = parseHtmlDocument(fullInfoResp.data as String);
        //   final fullUserInfo =
        //       _parseUserInfoFromDocument(fullInfoDoc, parseEmail: true);
        //   if (fullUserInfo == null || !fullUserInfo.isComplete) {
        //     error('failed to check login result: user info is null');
        //     return left(LoginUserInfoNotFoundException());
        //   }

        //   // Mark login progress has ended.
        //   await CookieData.endLogin(fullUserInfo);

        // Here we get complete user info.
        await _saveLoggedUserInfo(userInfo);

        debug('login finished');

        _controller.add(AuthenticationStatus.authenticated);

        return rightVoid();
      });

  /// Parse logged user info from html [document].
  AsyncVoidEither loginWithDocument(uh.Document document) =>
      AsyncVoidEither(() async {
        final userInfo = _parseUserInfoFromDocument(document);
        if (userInfo == null) {
          debug('failed to login with document: user info not found');
          return left(LoginUserInfoNotFoundException());
        }

        // Second check for email.
        // Get complete user info from page.
        final fullInfoRespEither =
            await NetClientProvider.build(userLoginInfo: userInfo)
                .get(_passwordSettingsUrl)
                .run();
        if (fullInfoRespEither.isLeft()) {
          return left(fullInfoRespEither.unwrapErr());
        }
        final fullInfoResp = fullInfoRespEither.unwrap();
        if (fullInfoResp.statusCode != HttpStatus.ok) {
          error('failed to fetch complete user info: '
              'code=${fullInfoResp.statusCode}');
          return left(HttpRequestFailedException(fullInfoResp.statusCode));
        }
        final fullInfoDoc = parseHtmlDocument(fullInfoResp.data as String);
        final fullUserInfo =
            _parseUserInfoFromDocument(fullInfoDoc, parseEmail: true);
        if (fullUserInfo == null || !fullUserInfo.isComplete) {
          error('failed to: parse login result: email not found');
          return left(LoginUserInfoIncompleteException());
        }

        // Here we get complete user info.
        await _saveLoggedUserInfo(fullUserInfo);
        _controller.add(AuthenticationStatus.authenticated);

        debug('login with document: user $userInfo');
        return rightVoid();
      });

  /// Logout the current user.
  ///
  /// Check authentication status first then try to logout.
  /// Do nothing if already unauthenticated.
  AsyncVoidEither logout() => AsyncVoidEither(() async {
        if (_authedUser == null) {
          return rightVoid();
        }
        final netClient = NetClientProvider.build(
          userLoginInfo: UserLoginInfo(
            username: _authedUser!.username,
            uid: _authedUser!.uid,
            // email: _authedUser!.email,
          ),
          logout: true,
        );
        final respEither = await netClient.get(_checkAuthUrl).run();
        if (respEither.isLeft()) {
          return left(respEither.unwrapErr());
        }
        final resp = respEither.unwrap();
        if (resp.statusCode != HttpStatus.ok) {
          return left(HttpRequestFailedException(resp.statusCode));
        }
        final document = parseHtmlDocument(resp.data as String);
        final userInfo = _parseUserInfoFromDocument(document);
        if (userInfo == null) {
          // Not logged in.

          _authedUser = null;
          _controller.add(AuthenticationStatus.unauthenticated);
          return rightVoid();
        }
        final formHash = _formHashRe
            .firstMatch(document.body?.innerHtml ?? '')
            ?.namedGroup('FormHash');
        if (formHash == null) {
          return left(LogoutFormHashNotFoundException());
        }

        final logoutRespEither =
            await netClient.get(_buildLogoutUrl(formHash)).run();
        if (logoutRespEither.isLeft()) {
          return left(logoutRespEither.unwrapErr());
        }
        final logoutResp = logoutRespEither.unwrap();
        if (logoutResp.statusCode != HttpStatus.ok) {
          return left(HttpRequestFailedException(logoutResp.statusCode));
        }
        final logoutDocument = parseHtmlDocument(logoutResp.data as String);
        final logoutMessage = logoutDocument.getElementById('messagetext');
        if (logoutMessage == null ||
            !logoutMessage.innerHtmlEx().contains('已退出')) {
          // TODO: Here we'd better to check the failed reason.
          return left(LogoutFailedException());
        }

        await getIt.get<StorageProvider>().deleteCookieByUid(_authedUser!.uid!);

        final settings = getIt.get<SettingsRepository>();
        await settings.deleteValue(SettingsKeys.loginUsername);
        await settings.deleteValue(SettingsKeys.loginUid);
        await settings.deleteValue(SettingsKeys.loginEmail);

        _authedUser = null;
        _controller.add(AuthenticationStatus.unauthenticated);

        return rightVoid();
      });

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

    // String? email;
    // if (parseEmail) {
    //   email = document.querySelector('input#emailnew')?.attributes['value'];
    // }
    return UserLoginInfo(
      uid: uid,
      username: username, /*email: email*/
    );
  }

  /// Parse the login result.
  ///
  /// Do nothing if login succeed.
// SyncVoidEither _mapLoginResult(LoginResult loginResult) =>
//     switch (loginResult) {
//       LoginResult.success => rightVoid(),
//       LoginResult.incorrectCaptcha => left(LoginIncorrectCaptchaException()),
//       LoginResult.invalidUsernamePassword =>
//         left(LoginInvalidCredentialException()),
//       LoginResult.incorrectQuestionOrAnswer =>
//         left(LoginIncorrectSecurityQuestionException()),
//       LoginResult.attemptLimit => left(LoginAttemptLimitException()),
//     LoginResult.otherError => left(LoginOtherErrorException('other error')),
//     LoginResult.unknown => left(LoginOtherErrorException('unknown result')),
//     };

  Future<void> _saveLoggedUserInfo(UserLoginInfo userInfo) async {
    debug('save logged user info: $userInfo');
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
    // await settings.setValue<String>(
    //   SettingsKeys.loginEmail,
    //   userInfo.email!,
    // );

    _authedUser = userInfo;
  }
}
