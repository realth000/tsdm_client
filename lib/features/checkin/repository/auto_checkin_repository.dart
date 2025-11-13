import 'package:collection/collection.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/fp.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/features/checkin/models/models.dart';
import 'package:tsdm_client/features/checkin/utils/do_checkin.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/cookie_provider/cookie_provider.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/shared/providers/providers.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';
import 'package:tsdm_client/utils/logger.dart';

/// Repository for the auto checkin feature.
final class AutoCheckinRepository with LoggerMixin {
  /// Constructor.
  AutoCheckinRepository({required StorageProvider storageProvider}) : _storageProvider = storageProvider;

  final StorageProvider _storageProvider;

  /// Controller of stream providing current checkin info status.
  final _stream = BehaviorSubject<AutoCheckinInfo>();

  /// Stream of auto checkin progress.
  Stream<AutoCheckinInfo> get status => _stream.asBroadcastStream();

  /// Current status.
  var _currentInfo = AutoCheckinInfo.empty();

  /// Run checkin progress on all users.
  ///
  /// [concurrencyLimit] is the maximum checkin task running at the same time.
  /// To simplify the control progress, all tasks are chunked into pieces with
  /// the length of [concurrencyLimit] and each group is waiting for its
  /// previous groups. Not fully a regular throttle but simple and easy to
  /// implement.
  AsyncVoidEither checkinAll({
    required List<UserLoginInfo> waitingList,
    required List<UserLoginInfo> skippedList,
    required int concurrencyLimit,
    required CheckinFeeling feeling,
    required String message,
  }) => AsyncVoidEither(() async {
    // Initialize state.
    _updateSkipped(skippedList);
    _updateWaiting(waitingList);

    final progressGroups = waitingList.slices(concurrencyLimit);
    for (final pg in progressGroups) {
      debug(
        'run auto checkin for uid '
        '${pg.map((e) => "${e.uid}".obscured(4)).join(", ")}',
      );
      _updateRunning(pg);

      // FIXME: Reduce complexity.
      final tasks = pg
          .map(
            (userInfo) => _prepareCheckin(userInfo)
                .mapLeft((e) => _updateFailure(e, const CheckinResultNotAuthorized()))
                .map((netClient) async => (userInfo, await doCheckin(netClient, feeling, message).run())),
          )
          .map((e) async => e.run());
      final info = await Future.wait(tasks);
      final results = await Future.wait(info.map((e) => e.unwrap()));
      // FIXME: This message extracting step is anti-pattern.
      for (final result in results) {
        final (userInfo, checkinResult) = result;
        switch (checkinResult) {
          case CheckinResultSuccess(:final message):
            _updateSuccess(userInfo, CheckinResultSuccess(message));
          case CheckinResultNotAuthorized():
            _updateNotAuthed(userInfo);
          case CheckinResultWebRequestFailed(:final statusCode):
            _updateFailure(userInfo, CheckinResultWebRequestFailed(statusCode));
          case CheckinResultFormHashNotFound():
            _updateFailure(userInfo, const CheckinResultFormHashNotFound());
          case CheckinResultAlreadyChecked():
            _updateFailure(userInfo, const CheckinResultAlreadyChecked());
          case CheckinResultEarlyInTime():
            _updateFailure(userInfo, const CheckinResultEarlyInTime());
          case CheckinResultLateInTime():
            _updateFailure(userInfo, const CheckinResultLateInTime());
          case CheckinResultOtherError(:final message):
            _updateFailure(userInfo, CheckinResultOtherError(message));
        }
      }
    }

    return rightVoid();
  });

  TaskEither<UserLoginInfo, NetClientProvider> _prepareCheckin(UserLoginInfo userInfo) => TaskEither(() async {
    final cookieProvider = getIt.get<CookieProvider>(instanceName: ServiceKeys.empty);
    final loaded = await cookieProvider.loadCookieFromStorage(userInfo);
    if (!loaded) {
      return left(userInfo);
    }
    // FIXME: anti-pattern.
    final netClient = NetClientProvider.buildNoCookie(cookie: cookieProvider);
    return right(netClient);
  });

  /// Update status: [userInfoList] is in unauthenticated state.
  void _updateSkipped(List<UserLoginInfo> userInfoList) {
    _currentInfo = _currentInfo.copyWith(skipped: [..._currentInfo.skipped, ...userInfoList]);
    _stream.add(_currentInfo);
  }

  /// Update status: [userInfoList] is in unauthenticated state.
  void _updateWaiting(List<UserLoginInfo> userInfoList) {
    _currentInfo = _currentInfo.copyWith(
      waiting: _currentInfo.waiting.toList()..removeWhere((e) => userInfoList.contains(e)),
      running: [..._currentInfo.running, ...userInfoList],
    );
    _stream.add(_currentInfo);
  }

  /// Update status: [userInfoList] started running.
  void _updateRunning(List<UserLoginInfo> userInfoList) {
    _currentInfo = _currentInfo.copyWith(
      waiting: _currentInfo.waiting.toList()..removeWhere((e) => userInfoList.contains(e)),
      running: [..._currentInfo.running, ...userInfoList],
    );
    _stream.add(_currentInfo);
  }

  /// Update status: [userInfo] ends up with failure in checkin progress.
  void _updateFailure(UserLoginInfo userInfo, CheckinResult checkinResult) {
    _currentInfo = _currentInfo.copyWith(
      running: _currentInfo.running..removeWhere((e) => e == userInfo),
      failed: [..._currentInfo.failed, (userInfo, checkinResult)],
    );
    _stream.add(_currentInfo);
  }

  /// Update status: [userInfo] checked in successfully.
  void _updateSuccess(UserLoginInfo userInfo, CheckinResult checkinResult) {
    // FIXME: Here is a time gap between start checkin and checkin finished.
    // If any login-user related operation acted, for example logout or switch
    // to another user, the current user below is unexpected behavior.
    // So it's better to make a lock when doing checkin.
    _storageProvider.updateLastCheckinTime(userInfo.uid!, DateTime.now());
    _currentInfo = _currentInfo.copyWith(
      running: _currentInfo.running..removeWhere((e) => e == userInfo),
      succeeded: [..._currentInfo.succeeded, (userInfo, checkinResult)],
    );
    _stream.add(_currentInfo);
  }

  /// Update status: [userInfo] is in unauthenticated state.
  void _updateNotAuthed(UserLoginInfo userInfo) {
    _currentInfo = _currentInfo.copyWith(
      running: _currentInfo.running..removeWhere((e) => e == userInfo),
      notAuthed: [..._currentInfo.notAuthed],
    );
    _stream.add(_currentInfo);
  }

  /// Dispose the repo.
  Future<void> dispose() async {
    await _stream.close();
  }
}
