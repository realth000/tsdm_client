import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/features/profile/models/models.dart';
import 'package:tsdm_client/features/settings/repositories/settings_repository.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

/// Repository to get profile page.
final class ProfileRepository with LoggerMixin {
  static const _profileV2Target = '$baseUrl/home.php?mobile=yes&tsdmapp=1&mod=space';
  static const _editAvatarPage = '$baseUrl/home.php?mod=spacecp&ac=avatar';

  uh.Document? _loggedUserDocument;

  /// Cached profile v2 for current logged user.
  UserProfileV2? _loggedProfileV2;

  /// Check has cached html [_loggedUserDocument] for logged user or not.
  bool hasCache() => _loggedUserDocument != null;

  /// Get the cached [_loggedUserDocument] for logged user.
  uh.Document? getCache() => _loggedUserDocument;

  /// Clear cache as logged out.
  void logout() {
    _loggedUserDocument = null;
  }

  /// Profile page document cache;

  /// Fetch profile page from server.
  ///
  /// * Try to get the profile page of [uid] or [username] if provided.
  /// * Try to get current logged user profile if no parameter provided.
  /// * Return null if not logged in.
  AsyncEither<uh.Document> fetchProfile({String? username, String? uid, bool force = false}) => AsyncEither(() async {
    debug('fetch profile page');
    late final String targetUrl;
    late final bool isLoggedUserProfile;
    if (uid != null) {
      targetUrl = '$uidProfilePage$uid';
      isLoggedUserProfile = false;
    } else if (username != null) {
      targetUrl = '$usernameProfilePage$username';
      isLoggedUserProfile = false;
    } else {
      // Fetching logged user profile.
      final settings = getIt.get<SettingsRepository>().currentSettings;
      final loginUsername = settings.loginUsername;
      final loginUid = settings.loginUid;
      // TODO: Check if this condition check works during login progress.
      if (loginUsername.isEmpty || loginUid == 0) {
        warning(
          'fetch profile: not login, unsatisfied fields: '
          'name(${loginUsername.isEmpty}), uid(${loginUid == 0})',
        );
        // Not logged in.
        return left(ProfileNeedLoginException());
      }
      if (!force && _loggedUserDocument != null) {
        return right(_loggedUserDocument!);
      }
      targetUrl = '$uidProfilePage$loginUid';
      isLoggedUserProfile = true;
    }

    switch (await getIt.get<NetClientProvider>().get(targetUrl).run()) {
      case Left(:final value):
        return left(value);
      case Right(:final value):
        final document = parseHtmlDocument(value.data as String);
        if (isLoggedUserProfile) {
          _loggedUserDocument = document;
        }
        return right(document);
    }
  });

  /// Fetch user avatar for current user.
  AsyncEither<String> fetchAvatarUrl() => fetchProfileV2().map((v) => v.avatarUrl);

  /// Fetch user profile through API.
  ///
  /// ## Return value
  ///
  /// ### Success
  ///
  /// ```json
  /// {
  ///   "status": 0,
  ///   ... // Other fields can be converted into UserProfileV2.
  /// }
  /// ```
  ///
  /// ### Failure
  ///
  /// ```json
  /// {
  ///   "status": -1,
  ///   "message": "login_before_enter_home",
  ///   "url": null,
  ///   "extra": {
  ///     "showmsg": "1",
  ///     "login": "1"
  ///   },
  ///   "values": []
  /// }
  /// ```
  AsyncEither<UserProfileV2> fetchProfileV2({String? username, String? uid, bool force = false}) {
    return AsyncEither(() async {
      debug('fetch profile page v2');
      late final String targetUrl;
      late final bool isLoggedUserProfile;
      if (uid != null) {
        targetUrl = '$_profileV2Target&username=$uid';
        isLoggedUserProfile = false;
      } else if (username != null) {
        targetUrl = '$_profileV2Target&uid=$username';
        isLoggedUserProfile = false;
      } else {
        targetUrl = _profileV2Target;
        isLoggedUserProfile = true;
      }

      if (!force && _loggedProfileV2 != null) {
        return right(_loggedProfileV2!);
      }

      switch (await NetClientProvider.build(forceDesktop: false).get(targetUrl).run()) {
        case Left(:final value):
          return left(value);
        case Right(:final value):
          final jsonMap = jsonDecode(value.data as String) as Map<String, dynamic>;
          if (!jsonMap.containsKey('status')) {
            error('failed to fetch profile v2: status not found');
            return left(ProfileStatusNotFoundException());
          }
          final status = jsonMap['status'] as int?;
          if (status == -1) {
            error(
              'failed to fetch profile v2: '
              'message=${jsonMap.lookup("message")}',
            );
            return left(ProfileNeedLoginException());
          }
          if (status != 0) {
            error('failed to fetch profile v2: unknown status $status');
            return left(ProfileStatusUnknownException(jsonMap['status'].toString()));
          }
          // status is zero
          final userProfile = UserProfileV2Mapper.fromMap(jsonMap);

          if (isLoggedUserProfile) {
            _loggedProfileV2 = userProfile;
          }

          return right(userProfile);
      }
    });
  }

  /// Load the current using avatar url from server.
  AsyncEither<(String, String)> loadAvatarUrl() => getIt
      .get<NetClientProvider>()
      .get(_editAvatarPage)
      .mapHttp((v) => parseHtmlDocument(v.data as String))
      .map(
        (v) => (
          v.querySelector('input[name="headedit"]')?.attributes['value'],
          v.querySelector('input[name="formhash"]')?.attributes['value'],
        ),
      )
      .flatMap(
        (v) => switch (v) {
          (final String avatarUrl, final String formHash) => TaskEither.right((avatarUrl, formHash)),
          (_, _) => TaskEither.left(EditAvatarUrlNotFound()),
        },
      );

  /// Upload the new avatar [url] to server.
  AsyncVoidEither uploadAvatarUrl({required String url, required String formHash}) => getIt
      .get<NetClientProvider>()
      .postForm(_editAvatarPage, data: <String, String>{'headedit': url, 'formhash': formHash, 'headsubmit': '提交'})
      .mapHttp((v) => v);
}
