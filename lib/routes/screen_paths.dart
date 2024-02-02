/// All app routes.
class ScreenPaths {
  /// Root page to load [homepage].
  static const String root = '/';

  /// App about page.
  static const String about = '/about';

  /// App license page.
  static const String license = '/license';

  /// Detail page of license of a package.
  static const String licenseDetail = '/license_detail/:package/:license';

  /// Page to get latest version.
  static const String upgrade = '/upgrade';

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

  /// Logged user profile page.
  static const String loggedUserProfile = '/myProfile';

  /// Other not logged user profile page.
  ///
  ///
  /// User identity MUST be provided in **queryParameters** because we need to
  ///  accept both uid and username.
  /// When both are available, use uid in advance.
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

  /// Page to show "My thread" on web side.
  ///
  /// https://tsdm39.com/home.php?mod=space&do=thread&view=me
  /// Even when redirect to this route, query parameters contain uid, only the page of current user is visible.
  /// https://tsdm39.com/home.php?mod=space&uid=xxx&do=thread&view=me
  static const String myThread = '/myThread';

  /// Page to show "Latest thread" on web side.
  ///
  /// https://tsdm39.com/home.php?mod=forum&searchid=xxx&orderby...
  static const String latestThread = '/latestPage';

  /// Page to rate a post in thread.
  static const String ratePost = '/ratePost/:username/:pid/:floor/:rateAction';
}
