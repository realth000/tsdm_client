import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/shared/providers/server_time_provider/sevrer_time_provider.dart';
import 'package:tsdm_client/shared/providers/settings_provider/settings_provider.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

/// Repository to get profile page.
class ProfileRepository {
  uh.Document? _loggedUserDocument;

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
  ///
  /// # Exception
  ///
  /// * [HttpRequestFailedException] when http request failed.
  Future<uh.Document?> fetchProfile(
      {String? username, String? uid, bool force = false}) async {
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
      final loggedUser = getIt.get<SettingsProvider>().getLoginInfo();
      if ((loggedUser.$1?.isEmpty ?? true) ||
          (loggedUser.$2 == null || (loggedUser.$2! < 0))) {
        // Not logged in.
        return null;
      }
      if (!force && _loggedUserDocument != null) {
        return _loggedUserDocument;
      }
      targetUrl = '$uidProfilePage${loggedUser.$2}';
      isLoggedUserProfile = true;
    }

    try {
      final resp = await getIt.get<NetClientProvider>().get(targetUrl);
      final document = parseHtmlDocument(resp.data as String);
      if (isLoggedUserProfile) {
        _loggedUserDocument = document;
      }
      getIt.get<ServerTimeProvider>().updateServerTimeWithDocument(document);
      return document;
    } on HttpRequestFailedException catch (e) {
      debug('failed to get profile: $targetUrl, $e');
      rethrow;
    }
  }
}
