import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/utils/logger.dart';

part 'switch_user_event.dart';

part 'switch_user_state.dart';

part 'switch_user_bloc.mapper.dart';

typedef _Emit = Emitter<SwitchUserBaseState>;

/// Bloc for switching user.
///
/// This bloc records the state of switching user process.
final class SwitchUserBloc extends Bloc<SwitchUserBaseEvent, SwitchUserBaseState> with LoggerMixin {
  /// Constructor.
  SwitchUserBloc(this._repo) : super(const SwitchUserInitial()) {
    on<SwitchUserBaseEvent>(
      (event, emit) => switch (event) {
        SwitchUserStartRequested(:final userInfo) => _onStart(emit, userInfo),
      },
    );
  }

  final AuthenticationRepository _repo;

  Future<void> _onStart(_Emit emit, UserLoginInfo userInfo) async {
    emit(const SwitchUserLoading());
    switch (await _repo.switchUser(userInfo).run()) {
      case Left(:final value):
        handle(value);
        emit(SwitchUserFailure(value));
      case Right():
        emit(const SwitchUserSuccess());
    }
  }
}
