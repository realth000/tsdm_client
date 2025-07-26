/// Default cookie expiration time in seconds.
///
/// This is kept the same with server behavior.
const defaultCookieTime = 2592000;

/// Host in url.
const baseHost = 'www.tsdm39.com';

/// Host in url, without www prefix.
const baseHostAlt = 'tsdm39.com';

/// Server site base url.
const baseUrl = 'https://$baseHost';

/// Homepage of tsdm.
const homePage = '$baseUrl/forum.php';

/// Page to register new account
const signUpPage = '$baseUrl/member.php?mod=register.php';

/// User profile page for user with given uid.
const uidProfilePage = '$baseUrl/home.php?mod=space&uid=';

/// User profile page for user with given username.
const usernameProfilePage = '$baseUrl/home.php?mod=space&username=';

/// Default fallback user avatar url when user avatar is unavailable.
const noAvatarUrl = '$baseUrl/uc_server/images/noavatar_middle.gif';

/// Notice page of current logged user.
const noticeUrl = '$baseUrl/home.php?mod=space&do=notice';

/// All read notice page of current logged user.
const readNoticeUrl = '$baseUrl/home.php?mod=space&do=notice&isread=1';

/// Private personal messages.
const personalMessageUrl = '$baseUrl/home.php?mod=space&do=pm&filter=privatepm';

/// Broadcast messages.
const broadcastMessageUrl = '$baseUrl/home.php?mod=space&do=pm&filter=announcepm';

/// Broadcast message detail page.
const broadcastMessageDetailUrl = '$baseUrl/home.php?mod=space&do=pm&subop=viewg&pmid=';

/// Page contains all thread published by current logged user.
const myThreadThreadUrl = '$baseUrl/home.php?mod=space&do=thread&view=me&type=thread';

/// Page contains all posts (as replies in threads) published by current logged
/// user.
const myThreadReplyUrl = '$baseUrl/home.php?mod=space&do=thread&view=me&type=reply';

/// Page contains credential information of current user.
///
/// This page is also used for checking logged user info because it has the
/// complete information of current user:
/// * Username.
/// * Uid.
/// * Email address.
const modifyUserCredentialUrl = '$baseUrl/home.php?mod=spacecp&ac=profile&op=password';

/// Use [modifyUserCredentialUrl] to check user status.
///
/// This page contains full user info:
/// * Username
/// * UID
/// * User email
const checkAuthenticationStateUrl = modifyUserCredentialUrl;

/// Url to get the latest app on Github.
const upgradeGithubReleaseUrl = 'https://github.com/realth000/tsdm_client/releases/latest';

/// F-Droid homepage.
const upgradeFDroidHomepageUrl = 'https://f-droid.org/packages/kzs.th000.tsdm_client';

/// Target url to post a reply to thread [tid], forum [fid].
String formatReplyThreadUrl(String fid, String tid) {
  return '$homePage?mod=post&action=reply&fid=$fid&tid=$tid&'
      'extra=&replysubmit=yes&infloat=yes&handlekey=fastpost&inajax=1';
}

/// Prefix in url to get fast reply window to a certain post.
const replyPostWindowSuffix = '&infloat=yes&handlekey=reply&inajax=1&ajaxtarget=fwin_content_reply';

/// Url of images have rendering issue with Impeller.
///
/// The root cause is not clear, maybe corrupt cache content, but it works with skia backend so should not be it.
/// Since these images are now for redirect back purpose, we could handle them specially although we didn't intend to
/// do it before, we have to do it before the next upcoming stable release of Flutter in August, 2025.
const tmpImpellerWorkaroundUrls = [
  'https://$baseHost/static/image/common/back.gif',
  'https://$baseHostAlt/static/image/common/back.gif',
];

/// Target url to post a reply to another post in thread [tid], forum [fid].
String formatReplyPostUrl(String fid, String tid) {
  return '$homePage?mod=post&infloat=yes&action=reply&fid=$fid&'
      'extra=&tid=$tid&replysubmit=yes&inajax=1';
}

/// Target url to get the dialog showing before purchasing a thread.
/// Need thread id [tid] and post id [pid].
String formatPurchaseDialogUrl(String tid, String pid) {
  return '$homePage?mod=misc&action=pay&tid=$tid&pid=$pid&infloat=yes&'
      'handlekey=pay&inajax=1&ajaxtarget=fwin_content_pay';
}

/// Target url to get the chat dialog with user [uid].
///
/// [dateRange] is a query parameter controlling history chat message to
/// display.
/// However we do not know the detail effect so keep it with it's default value
/// 2.
///
/// There are two kinds of dialog:
///
/// * Pure dialog, query parameter contains "infloat=1" from user profile page.
/// * Dialog embedded in page, does not have "infloat=1" query parameter, from
///   hover dialog on user brief profile in thread floor.
///
/// The former kind is wrapped in xml data, pure and have anything we want.
/// So we convert the later kind of url into the former format, which means:
///
/// For all url contains "handlekey=showmesg_$uid", "touid=$uid" and the uid are
/// the same, convert into the format returned by this function.
String formatChatUrl(String uid, {int dateRange = 2}) {
  return '$baseUrl/home.php?mod=spacecp&ac=pm&op=showmsg&'
      'handlekey=showmsg_$uid&touid=$uid&pmid=0&daterange=$dateRange&'
      'infloat=yes&inajax=1&ajaxtarget=fwin_content_showMsgBox';
}

/// Target url to get the chat full history page with user [uid].
///
/// Each page contains 10 messages.
String formatChatFullHistoryUrl(String uid, {int? page}) {
  return '$baseUrl/home.php?mod=space&do=pm&subop=view&touid=$uid'
      '${page != null ? '&page=$page' : ''}#last';
}

/// Target url to get xml data wrapping recent chat history data with user
/// [uid].
///
/// Use [dateRange] if we need longer ago chat history but as said above, we do
/// NOT know the real effect so keep it the default value in most situations.
///
/// The date in this page only contains recent history, without required values
/// to send a new message.
String formatChatRecentHistoryUrl(String uid, {int dateRange = 2}) {
  return '$baseUrl/home.php?mod=spacecp&ac=pm&op=showmsg&'
      'msgonly=1&touid=$uid&pmid=0&inajax=1&daterange=$dateRange';
}

/// Target url to send a message to another user.
///
/// This is mainly used in chat dialog in server, so use this in the same
/// situation.
String formatSendMessageUrl(String touid) {
  return '$baseUrl/home.php?mod=spacecp&ac=pm&op=send&touid=$touid&inajax=1';
}
