/// Default cookie expiration time in seconds.
///
/// This is kept the same with server behavior.
const defaultCookieTime = 2592000;

/// Server site base url.
const baseUrl = 'https://www.tsdm39.com';

/// Homepage of tsdm.
const homePage = '$baseUrl/forum.php';

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
const broadcastMessageUrl =
    '$baseUrl/home.php?mod=space&do=pm&filter=announcepm';

/// Page contains all thread published by current logged user.
const myThreadThreadUrl =
    '$baseUrl/home.php?mod=space&do=thread&view=me&type=thread';

/// Page contains all posts (as replies in threads) published by current logged
/// user.
const myThreadReplyUrl =
    '$baseUrl/home.php?mod=space&do=thread&view=me&type=reply';

/// Page contains credential information of current user.
///
/// This page is also used for checking logged user info because it has the
/// complete information of current user:
/// * Username.
/// * Uid.
/// * Email address.
const modifyUserCredentialUrl =
    '$baseUrl/home.php?mod=spacecp&ac=profile&op=password';

/// Use [modifyUserCredentialUrl] to check user status.
///
/// This page contains full user info:
/// * Username
/// * UID
/// * User email
const checkAuthenticationStateUrl = modifyUserCredentialUrl;

/// Url to get the latest app on Github.
const upgradeGithubReleaseUrl =
    'https://github.com/realth000/tsdm_client/releases/latest';

/// Target url to post a reply to thread [tid], forum [fid].
String formatReplyThreadUrl(String fid, String tid) {
  return '$homePage?mod=post&action=reply&fid=$fid&tid=$tid&'
      'extra=&replysubmit=yes&infloat=yes&handlekey=fastpost&inajax=1';
}

/// Prefix in url to get fast reply window to a certain post.
const replyPostWindowSuffix =
    '&infloat=yes&handlekey=reply&inajax=1&ajaxtarget=fwin_content_reply';

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
