import 'package:dio/dio.dart';

const baseUrl = 'https://www.tsdm39.com';
const homePage = '$baseUrl/forum.php';
const uidProfilePage = '$baseUrl/home.php?mod=space&uid=';
const noAvatarUrl = '$baseUrl/uc_server/images/noavatar_middle.gif';
const noticeUrl = '$baseUrl/home.php?mod=space&do=notice';
const readNoticeUrl = '$baseUrl/home.php?mod=space&do=notice&isread=1';
const myThreadThreadUrl =
    '$baseUrl/home.php?mod=space&do=thread&view=me&type=thread';
const myThreadReplyUrl =
    '$baseUrl/home.php?mod=space&do=thread&view=me&type=reply';

/// Target url to post a reply to thread [tid], forum [fid].
String formatReplyThreadUrl(String fid, String tid) {
  return '$homePage?mod=post&action=reply&fid=$fid&tid=$tid&extra=&replysubmit=yes&infloat=yes&handlekey=fastpost&inajax=1';
}

/// Prefix in url to get fast reply window to a certain post.
const replyPostWindowSuffix =
    '&infloat=yes&handlekey=reply&inajax=1&ajaxtarget=fwin_content_reply';

/// Target url to post a reply to another post in thread [tid], forum [fid].
String formatReplyPostUrl(String fid, String tid) {
  return '$homePage?mod=post&infloat=yes&action=reply&fid=$fid&extra=&tid=$tid&replysubmit=yes&inajax=1';
}

/// Target url to get the dialog showing before purchasing a thread.
/// Need thread id [tid] and post id [pid].
String formatPurchaseDialogUrl(String tid, String pid) {
  return '$homePage?mod=misc&action=pay&tid=$tid&pid=$pid&infloat=yes&handlekey=pay&inajax=1&ajaxtarget=fwin_content_pay';
}

final emptyResponse = Response(requestOptions: RequestOptions(), data: '');
