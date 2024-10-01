import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:tsdm_client/features/thread_visit_history/repository/thread_visit_history_repository.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/utils/logger.dart';

part 'thread_visit_history_bloc.mapper.dart';
part 'thread_visit_history_event.dart';
part 'thread_visit_history_state.dart';

typedef _Emit = Emitter<ThreadVisitHistoryState>;

/// Bloc of thread visit history feature.
final class ThreadVisitHistoryBloc
    extends Bloc<ThreadVisitHistoryEvent, ThreadVisitHistoryState>
    with LoggerMixin {
  /// Constructor.
  ThreadVisitHistoryBloc(this._repo) : super(const ThreadVisitHistoryState()) {
    on<ThreadVisitHistoryEvent>(
      (event, emit) async => switch (event) {
        ThreadVisitHistoryFetchAllRequested() => _onFetchAllRequested(emit),
        // TODO: Handle this case.
        ThreadVisitHistoryFetchByUserRequested() => throw UnimplementedError(),
        // TODO: Handle this case.
        ThreadVisitHistoryUpdateRequested(:final history) =>
          _onUpdateRequested(history, emit),
        // TODO: Handle this case.
        ThreadVisitHistoryClearRequested() => throw UnimplementedError(),
      },
    );
  }

  final ThreadVisitHistoryRepo _repo;

  Future<void> _onFetchAllRequested(_Emit emit) async {
    emit(state.copyWith(status: ThreadVisitHistoryStatus.loadingData));
    switch (await _repo.fetchAllHistory().run()) {
      case Left():
        debug('fetch all failed');
        emit(state.copyWith(status: ThreadVisitHistoryStatus.failure));
      case Right(:final value):
        debug('fetch all succeeded, date count is ${value.length}');
        emit(
          state.copyWith(
            status: ThreadVisitHistoryStatus.success,
            history: value,
          ),
        );
    }
  }

  Future<void> _onUpdateRequested(
    ThreadVisitHistoryModel model,
    _Emit emit,
  ) async {
    emit(state.copyWith(status: ThreadVisitHistoryStatus.savingData));
    // TODO: Define the error here and handle it.
    await _repo.saveHistory(model).run();
    emit(state.copyWith(status: ThreadVisitHistoryStatus.success));
  }
}
