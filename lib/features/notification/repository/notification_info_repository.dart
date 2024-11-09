import 'package:rxdart/rxdart.dart';
import 'package:tsdm_client/features/notification/bloc/notification_state_cubit.dart';

/// A small repository for notification state cubit.
///
/// Act like a bridge between `NotificationBloc` and `AutoNotificationBloc`. The
/// former one calculates the latest notification status info, and the latter
/// one stores the info calculated and provide to presentation layer.
final class NotificationInfoRepository {
  final _controller = BehaviorSubject<NotificationStateInfo>();

  /// Stream of received notification info.
  Stream<NotificationStateInfo> get status => _controller.asBroadcastStream();

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

  /// Dispose the repo.
  void dispose() {
    _controller.close();
  }
}
