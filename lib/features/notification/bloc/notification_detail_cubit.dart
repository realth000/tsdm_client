import 'package:bloc/bloc.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/features/notification/bloc/notification_detail_state.dart';
import 'package:tsdm_client/features/notification/repository/notification_repository.dart';
import 'package:tsdm_client/shared/models/post.dart';
import 'package:tsdm_client/shared/models/reply_parameters.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:universal_html/html.dart' as uh;

class NotificationDetailCubit extends Cubit<NotificationDetailState> {
  NotificationDetailCubit({
    required NotificationRepository notificationRepository,
  })  : _notificationRepository = notificationRepository,
        super(const NotificationDetailState());

  static final _pidRe = RegExp(r'pid=(?<pid>\d+)');
  static final _tidRe = RegExp(r'ptid=(?<ptid>\d+)');

  final NotificationRepository _notificationRepository;

  Future<void> fetchDetail(String url) async {
    emit(state.copyWith(status: NotificationDetailStatus.loading));
    try {
      final (document, page) =
          await _notificationRepository.fetchNoticeDetail(url);

      final threadClosed = document.querySelector('form#fastpostform') == null;

      final match = _pidRe.firstMatch(url);
      final pid = match?.namedGroup('pid');
      if (pid == null) {
        debug('pid not found in url: $url');
        emit(state.copyWith(status: NotificationDetailStatus.failed));
        return;
      }

      final postNode = document.querySelector('div#post_$pid');
      if (postNode == null) {
        debug('failed to build reply page: post node not found for pid $pid');
        emit(state.copyWith(status: NotificationDetailStatus.failed));
        return;
      }
      final postData = Post.fromPostNode(postNode);

      // Parse thread id.
      final tidMatch = _tidRe.firstMatch(url);
      final tid = tidMatch?.namedGroup('ptid');
      if (tid == null) {
        debug('failed to build reply page: tid not found');
        emit(state.copyWith(status: NotificationDetailStatus.failed));
        return;
      }
      final replyParameters = _parseParameters(document, tid);
      emit(state.copyWith(
        status: NotificationDetailStatus.success,
        post: postData,
        replyParameters: replyParameters,
        tid: tid,
        pid: pid,
        page: page,
        threadClosed: threadClosed,
      ));
    } on HttpRequestFailedException catch (e) {
      debug('failed to fetch notification detail: $e');
      emit(state.copyWith(status: NotificationDetailStatus.failed));
    }
  }

  ReplyParameters? _parseParameters(uh.Document document, String tid) {
    final fid =
        document.querySelector('input[name="srhfid"]')?.attributes['value'];
    final postTime =
        document.querySelector('input[name="posttime"]')?.attributes['value'];
    final formHash =
        document.querySelector('input[name="formhash"]')?.attributes['value'];
    final subject =
        document.querySelector('input[name="subject"]')?.attributes['value'];

    if (fid == null ||
        postTime == null ||
        formHash == null ||
        subject == null) {
      debug(
          'failed to get reply form hash: fid=$fid postTime=$postTime formHash=$formHash subject=$subject');
      return null;
    }
    return ReplyParameters(
      fid: fid,
      tid: tid,
      postTime: postTime,
      formHash: formHash,
      subject: subject,
    );
  }
}
