import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/features/notification/models/models.dart';
import 'package:tsdm_client/features/notification/repository/notification_repository.dart';
import 'package:tsdm_client/utils/logger.dart';

part 'notification_bloc.mapper.dart';
part 'notification_event.dart';

part 'notification_state.dart';

/// Emitter
typedef _Emit = Emitter<NotificationState>;

/// Bloc of notification.
class NotificationBloc extends Bloc<NotificationEvent, NotificationState>
    with LoggerMixin {
  /// Constructor.
  NotificationBloc({required NotificationRepository notificationRepository})
      : _notificationRepository = notificationRepository,
        super(const NotificationState()) {
    on<NotificationRefreshNoticeRequired>(_onNotificationRefreshNoticeRequired);
    on<NotificationRefreshPersonalMessageRequired>(
      _onNotificationRefreshPersonalMessageRequired,
    );
    on<NotificationRefreshBroadcastMessageRequired>(
      _onNotificationRefreshBroadcastMessageRequired,
    );
  }

  final NotificationRepository _notificationRepository;

  Future<void> _onNotificationRefreshNoticeRequired(
    NotificationRefreshNoticeRequired event,
    _Emit emit,
  ) async {
    emit(state.copyWith(noticeStatus: NotificationStatus.loading));
    try {
      final noticeList = await _notificationRepository.fetchNotice();
      emit(
        state.copyWith(
          noticeStatus: NotificationStatus.success,
          noticeList: noticeList,
        ),
      );
    } on HttpRequestFailedException catch (e) {
      error('failed to fetch notice: $e');
      emit(state.copyWith(noticeStatus: NotificationStatus.failed));
    }
  }

  Future<void> _onNotificationRefreshPersonalMessageRequired(
    NotificationRefreshPersonalMessageRequired event,
    _Emit emit,
  ) async {
    emit(state.copyWith(personalMessageStatus: NotificationStatus.loading));
    try {
      final privateMessageList =
          await _notificationRepository.fetchPersonalMessage();
      emit(
        state.copyWith(
          personalMessageStatus: NotificationStatus.success,
          personalMessageList: privateMessageList,
        ),
      );
    } on HttpRequestFailedException catch (e) {
      error('failed to fetch private messages: $e');

      emit(state.copyWith(personalMessageStatus: NotificationStatus.failed));
    }
  }

  Future<void> _onNotificationRefreshBroadcastMessageRequired(
    NotificationRefreshBroadcastMessageRequired event,
    _Emit emit,
  ) async {
    emit(state.copyWith(broadcastMessageStatus: NotificationStatus.loading));
    try {
      final broadcastMessageList =
          await _notificationRepository.fetchBroadMessage();
      emit(
        state.copyWith(
          broadcastMessageStatus: NotificationStatus.success,
          broadcastMessageList: broadcastMessageList,
        ),
      );
    } on HttpRequestFailedException catch (e) {
      error('failed to fetch broad messages: $e');
      emit(state.copyWith(broadcastMessageStatus: NotificationStatus.failed));
    }
  }
}
