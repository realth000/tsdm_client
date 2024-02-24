import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/features/notification/models/models.dart';
import 'package:tsdm_client/features/notification/repository/notification_repository.dart';
import 'package:tsdm_client/utils/debug.dart';

part '../../../generated/features/notification/bloc/notification_bloc.mapper.dart';
part 'notification_event.dart';
part 'notification_state.dart';

/// Emitter
typedef NotificationEmitter = Emitter<NotificationState>;

/// Bloc of notification.
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  /// Constructor.
  NotificationBloc({required NotificationRepository notificationRepository})
      : _notificationRepository = notificationRepository,
        super(const NotificationState()) {
    on<NotificationRefreshNoticeRequired>(_onNotificationRefreshNoticeRequired);
  }

  final NotificationRepository _notificationRepository;

  Future<void> _onNotificationRefreshNoticeRequired(
    NotificationRefreshNoticeRequired event,
    NotificationEmitter emit,
  ) async {
    emit(state.copyWith(status: NotificationStatus.loading));
    try {
      final noticeList = await _notificationRepository.fetchNotice();
      emit(
        state.copyWith(
          status: NotificationStatus.success,
          noticeList: noticeList,
        ),
      );
    } on HttpRequestFailedException catch (e) {
      debug('failed to fetch notice: $e');
      emit(state.copyWith(status: NotificationStatus.failed));
    }
  }
}
