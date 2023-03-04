/// All app routes.
class TClientRoute {
  /// App about page.
  static const String about = '/about';

  /// Sub form page.
  ///
  /// Need to specify forum id (fid).
  static const String forum = '/forum/:fid';

  /// Homepage: "https://www.tsdm39.net/forum.php"
  static const String homepage = '/homepage';

  /// App login page.
  ///
  /// Redirect to user profile page.
  static const String login = '/login';

  /// Another login page, uses when website requires to login.
  ///
  /// Redirect to former page when successfully login,
  /// need to specify the former page.
  static const String loginRedirect = '/login/redirect';

  /// User profile page.
  ///
  /// Need to specify username (username).
  static const String profile = '/profile/:username';

  /// App settings page.
  static const String settings = '/settings';
}
