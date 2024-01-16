import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/features/thread/repository/thread_repository.dart';
import 'package:tsdm_client/shared/models/post.dart';
import 'package:tsdm_client/shared/models/reply_parameters.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:universal_html/html.dart' as uh;

part 'thread_event.dart';
part 'thread_state.dart';

typedef ThreadEmitter = Emitter<ThreadState>;

class ThreadBloc extends Bloc<ThreadEvent, ThreadState> {
  ThreadBloc({
    required String tid,
    required ThreadRepository threadRepository,
  })  : _threadRepository = threadRepository,
        super(ThreadState(tid: tid)) {
    on<ThreadLoadMoreRequested>(_onThreadLoadMoreRequested);
    on<ThreadRefreshRequested>(_onThreadRefreshRequested);
    on<ThreadJumpPageRequested>(_onThreadJumpPageRequested);
    on<ThreadClosedStateUpdated>(_onThreadUpdateClosedState);
  }

  final ThreadRepository _threadRepository;

  Future<void> _onThreadLoadMoreRequested(
    ThreadLoadMoreRequested event,
    ThreadEmitter emit,
  ) async {
    try {
      final document = await _threadRepository.fetchThread(
        tid: state.tid,
        pageNumber: event.pageNumber,
      );
      emit(await _parseFromDocument(document, event.pageNumber));
    } on HttpRequestFailedException catch (e) {
      debug('failed to load thread page: $e');
      emit(state.copyWith(status: ThreadStatus.failed));
    }
  }

  Future<void> _onThreadRefreshRequested(
    ThreadRefreshRequested event,
    ThreadEmitter emit,
  ) async {
    emit(state.copyWith(status: ThreadStatus.loading));
    try {
      final document = await _threadRepository.fetchThread(tid: state.tid);
      emit(await _parseFromDocument(document, 1));
    } on HttpRequestFailedException catch (e) {
      debug('failed to load thread page: $e');
      emit(state.copyWith(status: ThreadStatus.failed));
    }
  }

  Future<void> _onThreadJumpPageRequested(
    ThreadJumpPageRequested event,
    ThreadEmitter emit,
  ) async {
    emit(state.copyWith(status: ThreadStatus.loading, postList: []));

    try {
      final document = await _threadRepository.fetchThread(
        tid: state.tid,
        pageNumber: event.pageNumber,
      );
      emit(await _parseFromDocument(document, event.pageNumber));
    } on HttpRequestFailedException catch (e) {
      debug('failed to load thread page: fid=${state.tid}, pageNumber=1 : $e');
      emit(state.copyWith(status: ThreadStatus.failed));
    }
  }

  Future<void> _onThreadUpdateClosedState(
    ThreadClosedStateUpdated event,
    ThreadEmitter emit,
  ) async {
    emit(state.copyWith(threadClosed: event.closed));
  }

  Future<ThreadState> _parseFromDocument(
    uh.Document document,
    int pageNumber,
  ) async {
    final threadClosed = document.querySelector('form#fastpostform') == null;
    final threadDataNode = document.querySelector('div#postlist');
    final postList = Post.buildListFromThreadDataNode(threadDataNode);
    String? title;
    // Most threads have thread type node before the title.
    title = document
        .querySelector('div#postlist h1.ts')
        ?.nodes
        .elementAtOrNull(2)
        ?.text
        ?.trim();
    if (title?.isEmpty ?? true) {
      // Some thread
      title = document
          .querySelector('div#postlist h1.ts')
          ?.nodes
          .elementAtOrNull(0)
          ?.text
          ?.trim();
    }

    final currentPage = document.currentPage() ?? pageNumber;
    final totalPages = document.totalPages() ?? pageNumber;

    var needLogin = false;
    var havePermission = true;
    String? permissionDeniedMessage;
    if (postList.isEmpty) {
      // Here both normal thread list and subreddit is empty, check permission.
      final docMessage = document.getElementById('messagetext');
      final docLogin = document.getElementById('messagelogin');
      if (docLogin != null) {
        needLogin = true;
      } else if (docMessage != null) {
        havePermission = false;
        permissionDeniedMessage = docMessage.querySelector('p')?.innerText;
      }
    }

    /// Parse thread type from thread page document.
    /// This should only run once.
    final node = document.querySelector('div#postlist h1.ts > a');
    final threadType =
        node?.firstEndDeepText()?.replaceFirst('[', '').replaceFirst(']', '');

    // Update reply parameters.
    // These reply parameters should be sent to [ReplyBar] later.
    final fid =
        document.querySelector('input[name="srhfid"]')?.attributes['value'];
    final postTime =
        document.querySelector('input[name="posttime"]')?.attributes['value'];
    final formHash =
        document.querySelector('input[name="formhash"]')?.attributes['value'];
    final subject =
        document.querySelector('input[name="subject"]')?.attributes['value'];

    ReplyParameters? replyParameters;
    if (fid == null ||
        postTime == null ||
        formHash == null ||
        subject == null) {
      debug(
          'failed to get reply form hash: fid=$fid postTime=$postTime formHash=$formHash subject=$subject');
    } else {
      replyParameters = ReplyParameters(
        fid: fid,
        tid: state.tid,
        postTime: postTime,
        formHash: formHash,
        subject: subject,
      );
    }

    return ThreadState(
      tid: state.tid,
      replyParameters: replyParameters,
      status: ThreadStatus.success,
      title: title ?? state.title,
      canLoadMore: currentPage < totalPages,
      currentPage: currentPage,
      totalPages: totalPages,
      havePermission: havePermission,
      permissionDeniedMessage: permissionDeniedMessage,
      needLogin: needLogin,
      threadClosed: threadClosed,
      postList: [...state.postList, ...postList],
      threadType: threadType,
    );
  }
}
