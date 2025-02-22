import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/features/forum/repository/forum_repository.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/utils/logger.dart';

part 'forum_group_event.dart';

part 'forum_group_state.dart';

part 'forum_group_bloc.mapper.dart';

typedef _Emit = Emitter<ForumGroupBaseState>;

/// The bloc of forum group feature.
final class ForumGroupBloc extends Bloc<ForumGroupBaseEvent, ForumGroupBaseState> with LoggerMixin {
  /// Constructor.
  ForumGroupBloc(this._repo) : super(const ForumGroupInitial()) {
    on<ForumGroupBaseEvent>(
      (event, emit) => switch (event) {
        ForumGroupLoadRequested(:final gid) => _onLoad(emit, gid),
      },
    );
  }

  final ForumRepository _repo;

  Future<void> _onLoad(_Emit emit, String gid) async {
    emit(const ForumGroupLoading());

    await _repo
        .fetchForumGroup(gid)
        .map((v) => v == null ? emit(const ForumGroupFailure()) : emit(ForumGroupSuccess(v)))
        .mapLeft((e) {
          handle(e);
          emit(const ForumGroupFailure());
        })
        .run();
  }
}
