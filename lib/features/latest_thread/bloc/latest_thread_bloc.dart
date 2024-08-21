import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/features/latest_thread/models/latest_thread.dart';
import 'package:tsdm_client/features/latest_thread/repository/latest_thread_repository.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:universal_html/html.dart' as uh;

part 'latest_thread_bloc.mapper.dart';
part 'latest_thread_event.dart';
part 'latest_thread_state.dart';

/// Emitter
typedef LatestThreadEmitter = Emitter<LatestThreadState>;

/// Bloc the the latest thread feature.
final class LatestThreadBloc extends Bloc<LatestThreadEvent, LatestThreadState>
    with LoggerMixin {
  /// Constructor.
  LatestThreadBloc({required LatestThreadRepository latestThreadRepository})
      : _latestThreadRepository = latestThreadRepository,
        super(const LatestThreadState()) {
    on<LatestThreadLoadMoreRequested>(_onLatestThreadLoadMoreRequested);
    on<LatestThreadRefreshRequested>(_onLatestThreadRefreshRequested);
  }

  final LatestThreadRepository _latestThreadRepository;

  Future<void> _onLatestThreadLoadMoreRequested(
    LatestThreadLoadMoreRequested event,
    LatestThreadEmitter emit,
  ) async {
    // Do nothing, UI should check this.
    if (state.nextPageUrl == null) {
      return;
    }
    await _latestThreadRepository.fetchDocument(state.nextPageUrl!).match((e) {
      handle(e);
      error('failed to load latest thread next page: $e');
      emit(state.copyWith(status: LatestThreadStatus.failed));
    }, (v) {
      final (threadList, nextPageUrl) = _parseThreadList(v);
      emit(
        state.copyWith(
          status: LatestThreadStatus.success,
          threadList: [...state.threadList, ...?threadList],
          pageNumber: state.pageNumber + 1,
          nextPageUrl: nextPageUrl,
        ),
      );
    }).run();
  }

  Future<void> _onLatestThreadRefreshRequested(
    LatestThreadRefreshRequested event,
    LatestThreadEmitter emit,
  ) async {
    emit(state.copyWith(status: LatestThreadStatus.loading, threadList: []));
    await _latestThreadRepository.fetchDocument(event.url).match((e) {
      handle(e);
      error('failed to load latest thread page: $e');
      emit(state.copyWith(status: LatestThreadStatus.failed));
    }, (v) {
      final (threadList, nextPageUrl) = _parseThreadList(v);
      emit(
        state.copyWith(
          status: LatestThreadStatus.success,
          threadList: threadList,
          pageNumber: 1,
          nextPageUrl: nextPageUrl,
        ),
      );
    }).run();
  }

  (List<LatestThread>?, String? nextPageUrl) _parseThreadList(
    uh.Document document,
  ) {
    final data = document
        .querySelector('div#threadlist > ul')
        ?.querySelectorAll('li')
        .map(LatestThread.fromLi)
        .whereType<LatestThread>()
        .toList();
    final nextPageUrl = document
        .querySelector('div#ct_shell div.pg > a.nxt')
        ?.firstHref()
        ?.prependHost();
    return (data ?? const [], nextPageUrl);
  }
}
