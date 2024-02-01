import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/features/latest_thread/models/latest_thread.dart';
import 'package:tsdm_client/features/latest_thread/repository/latest_thread_repository.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:universal_html/html.dart' as uh;

part 'latest_thread_event.dart';
part 'latest_thread_state.dart';

/// Emitter
typedef LatestThreadEmitter = Emitter<LatestThreadState>;

/// Bloc the the latest thread feature.
final class LatestThreadBloc
    extends Bloc<LatestThreadEvent, LatestThreadState> {
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

    try {
      final document =
          await _latestThreadRepository.fetchDocument(state.nextPageUrl!);
      final (threadList, nextPageUrl) = _parseThreadList(document);
      emit(
        state.copyWith(
          status: LatestThreadStatus.success,
          threadList: [...state.threadList, ...?threadList],
          pageNumber: state.pageNumber + 1,
          nextPageUrl: nextPageUrl,
        ),
      );
    } on HttpRequestFailedException catch (e) {
      debug('failed to load latest thread next page: $e');
      emit(state.copyWith(status: LatestThreadStatus.failed));
    }
  }

  Future<void> _onLatestThreadRefreshRequested(
    LatestThreadRefreshRequested event,
    LatestThreadEmitter emit,
  ) async {
    emit(state.copyWith(status: LatestThreadStatus.loading, threadList: []));
    try {
      final document = await _latestThreadRepository.fetchDocument(event.url);
      final (threadList, nextPageUrl) = _parseThreadList(document);
      emit(
        state.copyWith(
          status: LatestThreadStatus.success,
          threadList: threadList,
          pageNumber: 1,
          nextPageUrl: nextPageUrl,
        ),
      );
    } on HttpRequestFailedException catch (e) {
      debug('failed to load latest thread page: $e');
      emit(state.copyWith(status: LatestThreadStatus.failed));
    }
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
