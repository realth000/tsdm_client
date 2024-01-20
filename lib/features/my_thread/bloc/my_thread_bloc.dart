import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/features/my_thread/models/my_thread.dart';
import 'package:tsdm_client/features/my_thread/repository/my_thread_repository.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:universal_html/html.dart' as uh;

part 'my_thread_event.dart';
part 'my_thread_state.dart';

typedef MyThreadEmitter = Emitter<MyThreadState>;

final class MyThreadBloc extends Bloc<MyThreadEvent, MyThreadState> {
  MyThreadBloc({required MyThreadRepository myThreadRepository})
      : _myThreadRepository = myThreadRepository,
        super(const MyThreadState()) {
    on<MyThreadLoadMoreThreadRequested>(_onMyThreadLoadMoreThreadRequested);
    on<MyThreadLoadMoreReplyRequested>(_onMyThreadLoadMoreReplyRequested);
    on<MyThreadRefreshThreadRequested>(_onMyThreadRefreshThreadRequested);
    on<MyThreadRefreshReplyRequested>(_onMyThreadRefreshReplyRequested);
    on<MyThreadLoadInitialDataRequested>(_onMyThreadLoadInitialDataRequested);
  }

  final MyThreadRepository _myThreadRepository;

  Future<void> _onMyThreadLoadInitialDataRequested(
    MyThreadLoadInitialDataRequested event,
    MyThreadEmitter emit,
  ) async {
    // Only emit loading state when loading initial data.
    emit(state.copyWith(
      status: MyThreadStatus.loading,
      threadList: [],
      replyList: [],
      refreshingThread: true,
      refreshingReply: true,
    ));
    // FIXME: If only one tab threw exception.
    try {
      final data = await Future.wait([
        _myThreadRepository.fetchDocument(myThreadThreadUrl),
        _myThreadRepository.fetchDocument(myThreadReplyUrl),
      ]);
      final d1 = data[0];
      final d2 = data[1];
      final (threadList, threadNextPageUrl) = _parseThreadList(d1);
      final (replyList, replyNextPageUrl) = _parseReplyList(d2);
      emit(state.copyWith(
        status: MyThreadStatus.success,
        threadList: threadList,
        threadPageNumber: 1,
        nextThreadPageUrl: threadNextPageUrl,
        replyList: replyList,
        replyPageNumber: 1,
        nextReplyPageUrl: replyNextPageUrl,
        refreshingThread: false,
        refreshingReply: false,
      ));
    } on HttpRequestFailedException catch (e) {
      debug('failed to initial my thread page data: $e');
      emit(state.copyWith(
        status: MyThreadStatus.failed,
        refreshingThread: false,
        refreshingReply: false,
      ));
    }
  }

  Future<void> _onMyThreadLoadMoreThreadRequested(
    MyThreadLoadMoreThreadRequested event,
    MyThreadEmitter emit,
  ) async {
    // Do nothing because this part should be avoided by ui.
    if (state.nextThreadPageUrl == null) {
      return;
    }
    try {
      final document =
          await _myThreadRepository.fetchDocument(state.nextThreadPageUrl!);
      final (threadList, nextThreadPageUrl) = _parseThreadList(document);
      emit(state.copyWith(
        status: MyThreadStatus.success,
        threadList: [...state.threadList, ...threadList],
        threadPageNumber: state.threadPageNumber + 1,
        nextThreadPageUrl: nextThreadPageUrl,
      ));
    } on HttpRequestFailedException catch (e) {
      debug('failed to load next page of thread tab: $e');
      emit(state.copyWith(
        status: MyThreadStatus.failed,
      ));
    }
  }

  Future<void> _onMyThreadLoadMoreReplyRequested(
    MyThreadLoadMoreReplyRequested event,
    MyThreadEmitter emit,
  ) async {
    // Do nothing because this part should be avoided by ui.
    if (state.nextReplyPageUrl == null) {
      return;
    }
    try {
      final document =
          await _myThreadRepository.fetchDocument(state.nextReplyPageUrl!);
      final (replyList, nextReplyPageUrl) = _parseReplyList(document);
      emit(state.copyWith(
        status: MyThreadStatus.success,
        replyList: [...state.replyList, ...replyList],
        replyPageNumber: state.replyPageNumber + 1,
        nextReplyPageUrl: nextReplyPageUrl,
      ));
    } on HttpRequestFailedException catch (e) {
      debug('failed to load next page of reply tab: $e');
      emit(state.copyWith(
        status: MyThreadStatus.failed,
      ));
    }
  }

  Future<void> _onMyThreadRefreshThreadRequested(
    MyThreadRefreshThreadRequested event,
    MyThreadEmitter emit,
  ) async {
    emit(state.copyWith(refreshingThread: true));
    try {
      final document =
          await _myThreadRepository.fetchDocument(myThreadThreadUrl);
      final (threadList, nextThreadPageUrl) = _parseThreadList(document);
      emit(state.copyWith(
        status: MyThreadStatus.success,
        threadList: threadList,
        threadPageNumber: 1,
        nextThreadPageUrl: nextThreadPageUrl,
        refreshingThread: false,
      ));
    } on HttpRequestFailedException catch (e) {
      debug('failed to load next page of thread tab: $e');
      emit(state.copyWith(
        status: MyThreadStatus.failed,
        refreshingThread: false,
      ));
    }
  }

  Future<void> _onMyThreadRefreshReplyRequested(
    MyThreadRefreshReplyRequested event,
    MyThreadEmitter emit,
  ) async {
    emit(state.copyWith(refreshingReply: true));
    try {
      final document =
          await _myThreadRepository.fetchDocument(myThreadReplyUrl);
      final (replyList, nextReplyPageUrl) = _parseReplyList(document);
      emit(state.copyWith(
        status: MyThreadStatus.success,
        replyList: replyList,
        replyPageNumber: 1,
        nextReplyPageUrl: nextReplyPageUrl,
        refreshingReply: false,
      ));
    } on HttpRequestFailedException catch (e) {
      debug('failed to load next page of reply tab: $e');
      emit(state.copyWith(
        status: MyThreadStatus.failed,
        refreshingReply: false,
      ));
    }
  }

  (List<MyThread>, String? nextPageurl) _parseThreadList(uh.Document document) {
    final data = document
        .querySelectorAll('div.bm.bw0 > div.tl > form > table > tbody > tr')
        .skip(1)
        .map(MyThread.fromTr)
        .whereType<MyThread>()
        .toList();

    final nextPageUrl = document
        .querySelector('div.pgs.cl.mtm > div.pg > a.nxt')
        ?.firstHref()
        ?.prependHost();

    return (data, nextPageUrl);
  }

  (List<MyThread>, String? nextPageUrl) _parseReplyList(uh.Document document) {
    final data = document
        .querySelectorAll(
            'div.bm.bw0 > div.tl > form > table > tbody > tr.bw0_all')
        .skip(1)
        .map(MyThread.fromTr)
        .whereType<MyThread>()
        .toList();
    final nextPageUrl = document
        .querySelector('div.pgs.cl.mtm > div.pg > a.nxt')
        ?.firstHref()
        ?.prependHost();
    return (data, nextPageUrl);
  }
}
