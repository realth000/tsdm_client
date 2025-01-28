import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/features/thread/v2/models/models.dart';
import 'package:tsdm_client/features/thread/v2/repository/thread_repository_v2.dart';
import 'package:tsdm_client/shared/models/models.dart';

part 'thread_bloc_v2.mapper.dart';
part 'thread_event_v2.dart';
part 'thread_state_v2.dart';

typedef _Emit = Emitter<ThreadStateV2>;

/// V2 bloc of thread feature.
final class ThreadBlocV2 extends Bloc<ThreadV2Event, ThreadStateV2> {
  /// Constructor.
  ThreadBlocV2(
    this._repo, {
    required String threadId,
    int page = 1,
    String? forumId,
  }) : super(
          ThreadStateV2(
            threadId: threadId,
            pageRange: PageRange(start: page, end: page),
            forumId: forumId,
          ),
        ) {
    on<ThreadV2Event>(
      (event, emit) => switch (event) {
        ThreadV2LoadPrevPageRequested() => _onLoadPrevPage(emit),
        ThreadV2LoadNextPageRequested() => throw UnimplementedError(),
        ThreadV2JumpPageRequested() => throw UnimplementedError(),
      },
    );
  }

  final ThreadRepositoryV2 _repo;

  Future<void> _onLoadPrevPage(_Emit emit) async {
    if (state.status == ThreadStatusV2.loading) {
      return;
    }

    if (state.pageRange == null ||
        !state.pageRange!.hasNext(state.entirePageRange)) {
      return;
    }

    // TODO: Implement the handler
    final _ = await _repo
        .fetchThreadContent(
          tid: state.threadId,
          page: state.pageRange!.start - 1,
        )
        .run();
  }
}
