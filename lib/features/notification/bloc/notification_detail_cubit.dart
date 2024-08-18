import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/features/notification/repository/notification_repository.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:universal_html/html.dart' as uh;

part 'notification_detail_cubit.mapper.dart';
part 'notification_detail_state.dart';

/// Cubit of the notification detail page.
class NotificationDetailCubit extends Cubit<NotificationDetailState>
    with LoggerMixin {
  /// Constructor.
  NotificationDetailCubit({
    required NotificationRepository notificationRepository,
  })  : _notificationRepository = notificationRepository,
        super(const NotificationDetailState());

  static final _pidRe = RegExp(r'pid=(?<pid>\d+)');
  static final _tidRe = RegExp(r'ptid=(?<ptid>\d+)');

  final NotificationRepository _notificationRepository;

  /// Fetch notification detail from [url].
  ///
  /// Usually the [url] is a thread page and the logic below is trying to get
  /// the corresponding post in thread.
  Future<void> fetchDetail(String url) async {
    emit(state.copyWith(status: NotificationDetailStatus.loading));
    try {
      final (document, page) = await _notificationRepository.fetchDocument(url);

      final threadClosed = document.querySelector('form#fastpostform') == null;

      final match = _pidRe.firstMatch(url);
      final pid = match?.namedGroup('pid');
      if (pid == null) {
        error('pid not found in url: $url');
        emit(state.copyWith(status: NotificationDetailStatus.failed));
        return;
      }

      final postNode = document.querySelector('div#post_$pid');
      if (postNode == null) {
        error('failed to build reply page: post node not found for pid $pid');
        emit(state.copyWith(status: NotificationDetailStatus.failed));
        return;
      }
      final postData = Post.fromPostNode(postNode, document.currentPage() ?? 1);

      // Parse thread id.
      final tidMatch = _tidRe.firstMatch(url);
      final tid = tidMatch?.namedGroup('ptid');
      if (tid == null) {
        error('failed to build reply page: tid not found');
        emit(state.copyWith(status: NotificationDetailStatus.failed));
        return;
      }
      final replyParameters = _parseParameters(document, tid);
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          status: NotificationDetailStatus.success,
          post: postData,
          replyParameters: replyParameters,
          tid: tid,
          pid: pid,
          page: page,
          threadClosed: threadClosed,
        ),
      );
    } on HttpRequestFailedException catch (e) {
      error('failed to fetch notification detail: $e');
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
        'failed to get reply form hash: fid=$fid postTime=$postTime '
        'formHash=$formHash subject=$subject',
      );
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
