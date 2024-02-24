import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/shared/providers/checkin_provider/checkin_provider.dart';
import 'package:tsdm_client/shared/providers/checkin_provider/models/check_in_feeling.dart';
import 'package:tsdm_client/shared/providers/checkin_provider/models/checkin_result.dart';
import 'package:tsdm_client/shared/repositories/settings_repository/settings_repository.dart';

part '../../../generated/widgets/checkin_button/bloc/checkin_button_bloc.mapper.dart';
part 'checkin_button_event.dart';
part 'checkin_button_state.dart';

/// Bloc of checkin.
class CheckinButtonBloc extends Bloc<CheckinButtonEvent, CheckinButtonState> {
  /// Constructor.
  CheckinButtonBloc({
    required CheckinProvider checkinProvider,
    required AuthenticationRepository authenticationRepository,
    required SettingsRepository settingsRepository,
  })  : _checkinProvider = checkinProvider,
        _authenticationRepository = authenticationRepository,
        _settingsRepository = settingsRepository,
        super(const CheckinButtonInitial()) {
    on<CheckinButtonRequested>(_onCheckinButtonRequested);
    on<CheckinButtonAuthChanged>(_onCheckinButtonAuthChanged);
    _authStreamSub = _authenticationRepository.status.listen(
      (status) => add(
        CheckinButtonAuthChanged(
          authed: status == AuthenticationStatus.authenticated,
        ),
      ),
    );
  }

  late StreamSubscription<AuthenticationStatus> _authStreamSub;

  final CheckinProvider _checkinProvider;
  final AuthenticationRepository _authenticationRepository;
  final SettingsRepository _settingsRepository;

  Future<void> _onCheckinButtonRequested(
    CheckinButtonRequested event,
    Emitter<CheckinButtonState> emit,
  ) async {
    if (_authenticationRepository.currentUser == null) {
      emit(const CheckinButtonNeedLogin());
      return;
    }
    emit(const CheckinButtonLoading());
    final checkinFeeling = _settingsRepository.getCheckinFeeling();
    final checkinMessage = _settingsRepository.getCheckinMessage();
    final result = await _checkinProvider.checkin(
      CheckinFeeling.from(checkinFeeling),
      checkinMessage,
    );
    if (result is CheckinButtonSuccess) {
      emit(CheckinButtonSuccess((result as CheckinButtonSuccess).message));
      return;
    }
    emit(CheckinButtonFailed(result));
  }

  void _onCheckinButtonAuthChanged(
    CheckinButtonAuthChanged event,
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
