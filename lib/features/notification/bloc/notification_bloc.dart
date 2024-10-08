import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/features/notification/models/models.dart';
import 'package:tsdm_client/features/notification/repository/notification_repository.dart';
import 'package:tsdm_client/utils/logger.dart';

part 'notification_bloc.mapper.dart';
part 'notification_event.dart';
part 'notification_state.dart';

/// Emitter
typedef _Emit<M, T extends NotificationBaseState<M>> = Emitter<T>;

/// Bloc of notification.
class NotificationBaseBloc<M, T extends NotificationBaseState<M>>
    extends Bloc<NotificationEvent, T> with LoggerMixin {
  /// Constructor.
  NotificationBaseBloc({
    required NotificationRepository notificationRepository,
    required T initialState,
  })  : _notificationRepository = notificationRepository,
        super(initialState) {
    on<NotificationEvent>(
      (event, emit) => switch (event) {
        NotificationRefreshRequested() => _onRefreshRequested(emit),
        NotificationLoadMoreRequested() => _onLoadRequested(emit),
      },
    );
  }

  final NotificationRepository _notificationRepository;

  Future<void> _onRefreshRequested(_Emit<M, T> emit) async {
    emit(state.copyWith(status: NotificationStatus.loading) as T);
    switch (T) {
      case NoticeState:
        await _notificationRepository.fetchNotice().match((e) {
          handle(e);
          error('failed to fetch notice: $e');
          emit(state.copyWith(status: NotificationStatus.failure) as T);
        }, (v) {
          final noticeList = v.notificationList;
          emit(
            state.copyWith(
              status: NotificationStatus.success,
              noticeList: noticeList as List<M>,
            ) as T,
          );
        }).run();
      case PersonalMessageState:
        await _notificationRepository.fetchPersonalMessage().match((e) {
          handle(e);
          error('failed to fetch notice: $e');
          emit(state.copyWith(status: NotificationStatus.failure) as T);
        }, (v) {
          final noticeList = v;
          emit(
            state.copyWith(
              status: NotificationStatus.success,
              noticeList: noticeList as List<M>,
            ) as T,
          );
        }).run();
      case BroadcastMessageState:
        await _notificationRepository.fetchBroadMessage().match((e) {
          handle(e);
          error('failed to fetch notice: $e');
          emit(state.copyWith(status: NotificationStatus.failure) as T);
        }, (v) {
          final noticeList = v;
          emit(
            state.copyWith(
              status: NotificationStatus.success,
              noticeList: noticeList as List<M>,
            ) as T,
          );
        }).run();
      case Type():
        throw UnimplementedError('notification type not implemented: $T');
    }
  }

  Future<void> _onLoadRequested(_Emit<M, T> emit) async {
    throw UnimplementedError('implement load pages');
  }
}

/// Bloc of notice type notification.
final class NoticeBloc extends NotificationBaseBloc<Notice, NoticeState> {
  /// Constructor.
  NoticeBloc({required super.notificationRepository})
      : super(
          initialState: const NoticeState(),
        );
}

/// Bloc of personal message type notification.
final class PersonalMessageBloc
    extends NotificationBaseBloc<PersonalMessage, PersonalMessageState> {
  /// Constructor.
  PersonalMessageBloc({required super.notificationRepository})
      : super(
          initialState: const PersonalMessageState(),
        );
}

/// Bloc of broadcast message type notification.
final class BroadcastMessageBloc
    extends NotificationBaseBloc<BroadcastMessage, BroadcastMessageState> {
  /// Constructor.
  BroadcastMessageBloc({required super.notificationRepository})
      : super(
          initialState: const BroadcastMessageState(),
        );
}
