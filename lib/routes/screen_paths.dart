/// All app routes.
class ScreenPaths {
  /// Root page to load [homepage].
  static const String root = '/';

  /// App about page.
  static const String about = '/about';

  /// Sub form page.
  ///
  /// Need to specify forum id (fid).
  static const String forum = '/forum/:fid';

  /// Homepage: "https://www.tsdm39.com/forum.php"
  ///
  /// Only the very first part of page.
  static const String homepage = '/homepage';

  /// Homepage: "https://www.tsdm39.com/forum.php"
  ///
  /// Rest part of homepage, including all topics.
  /// Contains groups of sub-forums.
  static const String topic = '/topic';

  /// App login page.
  ///
  static const String login = '/login';

  /// A notice page that show the user need to login to see this page.
  static const String needLogin = '/needLogin';

  /// Another login page, uses when website requires to login.
  ///
  /// Redirect to former page when successfully login,
  /// need to specify the former page.
  static const String loginRedirect = '/login/redirect';

  /// User profile page.
  static const String profile = '/profile';

  /// App settings page.
  static const String settings = '/settings';

  /// Thread page.
  static const String thread = '/thread/:tid';

  /// Notice page.
  ///
  /// Show all notice and private messages on current user.
  static const String notice = '/notice';

  /// Reply page.
  ///
  /// Reply to a notice or message.
  /// Currently only reply to a post with given pid in thread.
  static const String reply = '/reply/:target';

  /// Search page.
  static const String search = '/search';
}
