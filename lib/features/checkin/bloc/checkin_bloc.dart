import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/features/authentication/repository/models/models.dart';
import 'package:tsdm_client/features/checkin/models/models.dart';
import 'package:tsdm_client/features/checkin/repository/checkin_repository.dart';
import 'package:tsdm_client/features/settings/repositories/settings_repository.dart';
import 'package:tsdm_client/shared/models/models.dart';

part 'checkin_bloc.mapper.dart';
part 'checkin_event.dart';
part 'checkin_state.dart';

/// Bloc of checkin.
final class CheckinBloc extends Bloc<CheckinEvent, CheckinState> {
  /// Constructor.
  CheckinBloc({
    required CheckinRepository checkinRepository,
    required AuthenticationRepository authenticationRepository,
    required SettingsRepository settingsRepository,
  }) : _checkinRepository = checkinRepository,
       _authenticationRepository = authenticationRepository,
       _settingsRepository = settingsRepository,
       super(const CheckinStateInitial()) {
    on<CheckinRequested>(_onCheckinRequested);
    on<CheckinAuthChanged>(_onCheckinAuthChanged);
    _authStreamSub = _authenticationRepository.status.listen(
      (status) => add(CheckinAuthChanged(authed: status is AuthStatusAuthed)),
    );
  }

  late StreamSubscription<AuthStatus> _authStreamSub;

  final CheckinRepository _checkinRepository;
  final AuthenticationRepository _authenticationRepository;
  final SettingsRepository _settingsRepository;

  Future<void> _onCheckinRequested(CheckinRequested event, Emitter<CheckinState> emit) async {
    if (_authenticationRepository.currentUser == null) {
      emit(const CheckinStateNeedLogin());
      return;
    }
    emit(const CheckinStateLoading());
    final checkinFeeling = await _settingsRepository.getValue<String>(SettingsKeys.checkinFeeling);
    final checkinMessage = await _settingsRepository.getValue<String>(SettingsKeys.checkinMessage);
    final result = await _checkinRepository.checkin(
      _authenticationRepository.currentUser!.uid!,
      CheckinFeeling.from(checkinFeeling),
      checkinMessage,
    );
    if (result is CheckinStateSuccess) {
      emit(CheckinStateSuccess((result as CheckinStateSuccess).message));
      return;
    }
    emit(CheckinStateFailed(result));
  }

  void _onCheckinAuthChanged(CheckinAuthChanged event, Emitter<CheckinState> emit) {
    if (event.authed) {
      if (state is CheckinStateLoading) {
        return;
      }
      emit(const CheckinStateInitial());
    } else {
      if (state is CheckinStateLoading) {
        return;
      }
      emit(const CheckinStateNeedLogin());
    }
  }

  @override
  Future<void> close() async {
    await _authStreamSub.cancel();
    await super.close();
  }
}
