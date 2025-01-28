import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/features/thread/repository/thread_repository.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:universal_html/html.dart' as uh;

part 'thread_bloc.mapper.dart';
part 'thread_bloc_v1.dart';
part 'thread_bloc_v2.dart';
part 'thread_event.dart';
part 'thread_state.dart';

/// Emitter.
typedef ThreadEmitter = Emitter<ThreadState>;

/// Basic interfaces on thread bloc.
///
/// Ideally the basic thread bloc shall be implemented, not extended, to ensure
/// all derived class have their own implementation on all needed methods. But
/// since the class extends `Bloc` class, all methods in `Bloc` are required to
/// override for every derived class when derive through `implements`. It is not
/// intended so use the `extends` and throws [UnimplementedError] in the base
/// implementation. This is similar in all blocs with migration.
abstract interface class ThreadBloc extends Bloc<ThreadEvent, ThreadState>
    with LoggerMixin {
  /// Constructor.
  ThreadBloc({
    required String? tid,
    required String? pid,
    required String? onlyVisibleUid,
    required bool? reverseOrder,
    required int? exactOrder,
    required ThreadRepository threadRepository,
  })  : _threadRepository = threadRepository,
        super(
          ThreadState(
            tid: tid,
            pid: pid,
            onlyVisibleUid: onlyVisibleUid,
            reverseOrder: reverseOrder,
            exactOrder: exactOrder,
          ),
        ) {
    on<ThreadLoadMoreRequested>(_onThreadLoadMoreRequested);
    on<ThreadRefreshRequested>(_onThreadRefreshRequested);
    on<ThreadJumpPageRequested>(_onThreadJumpPageRequested);
    on<ThreadClosedStateUpdated>(_onThreadUpdateClosedState);
    on<ThreadOnlyViewAuthorRequested>(_onThreadOnlyViewAuthorRequested);
    on<ThreadViewAllAuthorsRequested>(_onThreadViewAllAuthorsRequested);
    on<ThreadChangeViewOrderRequested>(_onThreadChangeViewOrderRequested);
  }

  final ThreadRepository _threadRepository;

  /// Load the next page.
  ///
  /// Page number to fetch is store in [event].
  Future<void> _onThreadLoadMoreRequested(
    ThreadLoadMoreRequested event,
    ThreadEmitter emit,
  ) async {
    throw UnimplementedError();
  }

  /// Refresh the thread page.
  ///
  /// Reload and go back to the first page.
  /// Thread order and author visibility are kept.
  Future<void> _onThreadRefreshRequested(
    ThreadRefreshRequested event,
    ThreadEmitter emit,
  ) async {
    throw UnimplementedError();
  }

  /// Jump to a specified page.
  ///
  /// Remove all loaded pages and only keep the jumped one.
  Future<void> _onThreadJumpPageRequested(
    ThreadJumpPageRequested event,
    ThreadEmitter emit,
  ) async {
    throw UnimplementedError();
  }

  /// Update the thread closed state.
  ///
  /// Sometimes we realise the correct thread state later than the moment we
  /// loaded it. Use this event to check if a thread is closed or not.
  Future<void> _onThreadUpdateClosedState(
    ThreadClosedStateUpdated event,
    ThreadEmitter emit,
  ) async {
    throw UnimplementedError();
  }

  /// Change the "only view specified author" behavior.
  ///
  /// Toggle on.
  Future<void> _onThreadOnlyViewAuthorRequested(
    ThreadOnlyViewAuthorRequested event,
    ThreadEmitter emit,
  ) async {
    throw UnimplementedError();
  }

  /// Change the "only view specified author" behavior.
  ///
  /// Toggle off.
  Future<void> _onThreadViewAllAuthorsRequested(
    ThreadViewAllAuthorsRequested event,
    ThreadEmitter emit,
  ) async {
    throw UnimplementedError();
  }

  /// Change the view order of request.
  Future<void> _onThreadChangeViewOrderRequested(
    ThreadChangeViewOrderRequested event,
    ThreadEmitter emit,
  ) async {
    throw UnimplementedError();
  }
}
