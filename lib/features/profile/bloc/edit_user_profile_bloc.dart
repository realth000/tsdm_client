import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:tsdm_client/features/profile/models/editable_user_profile.dart' as eup;
import 'package:tsdm_client/features/profile/repository/edit_user_profile_repository.dart';
import 'package:tsdm_client/utils/logger.dart';

part 'edit_user_profile_bloc.mapper.dart';
part 'edit_user_profile_event.dart';
part 'edit_user_profile_state.dart';

typedef _Emit = Emitter<EditUserProfileState>;

/// The bloc.
final class EditUserProfileBloc extends Bloc<EditUserProfileEvent, EditUserProfileState> with LoggerMixin {
  /// Constructor.
  EditUserProfileBloc(this._repo) : super(const EditUserProfileState()) {
    on<EditUserProfileEvent>(
      (event, emit) async => switch (event) {
        EditUserProfileLoadProfileRequested() => await _onLoadProfile(emit),
        EditUserProfileSubmitRequested() => throw UnimplementedError(),
        EditUserProfileSaveProfileRequested(:final profile) => _onSaveProfile(emit, profile),
        EditUserProfileUploadProfileRequested(:final profile) => _onUploadProfile(emit, profile),
      },
    );
  }

  final EditUserProfileRepository _repo;

  Future<void> _onLoadProfile(_Emit emit) async {
    emit(state.copyWith(status: .loading));
    switch (await _repo.loadProfile().run()) {
      case Right(:final value):
        emit(state.copyWith(status: .success, profile: value));
      case Left(:final value):
        error('failed to load editable user profile: $value');
        emit(state.copyWith(status: .failure));
    }
  }

  void _onSaveProfile(_Emit emit, eup.UserProfile profile) => emit(state.copyWith(profile: profile));

  Future<void> _onUploadProfile(_Emit emit, eup.UserProfile profile) async {
    emit(state.copyWith(status: .submitting));
    switch (await _repo.uploadProfile(profile).run()) {
      case Right():
        emit(state.copyWith(status: .success));
      case Left(:final value):
        handle(value);
        emit(state.copyWith(status: .failure));
    }
  }
}
