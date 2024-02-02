part of 'notification_bloc.dart';

/// Status of notification.
enum NotificationStatus {
  /// Initial.
  initial,

  /// Loading.
  loading,

  /// Success.
  success,

  /// Failed.
  failed,
}

/// State of notification.
class NotificationState extends Equatable {
  /// Constructor.
  const NotificationState({
    this.status = NotificationStatus.initial,
    this.noticeList = const [],
  });

  /// Status.
  final NotificationStatus status;

  /// All fetched [Notice].
  final List<Notice> noticeList;

  /// Copy with.
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
