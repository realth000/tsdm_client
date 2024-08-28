import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/extensions/fp.dart';
import 'package:tsdm_client/features/thread_publish/models/models.dart';
import 'package:tsdm_client/features/thread_publish/repository/thread_pub_repository.dart';
import 'package:tsdm_client/utils/logger.dart';

part 'thread_publish_bloc.mapper.dart';
part 'thread_publish_event.dart';
part 'thread_publish_state.dart';

typedef _Emit = Emitter<ThreadPubState>;

/// Bloc of thread publish.
///
/// * Fetch thread info.
/// * Post thread data.
/// * Save thread data.
final class ThreadPubBloc extends Bloc<ThreadPubEvent, ThreadPubState>
    with LoggerMixin {
  /// Constructor.
  ThreadPubBloc(this._repo)
      : super(const ThreadPubState(status: ThreadPubStatus.initial)) {
    on<ThreadPubEvent>(
      (event, emit) => switch (event) {
        ThreadPubFetchInfoRequested(:final fid) => _onFetchInfo(fid, emit),
        ThreadPubPostThread(:final info) => _onPostThread(info, emit),
      },
    );
  }

  final ThreadPubRepository _repo;

  Future<void> _onFetchInfo(String fid, _Emit emit) async {
    emit(state.copyWith(status: ThreadPubStatus.loadingInfo));

    final docEither = await _repo.prepareInfo(fid).run();
    if (docEither.isLeft()) {
      handle(docEither.unwrapErr());
      emit(state.copyWith(status: ThreadPubStatus.failure));
      return;
    }

    final doc = docEither.unwrap();
    final formHash = doc.querySelector('input#formhash')?.attributes['value'];
    final postTime = doc.querySelector('input#posttime')?.attributes['value'];

    if (formHash == null || postTime == null) {
      error('failed to fetch info: form hash or post time not found: '
          'formHash=$formHash, postTime=$postTime');
      emit(state.copyWith(status: ThreadPubStatus.failure));
      return;
    }

    emit(
      state.copyWith(
        status: ThreadPubStatus.readyToPost,
        forumHash: formHash,
        postTime: postTime,
      ),
    );
  }

  Future<void> _onPostThread(
    ThreadPublishInfo info,
    _Emit emit,
  ) async {
    emit(state.copyWith(status: ThreadPubStatus.posting));

    final urlEither = await _repo.postThread(info).run();
    if (urlEither.isLeft()) {
      handle(urlEither.unwrapErr());
      emit(state.copyWith(status: ThreadPubStatus.failure));
      return;
    }

    emit(
      state.copyWith(
        status: ThreadPubStatus.success,
        redirectUrl: urlEither.unwrap(),
      ),
    );
  }
}
