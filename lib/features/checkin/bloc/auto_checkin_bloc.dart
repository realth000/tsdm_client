import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/features/checkin/models/models.dart';
import 'package:tsdm_client/features/checkin/repository/auto_checkin_repository.dart';
import 'package:tsdm_client/features/settings/repositories/settings_repository.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';

part 'auto_checkin_bloc.mapper.dart';

part 'auto_checkin_event.dart';

part 'auto_checkin_state.dart';

typedef _Emit = Emitter<AutoCheckinState>;

/// Bloc for auto checkin feature.
final class AutoCheckinBloc extends Bloc<AutoCheckinEvent, AutoCheckinState> {
  /// Constructor.
  AutoCheckinBloc({
    required AutoCheckinRepository autoCheckinRepository,
    required SettingsRepository settingsRepository,
    required StorageProvider storageProvider,
  }) : _autoCheckinRepository = autoCheckinRepository,
       _settingsRepository = settingsRepository,
       _storageProvider = storageProvider,
       super(const AutoCheckinStateInitial()) {
    on<AutoCheckinEvent>(
      (e, emit) => switch (e) {
        AutoCheckinStartRequested() => _onStart(emit),
        AutoCheckinUserStateChanged(:final checkinInfo) => _onUserStateChanged(checkinInfo, emit),
      },
    );

    // Update checkin state.
    _stateSub = _autoCheckinRepository.status.listen((e) => add(AutoCheckinUserStateChanged(e)));
  }

  final AutoCheckinRepository _autoCheckinRepository;
  final SettingsRepository _settingsRepository;
  final StorageProvider _storageProvider;

  late final StreamSubscription<AutoCheckinInfo> _stateSub;

  /// Start auto checkin progress.
  ///
  /// Unlike most event handler functions, this one only triggers the progress,
  /// not changing any state of current bloc.
  ///
  /// Alternatively, state is updated by acting on repository's state stream
  /// called [_onUserStateChanged].
  Future<void> _onStart(_Emit emit) async {
    // First trap into preparing state.
    emit(const AutoCheckinStatePreparing());

    final now = DateTime.now();
    final users = await _storageProvider.getAllUsersWithTime();

    final skippedList = <UserLoginInfo>[];
    final waitingList = <UserLoginInfo>[];
    for (final (user, lastCheckinTime) in users) {
      if ((user.uid == null || user.uid! < 1) || (user.username == null || user.username!.isEmpty)) {
        // Drop invalid ones.
        continue;
      }
      // By default, only run checkin on those users who has a last checkin time
      // passed 1 day or more.
      if (lastCheckinTime == null ||
          now.year > lastCheckinTime.year ||
          now.month > lastCheckinTime.month ||
          now.day > lastCheckinTime.day) {
        waitingList.add(user);
      } else {
        skippedList.add(user);
      }
    }
    if (waitingList.isEmpty) {
      // No users to auto checkin, skip.
      emit(const AutoCheckinStateInitial());
      return;
    }

    final checkinFeeling = await _settingsRepository.getValue<String>(SettingsKeys.checkinFeeling);
    final checkinMessage = await _settingsRepository.getValue<String>(SettingsKeys.checkinMessage);
    await _autoCheckinRepository
        .checkinAll(
          waitingList: waitingList,
          skippedList: skippedList,
          concurrencyLimit: 4,
          feeling: CheckinFeeling.from(checkinFeeling),
          message: checkinMessage,
        )
        .run();
  }

  Future<void> _onUserStateChanged(AutoCheckinInfo checkinInfo, _Emit emit) async {
    if (checkinInfo.running.isEmpty && (checkinInfo.succeeded.isNotEmpty || checkinInfo.failed.isNotEmpty)) {
      final now = DateTime.now();
      for (final (user, _) in checkinInfo.succeeded) {
        await _storageProvider.updateLastCheckinTime(user.uid!, now).run();
      }
      for (final (user, checkinResult) in checkinInfo.failed) {
        // Still record checkin time if is already checked in because user may
        // checkin on another machine.
        if (checkinResult is CheckinResultAlreadyChecked) {
          await _storageProvider.updateLastCheckinTime(user.uid!, now).run();
        }
      }
      emit(AutoCheckinStateFinished(succeeded: checkinInfo.succeeded, failed: checkinInfo.failed));
      return;
    }

    emit(AutoCheckinStateLoading(checkinInfo));
  }

  @override
  Future<void> close() {
    _stateSub.cancel();
    _autoCheckinRepository.dispose();
    return super.close();
  }
}
