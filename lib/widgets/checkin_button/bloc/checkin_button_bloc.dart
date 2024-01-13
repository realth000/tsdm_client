import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/checkin_provider/checkin_provider.dart';
import 'package:tsdm_client/shared/providers/checkin_provider/models/check_in_feeling.dart';
import 'package:tsdm_client/shared/providers/checkin_provider/models/checkin_result.dart';
import 'package:tsdm_client/shared/providers/settings_provider/settings_provider.dart';
import 'package:tsdm_client/shared/repositories/authentication_repository/authentication_repository.dart';

part 'checkin_button_event.dart';
part 'checkin_button_state.dart';

class CheckinButtonBloc extends Bloc<CheckinButtonEvent, CheckinButtonState> {
  CheckinButtonBloc(
      {required CheckinProvider checkinProvider,
      required AuthenticationRepository authenticationRepository})
      : _checkinProvider = checkinProvider,
        _authenticationRepository = authenticationRepository,
        super(const CheckinButtonInitial()) {
    on<CheckinButtonRequested>(_onCheckinButtonRequested);
    on<_CheckinButtonAuthChanged>(_onCheckinButtonAuthChanged);
    _authStreamSub = _authenticationRepository.status.listen((status) => add(
        _CheckinButtonAuthChanged(
            authed: status == AuthenticationStatus.authenticated)));
  }

  late StreamSubscription<AuthenticationStatus> _authStreamSub;

  final CheckinProvider _checkinProvider;
  final AuthenticationRepository _authenticationRepository;

  Future<void> _onCheckinButtonRequested(
    CheckinButtonRequested event,
    Emitter<CheckinButtonState> emit,
  ) async {
    if (_authenticationRepository.currentUser == null) {
      emit(const CheckinButtonNeedLogin());
      return;
    }
    emit(const CheckinButtonLoading());
    final checkinFeeling = getIt.get<SettingsProvider>().getCheckinFeeling();
    final checkinMessage = getIt.get<SettingsProvider>().getCheckinMessage();
    final result = await _checkinProvider.checkin(
        CheckinFeeling.from(checkinFeeling), checkinMessage);
    if (result is CheckinButtonSuccess) {
      emit(CheckinButtonSuccess((result as CheckinButtonSuccess).message));
      return;
    }
    emit(CheckinButtonFailed(result));
  }

  void _onCheckinButtonAuthChanged(
    _CheckinButtonAuthChanged event,
    Emitter<CheckinButtonState> emit,
  ) {
    if (event.authed) {
      if (state is CheckinButtonLoading) {
        return;
      }
      emit(const CheckinButtonInitial());
    } else {
      if (state is CheckinButtonLoading) {
        return;
      }
      emit(const CheckinButtonNeedLogin());
    }
  }

  @override
  Future<void> close() async {
    await _authStreamSub.cancel();
    await super.close();
  }
}
