import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/features/thread/repository/thread_repository.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:universal_html/html.dart' as uh;

part '../../../generated/features/thread/bloc/thread_bloc.mapper.dart';
part 'thread_event.dart';
part 'thread_state.dart';

/// Emitter.
typedef ThreadEmitter = Emitter<ThreadState>;

/// Bloc the thread page.
class ThreadBloc extends Bloc<ThreadEvent, ThreadState> {
  /// Constructor.
  ThreadBloc({
    required String? tid,
    required String? pid,
    required ThreadRepository threadRepository,
  })  : _threadRepository = threadRepository,
        super(ThreadState(tid: tid, pid: pid)) {
    on<ThreadLoadMoreRequested>(_onThreadLoadMoreRequested);
    on<ThreadRefreshRequested>(_onThreadRefreshRequested);
    on<ThreadJumpPageRequested>(_onThreadJumpPageRequested);
    on<ThreadClosedStateUpdated>(_onThreadUpdateClosedState);
    on<ThreadOnlyViewAuthorRequested>(_onThreadOnlyViewAuthorRequested);
    on<ThreadViewAllAuthorsRequested>(_onThreadViewAllAuthorsRequested);
    on<ThreadChangeViewOrderRequested>(_onThreadChangeViewOrderRequested);
  }

  final ThreadRepository _threadRepository;

  Future<void> _onThreadLoadMoreRequested(
    ThreadLoadMoreRequested event,
    ThreadEmitter emit,
  ) async {
    try {
      final document = await _threadRepository.fetchThread(
        tid: state.tid,
        pid: state.pid,
        pageNumber: event.pageNumber,
        onlyVisibleUid: state.onlyVisibleUid,
        reverseOrder: state.reverseOrder,
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
    emit(state.copyWith(status: ThreadStatus.loading, postList: []));
    try {
      final document = await _threadRepository.fetchThread(
        tid: state.tid,
        pid: state.pid,
        onlyVisibleUid: state.onlyVisibleUid,
        reverseOrder: state.reverseOrder,
      );
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
        pid: state.pid,
        pageNumber: event.pageNumber,
        onlyVisibleUid: state.onlyVisibleUid,
        reverseOrder: state.reverseOrder,
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

  Future<void> _onThreadOnlyViewAuthorRequested(
    ThreadOnlyViewAuthorRequested event,
    ThreadEmitter emit,
  ) async {
    emit(state.copyWith(status: ThreadStatus.loading, postList: []));

    try {
      final document = await _threadRepository.fetchThread(
        tid: state.tid,
        pid: state.pid,
        pageNumber: state.currentPage,
        onlyVisibleUid: event.uid,
        reverseOrder: state.reverseOrder,
      );
      // Use "1" as current page number to prevent page number overflow.
      final s = await _parseFromDocument(document, 1);
      emit(s.copyWith(onlyVisibleUid: event.uid));
    } on HttpRequestFailedException catch (e) {
      debug('failed to load thread page: fid=${state.tid}, pageNumber=1 : $e');
      emit(
        state.copyWith(
          status: ThreadStatus.failed,
          onlyVisibleUid: event.uid,
        ),
      );
    }
  }

  Future<void> _onThreadViewAllAuthorsRequested(
    ThreadViewAllAuthorsRequested event,
    ThreadEmitter emit,
  ) async {
    emit(state.copyWith(status: ThreadStatus.loading, postList: []));

    try {
      // Switching from "only view specified author" to "view all authors"
      // will have more posts and pages so there is no page number overflow
      // risk.
      final document = await _threadRepository.fetchThread(
        tid: state.tid,
        pid: state.pid,
        pageNumber: state.currentPage,
        reverseOrder: state.reverseOrder,
      );
      // Use "1" as current page number to prevent page number overflow.
      final s = await _parseFromDocument(
        document,
        state.currentPage,
        clearOnlyVisibleUid: true,
      );
      emit(s.copyWith(onlyVisibleUid: state.onlyVisibleUid));
    } on HttpRequestFailedException catch (e) {
      debug('failed to load thread page: fid=${state.tid}, pageNumber=1 : $e');
      emit(state.copyWith(status: ThreadStatus.failed));
    }
  }

  Future<void> _onThreadChangeViewOrderRequested(
    ThreadChangeViewOrderRequested event,
    ThreadEmitter emit,
  ) async {
    emit(
      state.copyWith(
        status: ThreadStatus.loading,
        postList: [],
        reverseOrder: !state.reverseOrder,
      ),
    );
    try {
      final document = await _threadRepository.fetchThread(
        tid: state.tid,
        pid: state.pid,
        pageNumber: state.currentPage,
        onlyVisibleUid: state.onlyVisibleUid,
        reverseOrder: state.reverseOrder,
      );
      final s = await _parseFromDocument(
        document,
        state.currentPage,
      );
      emit(s.copyWith(reverseOrder: state.reverseOrder));
    } on HttpRequestFailedException catch (e) {
      debug('failed to load thread page: fid=${state.tid}, pageNumber=1 : $e');
      emit(
        state.copyWith(
          status: ThreadStatus.failed,
          reverseOrder: state.reverseOrder,
        ),
      );
    }
  }

  Future<ThreadState> _parseFromDocument(
    uh.Document document,
    int pageNumber, {
    bool? clearOnlyVisibleUid,
  }) async {
    // Reset the thread id from document.
    final threadID = document.querySelector('head > link')?.attributes['href'];

    final threadClosed = document.querySelector('form#fastpostform') == null;
    final threadDataNode = document.querySelector('div#postlist');
    final postList = Post.buildListFromThreadDataNode(threadDataNode);
    String? title;
    // Most threads have thread type node before the title.
    title =
        // Thread belongs to not types.
        document
                .querySelector('div#postlist h1.ts > a:nth-child(1)')
                ?.nextNode
                ?.text
                ?.trim() ??
            // Thread belongs to some type.
            document
                .querySelector('div#postlist h1.ts > a:nth-child(1)')
                ?.innerText
                .trim();
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
    uh.Element? permissionDeniedMessage;
    if (postList.isEmpty) {
      // Here both normal thread list and subreddit is empty, check permission.
      final docMessage = document.getElementById('messagetext');
      final docLogin = document.getElementById('messagelogin');
      if (docLogin != null) {
        needLogin = true;
      } else if (docMessage != null) {
        havePermission = false;
        permissionDeniedMessage = docMessage.querySelector('p');
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
        'failed to get reply form hash: fid=$fid postTime=$postTime '
        'formHash=$formHash subject=$subject',
      );
    } else {
      replyParameters = ReplyParameters(
        fid: fid,
        tid: threadID!,
        postTime: postTime,
        formHash: formHash,
        subject: subject,
      );
    }

    return ThreadState(
      tid: threadID,
      pid: state.pid,
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
      onlyVisibleUid:
          (clearOnlyVisibleUid ?? false) ? null : state.onlyVisibleUid,
      reverseOrder: state.reverseOrder,
    );
  }
}
