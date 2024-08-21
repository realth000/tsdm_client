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
  static const settings = NestedPath._('/settings');

  /// Settings page for thread card appearance.
  static const settingsThreadAppearance =
      NestedPath._('threadAppearance', settings);

  /// Thread page.
  ///
  /// Parameters MUST provided within the queryParameters.
  ///
  /// Especially the `tid` or `pid` parameters. Thr former one is used in most
  /// situations to locate and represent  an unique thread and the later one is
  /// used in some situation that we do not know the actual thread ID but we
  /// redirect by finding a post.
  ///
  /// Now the parameter is **implicitly** required by the related UI page, which
  /// is really a bad idea.
  ///
  /// # Parameters
  ///
  /// `tid` or `pid` MUST be provided through query parameter.
  ///
  /// `overrideReverseOrder`: set to "false" keep the original post order in
  /// thread, for some use case user heading to a page contains a certain post.
  static const String thread = '/thread';

  /// Notice page.
  ///
  /// Show all notice and private messages on current user.
  static const String notice = '/notice';

  /// Reply page.
  ///
  /// Reply to a notice or message.
  /// Currently only reply to a post with given pid in thread.
  static const String reply = '/reply/:target';

  /// Detail page of broadcast message.
  ///
  /// Show full content of broadcast message in this page.
  static const String broadcastMessageDetail = '/notice/broadcast/:pmid';

  /// Chat page describes the chat dialog on server side.
  ///
  /// Inside node `<div class="pm">`.
  ///
  /// May contains part of the chat history including recent messages.
  ///
  /// Can enter this page from:
  ///
  /// * Link in user dialog when mouse hover on thread floor brief profile.
  /// * Link in user profile page.
  ///
  /// Two method above both have the following format url:
  ///
  /// ``` bash
  /// ${HOST}/home.php?mod=spacecp&ac=pm&op=showmsg&
  /// handlekey=showmsg_${UID}&touid=${UID}&pmid=0&daterange=2
  /// ```
  static const String chat = '/chat/:uid';

  /// Chat history page mainly describes the chat history with another user.
  ///
  /// Only can enter this page from notification page.
  ///
  /// Have the following format url:
  ///
  /// ``` bash
  /// ${HOST}/home.php?mod=space&do=pm&subop=view&touid=${UID}
  /// ```
  static const String chatHistory = '/chat/history/:uid';

  /// Search page.
  static const String search = '/search';

  /// Page to show "My thread" on web side.
  ///
  /// https://tsdm39.com/home.php?mod=space&do=thread&view=me
  /// Even when redirect to this route, query parameters contain uid, only the
  /// page of current user is visible.
  /// https://tsdm39.com/home.php?mod=space&uid=xxx&do=thread&view=me
  static const String myThread = '/myThread';

  /// Page to show "Latest thread" on web side.
  ///
  /// https://tsdm39.com/home.php?mod=forum&searchid=xxx&orderby...
  static const String latestThread = '/latestPage';

  /// Page to rate a post in thread.
  static const String ratePost = '/ratePost/:username/:pid/:floor/:rateAction';

  /// The page to show current logged user's points statistics status
  /// and changelog.
  ///
  /// Need to login before see the content.
  static const String points = '/points';

  /// Page to edit a post or thread.
  ///
  /// Contains:
  ///
  /// * Write a new post.
  /// * Write a new thread (post at the first floor).
  /// * Edit an existing post.
  ///
  /// Index of `PostEditType` is needed to specify the reason.
  static const String editPost = '/editPost/:editType/:fid/:tid/:pid';

  /// Page to show image in full page.
  static const String imageDetail = '/imageDetail/:imageUrl';
}

/// Route path for a screen.
final class NestedPath {
  const NestedPath._(this._path, [this._parent]);

  final NestedPath? _parent;

  final String _path;

  /// Page path.
  String get path => _path;

  /// Full path.
  String get fullPath => _parent != null ? '${_parent.fullPath}/$path' : path;
}
