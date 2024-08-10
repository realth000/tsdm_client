import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/features/settings/repositories/settings_repository.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

/// Repository to get profile page.
final class ProfileRepository with LoggerMixin {
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
  Future<uh.Document?> fetchProfile({
    String? username,
    String? uid,
    bool force = false,
  }) async {
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
      final loginEmail = settings.loginEmail;
      // TODO: Check if this condition check works during login progress.
      if (loginUsername.isEmpty || loginUid == 0 || loginEmail.isEmpty) {
        // Not logged in.
        return null;
      }
      if (!force && _loggedUserDocument != null) {
        return _loggedUserDocument;
      }
      targetUrl = '$uidProfilePage$loginUid';
      isLoggedUserProfile = true;
    }

    try {
      final resp = await getIt.get<NetClientProvider>().get(targetUrl);
      final document = parseHtmlDocument(resp.data as String);
      if (isLoggedUserProfile) {
        _loggedUserDocument = document;
      }
      return document;
    } on HttpRequestFailedException catch (e) {
      error('failed to get profile: $targetUrl, $e');
      rethrow;
    }
  }
}
