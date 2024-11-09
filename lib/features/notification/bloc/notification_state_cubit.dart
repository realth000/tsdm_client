import 'dart:math' as math;

import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/features/notification/repository/notification_info_repository.dart';

part 'notification_state_cubit.mapper.dart';

/// Current notification state.
///
/// Stores unread numbers on each type of notification.
@MappableClass()
final class NotificationStateInfo with NotificationStateInfoMappable {
  /// Constructor.
  const NotificationStateInfo({
    required this.notice,
    required this.personalMessage,
    required this.broadcastMessage,
  });

  /// Empty info for initialization.
  static const empty = NotificationStateInfo(
    notice: 0,
    personalMessage: 0,
    broadcastMessage: 0,
  );

  /// Count of unread notice.
  final int notice;

  /// Count of unread personal message.
  final int personalMessage;

  /// Count of unread broadcast message.
  final int broadcastMessage;

  /// Total unread notification count.
  int get total => notice + personalMessage + broadcastMessage;
}

/// Lightweight global cubit stores the state of current unread notifications.
///
/// The state is a simple boolean value which represents a having unread notice
/// state if set to true.
///
/// This cubit is made separately because the state persists through the entire
/// app lifetime and may change often. A often changing state is not recommended
/// to store with other fragment type state as it will trigger unwanted state
/// update.
final class NotificationStateCubit extends Cubit<NotificationStateInfo> {
  /// Constructor.
  NotificationStateCubit(NotificationInfoRepository infoRepository)
      : _infoRepository = infoRepository,
        super(NotificationStateInfo.empty) {
    _infoRepository.status.listen(emit);
  }

  final NotificationInfoRepository _infoRepository;

  /// Increase unread notice count by [count].
  void increaseNotice([int count = 1]) =>
      emit(state.copyWith(notice: state.notice + count));

  /// Decrease unread notice count by [count].
  void decreaseNotice([int count = 1]) =>
      emit(state.copyWith(notice: math.max(state.notice - count, 0)));

  /// Set unread notice count to [count].
  void setNotice(int count) => emit(state.copyWith(notice: count));

  /// Increase unread personal message by [count].
  void increasePersonalMessage([int count = 1]) =>
      emit(state.copyWith(personalMessage: state.personalMessage + count));

  /// Decrease unread personal message by [count].
  void decreasePersonalMessage([int count = 1]) => emit(
        state.copyWith(
          personalMessage: math.max(state.personalMessage - count, 0),
        ),
      );

  /// Set unread personal message count to [count].
  void setPersonalMessage(int count) =>
      emit(state.copyWith(personalMessage: count));

  /// Increase unread broadcast message count.
  void increaseBroadcastMessage([int count = 1]) =>
      emit(state.copyWith(broadcastMessage: state.broadcastMessage + count));

  /// Decrease unread broadcast message count.
  void decreaseBroadcastMessage([int count = 1]) => emit(
        state.copyWith(
          broadcastMessage: math.max(state.broadcastMessage - count, 0),
        ),
      );

  /// Set unread broadcast message count to [count].
  void setBroadcastMessage(int count) =>
      emit(state.copyWith(broadcastMessage: count));

  /// Update all count of types of notification.
  void setAll({
    required int noticeCount,
    required int personalMessageCount,
    required int broadcastMessageCount,
  }) =>
      emit(
        state.copyWith(
          notice: noticeCount,
          personalMessage: personalMessageCount,
          broadcastMessage: broadcastMessageCount,
        ),
      );
}
