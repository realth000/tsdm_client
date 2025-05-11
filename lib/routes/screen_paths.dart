/// All app routes.
class ScreenPaths {
  ScreenPaths._();

  /// Root page to load `RootSingleton` page.
  static const String root = '/';

  /// App about page.
  static const String about = '/about';

  /// App license page.
  static const String license = '/license';

  /// Detail page of license of a package.
  static const String licenseDetail = '/license_detail/:package/:license';

  /// Sub form page.
  ///
  /// Need to specify forum id (fid).
  static const String forum = '/forum/:fid';

  /// Forum group page.
  ///
  /// Show the group specified by group id `gid`.
  static const String forumGroup = '/forumGroup/:gid';

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

  /// Edit user avatar.
  static const String editAvatar = '/editAvatar';

  /// Page to switch current user's user group.
  static const String switchUserGroup = '/switchUserGroup';

  /// App settings page.
  static const settings = NestedPath._('/settings');

  /// Settings page for thread card appearance.
  static const settingsThreadAppearance = NestedPath._('threadAppearance', settings);

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
  ///
  /// `overrideWithExactOrder`: set the exact thread order type, this value
  /// is usually specified by the original source (in url).
  static const String threadV1 = '/thread/v1';

  /// V2 version of the thread page.
  ///
  /// # Parameters
  ///
  /// `id` is thread id.
  ///
  /// `overrideReverseOrder`: set to "false" keep the original post order in
  /// thread, for some use case user heading to a page contains a certain post.
  ///
  /// `overrideWithExactOrder`: set the exact thread order type, this value
  /// is usually specified by the original source (in url).
  static const String threadV2 = '/thread/v2/:id';

  /// Notice page.
  ///
  /// Show all notice and private messages on current user.
  static const String notice = '/notice';

  /// Search notice.
  static const String noticeSearch = '/noticeSearch';

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
  static const String editPost = '/editPost/:editType/:fid';

  /// Page to show image in full page.
  static const String imageDetail = '/imageDetail/:imageUrl';

  /// Page to view and thread visit history.
  static const String threadVisitHistory = '/threadVisitHistory';

  /// Page  to show auto checkin detail information.
  static const String autoCheckinDetail = '/autoCheckinDetail';

  /// Page to show logs for debugging.
  static const String debugLog = '/debugLog';

  /// Page to show packet statistics detail info of a thread.
  static const String packetDetail = '/packetDetail/:tid';

  /// Page to manage user account for multi-user target.
  static const String manageAccount = '/manageAccount';

  /// Page to get app updates.
  static const String update = '/update';

  /// Page to show the changelog bundled with app.
  static const String localChangelog = '/localChangelog';
}

/// Route paths for all temporary dialogs and bottom sheets in app.
///
/// These paths are used for tracking current locations with dialog routes support.
/// All dialogs shall specify these paths with wrapped `RootPage`.
class DialogPaths {
  const DialogPaths._();

  /// Dialog to select language.
  static const String selectLanguage = '/dialog/selectLanguage';

  /// Dialog to pick image.
  static const String imagePicker = '/dialog/imagePicker';

  /// Dialog to pick url.
  static const String urlPicker = '/dialog/urlPicker';

  /// Dialog to pick username.
  static const String usernamePicker = '/dialog/usernamePicker';

  /// Dialog to show image detail.
  static const String imageDetail = '/dialog/imageDetail';

  /// Dialog to manage logged user.
  static const String manageUser = '/dialog/manageUser';

  /// Dialog to parse user input url into app known targets.
  static const String parseUrl = '/dialog/parseUrl';

  /// Dialog to let user input thread price.
  static const String inputPrice = '/dialog/inputThreadPrice';

  /// Dialog to let user select thread read perm.
  static const String selectPerm = '/dialog/selectPerm';

  /// Dialog to let user select reason why rate the post.
  static const String selectRateReason = '/dialog/selectRateReason';

  /// Dialog to notice user that newer version is available.
  static const String updateNotice = '/dialog/updateNotice';

  /// Dialog to let user select all pages in thread could jump to.
  static const String jumpPage = '/dialog/jumpPage';

  /// Dialog to let user picker a font.
  static const String fontPicker = '/dialog/fontPicker';

  /// Dialog to let user select the duration between auto syncing notice events.
  static const String selectAutoSyncDuration = '/dialog/selectAutoSyncDuration';

  /// Dialog to let user select checkin feeling.
  static const String selectCheckinFeeling = '/dialog/selectCheckinFeeling';

  /// Dialog to let user select checkin message.
  static const String selectCheckinMessage = '/dialog/selectCheckinMessage';

  /// Dialog to let user manage proxy settings.
  static const String setupProxy = '/dialog/setupProxy';

  /// Dialog to show thread operation log.
  static const String showOperationLog = '/dialog/showOperationLog';

  /// Common dialog to show message with only one button in action.
  static const String messageSingleButton = '/dialog/messageSingleButton';

  /// Common dialog to show question.
  static const String question = '/dialog/question';

  /// Dialog to let user copy contents.
  static const String copyContent = '/dialog/copyContent';

  /// Bottom sheet to let user pick color.
  static const String colorPicker = '/dialog/colorPicker';

  /// Bottom sheet to let user pick emoji.
  static const String emojiPicker = '/dialog/emojiPicker';

  /// Bottom sheet provide options to clear cache.
  static const String clearCache = '/dialog/clearCache';
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
