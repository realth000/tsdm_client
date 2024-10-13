import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/extensions/fp.dart';
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
          emit(
            state.copyWith(
              status: NotificationStatus.success,
              noticeList: v.notificationList as List<M>,
              pageNumber: v.pageNumber,
              hasNextPage: v.hasNextPage,
            ) as T,
          );
        }).run();
      case PersonalMessageState:
        await _notificationRepository.fetchPersonalMessage().match((e) {
          handle(e);
          error('failed to fetch notice: $e');
          emit(state.copyWith(status: NotificationStatus.failure) as T);
        }, (v) {
          if (v.isLeft()) {
            error(v.unwrapErr());
            return;
          }
          final d = v.unwrap();
          final noticeList = d.notificationList;
          emit(
            state.copyWith(
              status: NotificationStatus.success,
              noticeList: noticeList as List<M>,
              pageNumber: d.pageNumber,
              hasNextPage: d.hasNextPage,
            ) as T,
          );
        }).run();
      case BroadcastMessageState:
        await _notificationRepository.fetchBroadMessage().match((e) {
          handle(e);
          error('failed to fetch notice: $e');
          emit(state.copyWith(status: NotificationStatus.failure) as T);
        }, (v) {
          if (v.isLeft()) {
            error(v.unwrapErr());
            emit(state.copyWith(status: NotificationStatus.failure) as T);
            return;
          }
          final d = v.unwrap();
          emit(
            state.copyWith(
              status: NotificationStatus.success,
              noticeList: d.notificationList as List<M>,
              hasNextPage: d.hasNextPage,
              pageNumber: d.pageNumber,
            ) as T,
          );
        }).run();
      case Type():
        throw UnimplementedError('notification type not implemented: $T');
    }
  }

  Future<void> _onLoadRequested(_Emit<M, T> emit) async {
    if (!state.hasNextPage) {
      emit(state.copyWith(status: NotificationStatus.noMoreData) as T);
      return;
    }
    emit(state.copyWith(status: NotificationStatus.loadingNextPage) as T);
    switch (T) {
      case NoticeState:
        await _notificationRepository.fetchNotice(state.pageNumber + 1).match(
            (e) {
          handle(e);
          error('failed to fetch notice: $e');
          emit(state.copyWith(status: NotificationStatus.failure) as T);
        }, (v) {
          final noticeList = v.notificationList;
          emit(
            state.copyWith(
              status: NotificationStatus.success,
              noticeList: [state.noticeList as M, ...noticeList as List<M>],
            ) as T,
          );
        }).run();
      case PersonalMessageState:
        await _notificationRepository
            .fetchPersonalMessage(state.pageNumber + 1)
            .match((e) {
          handle(e);
          error('failed to fetch notice: $e');
          emit(state.copyWith(status: NotificationStatus.failure) as T);
        }, (v) {
          if (v.isLeft()) {
            error('failed to fetch more notice, status code=${v.unwrapErr()}');
            return;
          }
          emit(
            state.copyWith(
              status: NotificationStatus.success,
              noticeList: [
                ...state.noticeList,
                ...v.unwrap().notificationList as List<M>,
              ],
            ) as T,
          );
        }).run();
      case BroadcastMessageState:
        await _notificationRepository
            .fetchBroadMessage(state.pageNumber + 1)
            .match((e) {
          handle(e);
          error('failed to fetch notice: $e');
          emit(state.copyWith(status: NotificationStatus.failure) as T);
        }, (v) {
          if (v.isLeft()) {
            error('resp code: ${v.unwrapErr()}');
            emit(state.copyWith(status: NotificationStatus.failure) as T);
            return;
          }
          final noticeList = v.unwrap().notificationList;
          final pageNumber = v.unwrap().pageNumber;
          final hasNextPage = v.unwrap().hasNextPage;
          emit(
            state.copyWith(
              status: NotificationStatus.success,
              noticeList: [state.noticeList as M, ...noticeList as List<M>],
              pageNumber: pageNumber,
              hasNextPage: hasNextPage,
            ) as T,
          );
        }).run();
      case Type():
        throw UnimplementedError('notification type not implemented: $T');
    }
    emit(state.copyWith(status: NotificationStatus.success) as T);
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
