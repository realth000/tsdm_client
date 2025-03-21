import 'dart:async';
import 'dart:convert';
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
import 'package:tsdm_client/shared/providers/cookie_provider/cookie_provider.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/shared/providers/providers.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

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
  static const _loginBaseUrl = '$baseUrl/member.php?mobile=yes&tsdmapp=1&mod=logging&action=login&loginsubmit=yes';
  static const _logoutBaseUrl = '$baseUrl/member.php?mod=logging&action=logout&formhash=';
  static const _fakeFormUrl =
      '$baseUrl/member.php?mod=logging&action=login&infloat=yes&frommessage&inajax=1&ajaxtarget=messagelogin';
  static final _layerLoginRe = RegExp(r'layer_login_(?<Hash>\w+)');
  static final _formHashRe = RegExp(r'formhash" value="(?<FormHash>\w+)"');

  /// Url to check authentication status using v2 API.
  static const _checkAuthUrlV2 = '$baseUrl/home.php?mobile=yes&tsdmapp=1&mod=space&do=profile';

  // static String _buildLoginUrl(String formHash) {
  //   return '$_loginBaseUrl$formHash';
  // }

  static String _buildLogoutUrl(String formHash) {
    return '$_logoutBaseUrl$formHash';
  }

  /// Provide a stream of [AuthStatus].
  ///
  /// Be aware that the data contained in stream is not the state in auth bloc.
  final _controller = BehaviorSubject<AuthStatus>();

  UserLoginInfo? _authedUser;

  /// The current logged user.
  UserLoginInfo? get currentUser => _authedUser;

  /// Authentication status stream.
  Stream<AuthStatus> get status => _controller.asBroadcastStream();

  /// Dispose the resources.
  void dispose() {
    _controller.close();
  }

  /// Fetch login hash and form hash for logging in.
  AsyncEither<LoginHash> fetchHash() =>
      getIt.get<NetClientProvider>(instanceName: ServiceKeys.noCookie).get(_fakeFormUrl).flatMap((v) {
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
  AsyncVoidEither loginWithPassword(UserCredential credential) => AsyncVoidEither(() async {
    debug('login with passwd');
    await _markUnauthenticated();
    // When login with password, use an empty and injected cookie when
    // performing login request. Because :
    //
    // * Want to use a pure and clean cookie when start login, to avoid
    //   using current authed user's cookie.
    // * Control when and what user info to save with the cookie stored in
    //   it, so that the token is successfully saved in storage.
    final cookie = getIt.get<CookieProvider>(instanceName: ServiceKeys.empty);
    // Inject cookie provider.
    final netClient = NetClientProvider.buildNoCookie(cookie: cookie, forceDesktop: false);

    final respEither = await netClient.postForm(_loginBaseUrl, data: credential.toJson()).run();
    if (respEither.isLeft()) {
      return left(respEither.unwrapErr());
    }

    final resp = respEither.unwrap();
    if (resp.statusCode != HttpStatus.ok) {
      return left(HttpRequestFailedException(resp.statusCode));
    }

    return Option.tryCatch(() => LoginResultMapper.fromJson(resp.data as String)).match(
      () {
        // Can not convert to regular login success result.
        final json = jsonDecode(resp.data as String) as Map<String, dynamic>?;
        final message = json?['message'] as String?;

        if (message == null) {
          return left(LoginOtherErrorException('message not found'));
        }

        final err = switch (message) {
          'login_invalid' => LoginInvalidCredentialException(),
          'login_strike' => LoginAttemptLimitException(),
          'err_login_captcha_invalid' => LoginIncorrectCaptchaException(),
          final String v => LoginOtherErrorException('unknown error message $v'),
        };
        return left(err);
      },
      (loginResult) async {
        if (loginResult.status != 0) {
          error('failed to login: $loginResult}');
          return left(LoginOtherErrorException('login failed, status=${loginResult.status}'));
        }

        // Here we get complete user info.
        final userInfo = UserLoginInfo(
          username: loginResult.values!.username,
          uid: int.parse(loginResult.values!.uid!),
        );
        // First combine user info and cookie together.
        await cookie.updateUserInfo(userInfo);
        // Second, save credential in storage.
        await cookie.saveCookieToStorage();
        // Refresh the cookie in global cookie provider.
        await getIt.get<CookieProvider>().loadCookieFromStorage(userInfo);
        // Finally save authed user info and update authentication status to
        // let auth stream subscribers update their status.
        await _markAuthenticated(userInfo);
        debug('end login with success');

        return rightVoid();
      },
    );
  });

  /// Parse logged user info from html [document].
  AsyncVoidEither loginWithDocument(uh.Document document) => AsyncVoidEither(() async {
    // Do NOT mark as unauthenticated here because auth with document is
    // only used as a verification of a token that intend to be valid. It's
    // outside the regular login progress.
    final userInfo = _parseUserInfoFromDocument(document);
    if (userInfo == null) {
      debug('failed to login with document: user info not found');
      return left(LoginUserInfoNotFoundException());
    }

    // Here we get complete user info.
    await getIt.get<CookieProvider>().saveCookieToStorage();
    await _markAuthenticated(userInfo);

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
      userLoginInfo: UserLoginInfo(username: _authedUser!.username, uid: _authedUser!.uid),
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
      await _markUnauthenticated();
      return rightVoid();
    }
    final formHash = _formHashRe.firstMatch(document.body?.innerHtml ?? '')?.namedGroup('FormHash');
    if (formHash == null) {
      return left(LogoutFormHashNotFoundException());
    }

    final logoutRespEither = await netClient.get(_buildLogoutUrl(formHash)).run();
    if (logoutRespEither.isLeft()) {
      return left(logoutRespEither.unwrapErr());
    }
    final logoutResp = logoutRespEither.unwrap();
    if (logoutResp.statusCode != HttpStatus.ok) {
      return left(HttpRequestFailedException(logoutResp.statusCode));
    }
    final logoutDocument = parseHtmlDocument(logoutResp.data as String);
    final logoutMessage = logoutDocument.getElementById('messagetext');
    if (logoutMessage == null || !logoutMessage.innerHtmlEx().contains('已退出')) {
      // TODO: Here we'd better to check the failed reason.
      return left(LogoutFailedException());
    }

    getIt.get<CookieProvider>().clearUserInfoAndCookie();
    await getIt.get<StorageProvider>().deleteCookieByUid(_authedUser!.uid!);
    await _markUnauthenticated();
    return rightVoid();
  });

  /// Switch to another user described in [userInfo].
  ///
  /// Return [SwitchUserNotAuthedException] if failed.
  AsyncVoidEither switchUser(UserLoginInfo userInfo) => AsyncVoidEither(() async {
    if (!await getIt.get<CookieProvider>().loadCookieFromStorage(userInfo)) {
      return left(LoginInvalidCredentialException());
    }
    final resp = await getIt.get<NetClientProvider>().get(_checkAuthUrlV2).run();
    if (resp.isLeft()) {
      return left(resp.unwrapErr());
    }

    final result = jsonDecode(resp.unwrap().data as String) as Map<String, dynamic>;
    if (result['status'] != 0) {
      error(
        'failed to switch user to uid=${"${userInfo.uid}".obscured(4)}, '
        'status=${result["status"]}, '
        'message=${result["message"]}',
      );
      return left(SwitchUserNotAuthedException());
    }

    // Succeed.
    // Here we get complete user info.
    await getIt.get<CookieProvider>().saveCookieToStorage();
    await _markAuthenticated(userInfo);

    debug('login with document: user $userInfo');
    return rightVoid();
  });

  /// Parse html [document], find current logged in user uid in it.
  UserLoginInfo? _parseUserInfoFromDocument(uh.Document document) {
    final userNode =
        // Style 1: With avatar.
        document.querySelector('div#hd div.wp div.hdc.cl div#um p strong.vwmy a') ??
        // Style 2: Without avatar.
        document.querySelector('div#inner_stat > strong > a');
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
    return UserLoginInfo(uid: uid, username: username /*email: email*/);
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
    await settings.setValue<String>(SettingsKeys.loginUsername, userInfo.username!);
    await settings.setValue<int>(SettingsKeys.loginUid, userInfo.uid!);
    // await settings.setValue<String>(
    //   SettingsKeys.loginEmail,
    //   userInfo.email!,
    // );

    _authedUser = userInfo;
  }

  /// All steps need to execute when state should change to authed except saving
  /// cookies because sometimes the cookie provider holding latest authed cookie
  /// is not the one global wide.
  ///
  /// This function does something that need to be completed before auth state
  /// changes so that all auth stream subscribers are using the correct data in
  /// authed state.
  Future<void> _markAuthenticated(UserLoginInfo userInfo) async {
    // Save user info to memory and storage.
    await _saveLoggedUserInfo(userInfo);
    // Clear cookie.
    await getIt<CookieProvider>().updateUserInfo(UserLoginInfo(username: userInfo.username, uid: userInfo.uid));
    // Do NOT save cookie to storage here, because it's not always the normal
    // global cookie provider doing the auth work, maybe another local cookie in
    // some scope.
    // Instead, save cookie outside this function when necessary.
    // await getIt<CookieProvider>().saveCookieToStorage();
    // Finally change state to authed.
    _controller.add(AuthStatusAuthed(userInfo));
  }

  /// All actions need to execute when state should change to unauthenticated.
  ///
  /// This function does something that need to be completed before auth state
  /// changes so that all auth stream subscribers are using the correct data in
  /// unauthenticated state.
  Future<void> _markUnauthenticated() async {
    final settings = getIt.get<SettingsRepository>();
    await settings.deleteValue(SettingsKeys.loginUsername);
    await settings.deleteValue(SettingsKeys.loginUid);
    await settings.deleteValue(SettingsKeys.loginEmail);
    _authedUser = null;
    _controller.add(const AuthStatusNotAuthed());
  }
}
