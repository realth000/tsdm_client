import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/features/my_thread/models/models.dart';
import 'package:tsdm_client/features/my_thread/repository/my_thread_repository.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:universal_html/html.dart' as uh;

part 'my_thread_bloc.mapper.dart';

part 'my_thread_event.dart';

part 'my_thread_state.dart';

/// Emitter
typedef MyThreadEmitter = Emitter<MyThreadState>;

/// Bloc of my thread page.
final class MyThreadBloc extends Bloc<MyThreadEvent, MyThreadState> with LoggerMixin {
  /// Constructor.
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

  Future<void> _onMyThreadLoadInitialDataRequested(MyThreadLoadInitialDataRequested event, MyThreadEmitter emit) async {
    // Only emit loading state when loading initial data.
    emit(
      state.copyWith(
        status: MyThreadStatus.loading,
        threadList: [],
        replyList: [],
        refreshingThread: true,
        refreshingReply: true,
      ),
    );
    final data = await Future.wait([
      _myThreadRepository.fetchDocument(myThreadThreadUrl).run(),
      _myThreadRepository.fetchDocument(myThreadReplyUrl).run(),
    ]);
    switch ((data[0], data[1])) {
      case (Right(value: final v1), Right(value: final v2)):
        final (threadList, threadNextPageUrl) = _parseThreadList(v1);
        final (replyList, replyNextPageUrl) = _parseReplyList(v2);
        emit(
          state.copyWith(
            status: MyThreadStatus.success,
            threadList: threadList,
            threadPageNumber: 1,
            nextThreadPageUrl: threadNextPageUrl,
            replyList: replyList,
            replyPageNumber: 1,
            nextReplyPageUrl: replyNextPageUrl,
            refreshingThread: false,
            refreshingReply: false,
          ),
        );
      default:
        error('failed to initial my thread page data: ${data[0]}/${data[1]}');
        emit(state.copyWith(status: MyThreadStatus.failed, refreshingThread: false, refreshingReply: false));
    }
  }

  Future<void> _onMyThreadLoadMoreThreadRequested(MyThreadLoadMoreThreadRequested event, MyThreadEmitter emit) async {
    // Do nothing because this part should be avoided by ui.
    if (state.nextThreadPageUrl == null) {
      return;
    }
    await _myThreadRepository
        .fetchDocument(state.nextThreadPageUrl!)
        .match(
          (e) {
            handle(e);
            error('failed to load next page of thread tab: $e');
            emit(state.copyWith(status: MyThreadStatus.failed));
          },
          (v) {
            final (threadList, nextThreadPageUrl) = _parseThreadList(v);
            emit(
              state.copyWith(
                status: MyThreadStatus.success,
                threadList: [...state.threadList, ...threadList],
                threadPageNumber: state.threadPageNumber + 1,
                nextThreadPageUrl: nextThreadPageUrl,
              ),
            );
          },
        )
        .run();
  }

  Future<void> _onMyThreadLoadMoreReplyRequested(MyThreadLoadMoreReplyRequested event, MyThreadEmitter emit) async {
    // Do nothing because this part should be avoided by ui.
    if (state.nextReplyPageUrl == null) {
      return;
    }
    await _myThreadRepository
        .fetchDocument(state.nextReplyPageUrl!)
        .match(
          (e) {
            handle(e);
            error('failed to load next page of reply tab: $e');
            emit(state.copyWith(status: MyThreadStatus.failed));
          },
          (v) {
            final (replyList, nextReplyPageUrl) = _parseReplyList(v);
            emit(
              state.copyWith(
                status: MyThreadStatus.success,
                replyList: [...state.replyList, ...replyList],
                replyPageNumber: state.replyPageNumber + 1,
                nextReplyPageUrl: nextReplyPageUrl,
              ),
            );
          },
        )
        .run();
  }

  Future<void> _onMyThreadRefreshThreadRequested(MyThreadRefreshThreadRequested event, MyThreadEmitter emit) async {
    emit(state.copyWith(refreshingThread: true));
    await _myThreadRepository
        .fetchDocument(myThreadThreadUrl)
        .match(
          (e) {
            handle(e);
            error('failed to load next page of thread tab: $e');
            emit(state.copyWith(status: MyThreadStatus.failed, refreshingThread: false));
          },
          (v) {
            final (threadList, nextThreadPageUrl) = _parseThreadList(v);
            emit(
              state.copyWith(
                status: MyThreadStatus.success,
                threadList: threadList,
                threadPageNumber: 1,
                nextThreadPageUrl: nextThreadPageUrl,
                refreshingThread: false,
              ),
            );
          },
        )
        .run();
  }

  Future<void> _onMyThreadRefreshReplyRequested(MyThreadRefreshReplyRequested event, MyThreadEmitter emit) async {
    emit(state.copyWith(refreshingReply: true));
    await _myThreadRepository
        .fetchDocument(myThreadReplyUrl)
        .match(
          (e) {
            handle(e);
            error('failed to load next page of reply tab: $e');
            emit(state.copyWith(status: MyThreadStatus.failed, refreshingReply: false));
          },
          (v) {
            final (replyList, nextReplyPageUrl) = _parseReplyList(v);
            emit(
              state.copyWith(
                status: MyThreadStatus.success,
                replyList: replyList,
                replyPageNumber: 1,
                nextReplyPageUrl: nextReplyPageUrl,
                refreshingReply: false,
              ),
            );
          },
        )
        .run();
  }

  (List<MyThread>, String? nextPageurl) _parseThreadList(uh.Document document) {
    final data =
        document
            .querySelectorAll('div.bm.bw0 > div.tl > form > table > tbody > tr')
            .skip(1)
            .map(MyThread.fromTr)
            .whereType<MyThread>()
            .toList();

    final nextPageUrl = document.querySelector('div.pgs.cl.mtm > div.pg > a.nxt')?.firstHref()?.prependHost();

    return (data, nextPageUrl);
  }

  (List<MyThread>, String? nextPageUrl) _parseReplyList(uh.Document document) {
    final data =
        document
            .querySelectorAll('div.bm.bw0 > div.tl > form > table > tbody > tr.bw0_all')
            .map(MyThread.fromTr)
            .whereType<MyThread>()
            .toList();
    final nextPageUrl = document.querySelector('div.pgs.cl.mtm > div.pg > a.nxt')?.firstHref()?.prependHost();
    return (data, nextPageUrl);
  }
}
