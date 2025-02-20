import 'package:rxdart/rxdart.dart';
import 'package:tsdm_client/features/notification/bloc/notification_state_cubit.dart';
import 'package:tsdm_client/features/notification/models/models.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/utils/platform.dart';

/// A small repository for notification state cubit.
///
/// Act like a bridge between `NotificationBloc` and `AutoNotificationBloc`. The
/// former one calculates the latest notification status info, and the latter
/// one stores the info calculated and provide to presentation layer.
final class NotificationInfoRepository with LoggerMixin {
  final _controller = BehaviorSubject<NotificationStateInfo>();
  final _autoSyncController = BehaviorSubject<NotificationAutoSyncInfo>();

  /// Stream of received notification info.
  Stream<NotificationStateInfo> get status => _controller.asBroadcastStream();

  /// Stream of incoming new notification to display as local notification.
  Stream<NotificationAutoSyncInfo> get autoSyncStatus => _autoSyncController.asBroadcastStream();

  /// Update notification state info.
  ///
  /// This function will construct and update a brand new info from parameters
  /// and override all existing state in state cubit.
  void updateInfo({
    required int unreadNoticeCount,
    required int unreadPersonalMessageCount,
    required int unreadBroadcastMessageCount,
  }) {
    _controller.add(
      NotificationStateInfo(
        notice: unreadNoticeCount,
        personalMessage: unreadPersonalMessageCount,
        broadcastMessage: unreadBroadcastMessageCount,
      ),
    );
  }

  /// Update the latest received notice status in last auto sync notice action.
  void updateAutoSyncInfo(NotificationAutoSyncInfo info) {
    if (!isAndroid) {
      return;
    }
    debug('update auto sync info: $info');
    _autoSyncController.add(info);
  }

  /// Dispose the repo.
  void dispose() {
    _controller.close();
    _autoSyncController.close();
  }
}
