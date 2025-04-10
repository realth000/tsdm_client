import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/features/profile/repository/profile_repository.dart';
import 'package:tsdm_client/utils/logger.dart';

part 'edit_avatar_bloc.mapper.dart';
part 'edit_avatar_event.dart';
part 'edit_avatar_state.dart';

typedef _Emit = Emitter<EditAvatarState>;

/// The edit state.
final class EditAvatarBloc extends Bloc<EditAvatarEvent, EditAvatarState> with LoggerMixin {
  /// Constructor.
  EditAvatarBloc(this._repo) : super(const EditAvatarState()) {
    on<EditAvatarEvent>(
      (event, emit) => switch (event) {
        EditAvatarLoadInfoRequested() => _onLoadInfo(emit),
        EditAvatarUploadRequested(:final avatarUrl, :final formHash) => _onUpload(emit, avatarUrl, formHash),
      },
    );
  }

  final ProfileRepository _repo;

  Future<void> _onLoadInfo(_Emit emit) async {
    emit(state.copyWith(status: EditAvatarStatus.loading));

    await _repo
        .loadAvatarUrl()
        .map((v) => emit(state.copyWith(status: EditAvatarStatus.waitingForUpload, avatarUrl: v.$1, formHash: v.$2)))
        .mapLeft((e) {
          handle(e);
          emit(state.copyWith(status: EditAvatarStatus.failure));
        })
        .run();
  }

  Future<void> _onUpload(_Emit emit, String avatarUrl, String formHash) async {
    emit(state.copyWith(status: EditAvatarStatus.uploading));

    await _repo.uploadAvatarUrl(url: avatarUrl, formHash: formHash).handle((e) {
      handle(e);
      emit(state.copyWith(status: EditAvatarStatus.failure));
    }, (_) => emit(state.copyWith(status: EditAvatarStatus.success)));
  }
}
