part of 'notification_bloc.dart';

enum NotificationStatus {
  initial,
  loading,
  success,
  failed,
}

class NotificationState extends Equatable {
  const NotificationState({
    this.status = NotificationStatus.initial,
    this.noticeList = const [],
  });

  final NotificationStatus status;

  final List<Notice> noticeList;

  NotificationState copyWith({
    NotificationStatus? status,
    List<Notice>? noticeList,
  }) {
    return NotificationState(
      status: status ?? this.status,
      noticeList: noticeList ?? this.noticeList,
    );
  }

  @override
  List<Object?> get props => [status, noticeList];
}
