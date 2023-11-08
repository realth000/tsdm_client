const baseUrl = 'https://www.tsdm39.com';
const homePage = '$baseUrl/forum.php';
const uidProfilePage = '$baseUrl/home.php?mod=space&uid=';
const noAvatarUrl = '$baseUrl/uc_server/images/noavatar_middle.gif';

String formatReplyThreadUrl(String fid, String tid) {
  return '$homePage?mod=post&action=reply&fid=$fid&tid=$tid&extra=&replysubmit=yes&infloat=yes&handlekey=fastpost&inajax=1';
}
