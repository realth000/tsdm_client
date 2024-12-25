import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/extensions/fp.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/features/notification/repository/notification_repository.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';
import 'package:tsdm_client/utils/logger.dart';

part 'auto_notification_cubit.mapper.dart';
part 'auto_notification_state.dart';

/// Cubit of auto notification feature.
///
/// This cubit takes control of automatically fetching notice from server,
/// update notice state.
///
/// This cubit only triggers automatic update of notification by calling global
/// [NotificationRepository], never handles the returned data .
/// For process on saving notice data in storage and merging fetched data with
/// current ones, see `NotificationBloc`. This is by design because here the
/// cubit SHOULD only be ca optional trigger of notification state update, all
/// data handling logic and presentation state update logic are implemented in
/// `NotificationBloc`.
final class AutoNotificationCubit extends Cubit<AutoNoticeState>
    with LoggerMixin {
  /// Constructor.
  AutoNotificationCubit({
    required AuthenticationRepository authenticationRepository,
    required NotificationRepository notificationRepository,
    required StorageProvider storageProvider,
    this.duration = Duration.zero,
  })  : _authenticationRepository = authenticationRepository,
        _notificationRepository = notificationRepository,
        _storageProvider = storageProvider,
        super(const AutoNoticeStateStopped());

  final AuthenticationRepository _authenticationRepository;
  final NotificationRepository _notificationRepository;
  final StorageProvider _storageProvider;

  /// Duration between auto fetch actions.
  Duration duration;

  /// Current time to tick.
  var _remainingTick = Duration.zero;

  /// Timer calculating fetch actions.
  Timer? _timer;

  AsyncVoidEither _emitDataState(int uid) {
    return AsyncVoidEither(() async {
      debug('auto fetch finished with data');
      emit(const AutoNoticeStatePending());

      // Code below is synced from _onRecordFetchTimeRequested in
      // NotificationBloc.
      //
      // NotificationBloc only exists in notice page so can not trigger actions
      // below by adding events to it.
      final now = DateTime.now();
      debug('update last fetch notification time to ${now.yyyyMMDDHHMMSS()}');
      await _storageProvider.updateLastFetchNoticeTime(uid, now).run();

      emit(AutoNoticeStateTicking(total: duration, remain: _remainingTick));

      return rightVoid();
    });
  }

  void _emitErrorState(AppException e) {
    error('auto fetch ended with error: $e');
    emit(const AutoNoticeStateStopped());
  }

  /// Do the auto fetch action when timeout.
  Future<void> _onTimeout() async {
    if (state is AutoNoticeStateStopped) {
      // Do nothing if already stopped.
      // Not intend to happen because the timer is canceled when stop but check
      // to make sure of that.
      return;
    }

    debug('running auto fetch...');

    // Mark as pending data.
    emit(const AutoNoticeStatePending());

    final uid = _authenticationRepository.currentUser?.uid;
    if (uid == null) {
      debug('skip auto fetch notice due to not-login state');
      return;
    }

    int? lastFetchTime;
    // TODO: More FP.
    final lastFetchTimeEither =
        await _storageProvider.fetchLastFetchNoticeTime(uid).run();
    if (lastFetchTimeEither.isRight()) {
      final t = lastFetchTimeEither.unwrap();
      if (t != null) {
        lastFetchTime = t.millisecondsSinceEpoch ~/ 1000;
      }
    }
    await _notificationRepository
        .fetchNotificationV2(uid: uid, timestamp: lastFetchTime)
        .andThen(() => _emitDataState(uid))
        .mapLeft(_emitErrorState)
        .run();
  }

  /// Start and schedule auto fetch actions.
  ///
  /// Will stop and restart if already running.
  ///
  /// Override the auto fetch action duration with parameter [duration].
  void start(Duration? duration) {
    // Do NOT start auto sync if duration is invalid.
    if (duration == null && this.duration.inSeconds < 30) {
      return;
    }
    info('start auto fetch with duration $duration');
    // Note that here is no check on whether already running a auto fetch action
    // because it's the callback to do the actual fetch job so changing duration
    // or timer here breaks nothing.

    if (duration != null) {
      this.duration = duration;
      _remainingTick = duration;
    }

    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      _remainingTick -= const Duration(seconds: 1);
      emit(
        AutoNoticeStateTicking(
          total: this.duration,
          remain: _remainingTick,
        ),
      );
      if (_remainingTick.inSeconds > 0) {
        return;
      }

      // Timeout, reset.
      _remainingTick = this.duration;
      await _onTimeout();
    });
  }

  /// Stop the auto fetch scheduler.
  void stop() {
    info('stop auto fetch with duration $duration');
    _timer?.cancel();
    _timer = null;
    _remainingTick = Duration.zero;
    emit(const AutoNoticeStateStopped());
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    await super.close();
  }
}
